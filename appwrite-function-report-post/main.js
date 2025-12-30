const sdk = require('node-appwrite');

module.exports = async function (req, res) {
  const client = new sdk.Client();
  const databases = new sdk.Databases(client);
  const users = new sdk.Users(client);

  if (
    !req.variables['APPWRITE_FUNCTION_ENDPOINT'] ||
    !req.variables['APPWRITE_FUNCTION_API_KEY'] ||
    !req.variables['APPWRITE_FUNCTION_PROJECT_ID']
  ) {
    console.warn("Environment variables are not set. Function cannot use Appwrite SDK.");
    res.json({ success: false, message: "Environment variables are not set." });
    return;
  }

  client
    .setEndpoint(req.variables['APPWRITE_FUNCTION_ENDPOINT'])
    .setProject(req.variables['APPWRITE_FUNCTION_PROJECT_ID'])
    .setKey(req.variables['APPWRITE_FUNCTION_API_KEY']);

  const payload = JSON.parse(req.payload || '{}');
  const { postId, reporterId, reason } = payload;

  if (!postId || !reporterId || !reason) {
    res.json({ success: false, message: "Missing required parameters." });
    return;
  }

  // TODO: Update with your actual Database ID
  const databaseId = 'gvone';
  const reportsCollectionId = 'reports'; // New collection
  const postsCollectionId = 'posts';
  const profilesCollectionId = 'profiles';

  // Thresholds

  const POST_BLOCK_THRESHOLD = 25;
  const PROFILE_BLOCK_THRESHOLD = 10;
  const ACCOUNT_BLOCK_THRESHOLD = 5;

  try {
    // 1. Check for duplicate report
    const existingReports = await databases.listDocuments(
      databaseId,
      reportsCollectionId,
      [
        sdk.Query.equal('postId', postId),
        sdk.Query.equal('reporterId', reporterId)
      ]
    );

    if (existingReports.total > 0) {
      res.json({ success: false, message: "You have already reported this post." });
      return;
    }

    // 2. Fetch Post to verify and get author
    const post = await databases.getDocument(databaseId, postsCollectionId, postId);

    if (post.author_id === reporterId || // Assuming author_id is profile ID of author
      (post.author && post.author.$id === reporterId)) {
      res.json({ success: false, message: "You cannot report your own post." });
      return;
    }

    // 3. Create Report
    await databases.createDocument(
      databaseId,
      reportsCollectionId,
      sdk.ID.unique(),
      {
        postId,
        reporterId,
        reason,
        timestamp: new Date().toISOString()
      }
    );

    // 4. Update Post Report Count
    const newReportCount = (post.reportCount || 0) + 1;
    let postUpdates = { reportCount: newReportCount };
    let postBlocked = false;

    if (newReportCount >= POST_BLOCK_THRESHOLD && !post.isBlocked) {
      postUpdates.isBlocked = true;
      postUpdates.blockedAt = new Date().toISOString();
      postBlocked = true;
    }

    await databases.updateDocument(
      databaseId,
      postsCollectionId,
      postId,
      postUpdates
    );

    // 5. Escalate to Profile Level if Post Blocked

    if (postBlocked) {
      const authorProfileId = post.profile_id || post.author.$id;
      const profile = await databases.getDocument(databaseId, profilesCollectionId, authorProfileId);

      const newBlockedPostCount = (profile.blockedPostCount || 0) + 1;
      let profileUpdates = { blockedPostCount: newBlockedPostCount };
      let profileBlocked = false;

      // Check Profile Threshold (10)
      if (newBlockedPostCount >= PROFILE_BLOCK_THRESHOLD && !profile.isBlocked) {
        console.log(`Profile ${authorProfileId} reached block threshold (${PROFILE_BLOCK_THRESHOLD}). Blocking profile.`);
        profileUpdates.isBlocked = true;
        profileBlocked = true;
      }

      await databases.updateDocument(
        databaseId,
        profilesCollectionId,
        authorProfileId,
        profileUpdates
      );

      // 6. Escalate to Account Level if Profile RECENTLY Blocked
      if (profileBlocked) {
        const ownerId = profile.ownerId;

        // Query all profiles for this user that are BLOCKED
        const blockedProfiles = await databases.listDocuments(
          databaseId,
          profilesCollectionId,
          [
            sdk.Query.equal('ownerId', ownerId),
            sdk.Query.equal('isBlocked', true)
          ]
        );

        // Check Account Threshold (5 blocked profiles)
        if (blockedProfiles.total >= ACCOUNT_BLOCK_THRESHOLD) {
          console.log(`User ${ownerId} has ${blockedProfiles.total} blocked profiles. Reached threshold (${ACCOUNT_BLOCK_THRESHOLD}). Blocking Account.`);

          // 1. Block User Account
          await users.updateStatus(ownerId, false);

          // 2. Block ALL remaining profiles to ensure they are hidden
          const allUserProfiles = await databases.listDocuments(
            databaseId,
            profilesCollectionId,
            [sdk.Query.equal('ownerId', ownerId)]
          );

          for (const userProfile of allUserProfiles.documents) {
            if (!userProfile.isBlocked) {
              await databases.updateDocument(
                databaseId,
                profilesCollectionId,
                userProfile.$id,
                { isBlocked: true }
              );
              console.log(`System Blocked profile: ${userProfile.$id} (Account Ban Cascade)`);
            }
          }
        }
      }
    }

    res.json({ success: true, message: "Report submitted successfully." });

  } catch (error) {
    console.error("Reporting Error:", error);
    res.json({ success: false, message: "An error occurred processing the report.", error: error.message });
  }
};
