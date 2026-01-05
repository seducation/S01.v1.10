const { Query } = require('node-appwrite');
const { DATABASE_ID, COLLECTIONS } = require('../config/constants');

/**
 * Fetch TV posts from followed TV profiles
 * @param {Object} databases - Appwrite Databases instance
 * @param {Array} profileIds - User's profile IDs (to check follows)
 * @param {number} limit - Max TV posts to fetch
 * @returns {Promise<Array>} TV posts with metadata
 */
async function getTVPosts(databases, profileIds, limit = 10) {
    try {
        if (!profileIds || profileIds.length === 0) {
            return [];
        }

        // 1. Get followed TV profiles
        const followsResult = await databases.listDocuments(
            DATABASE_ID,
            COLLECTIONS.FOLLOWS,
            [
                Query.equal('follower_id', profileIds),
                Query.equal('target_type', 'tv'),
                Query.limit(50)
            ]
        );

        if (followsResult.total === 0) {
            return [];
        }

        const followedTVIds = followsResult.documents.map(f => f.target_id);

        // 2. Fetch recent TV posts from those profiles
        const tvPostsResult = await databases.listDocuments(
            DATABASE_ID,
            COLLECTIONS.TV_POSTS,
            [
                Query.equal('tv_profile_id', followedTVIds),
                Query.orderDesc('published_at'),
                Query.limit(limit)
            ]
        );

        // 3. Hydrate with TV profile data
        const tvProfileIds = [...new Set(tvPostsResult.documents.map(p => p.tv_profile_id))];
        const profilesMap = {};

        if (tvProfileIds.length > 0) {
            const profilesResult = await databases.listDocuments(
                DATABASE_ID,
                COLLECTIONS.TV_PROFILES,
                [
                    Query.equal('$id', tvProfileIds),
                    Query.limit(50)
                ]
            );
            profilesResult.documents.forEach(p => {
                profilesMap[p.$id] = p;
            });
        }

        // 4. Format for feed consumption
        return tvPostsResult.documents.map(post => ({
            $id: post.$id,
            type: 'tv_post',
            title: post.title,
            url: post.url,
            description: post.description,
            image_url: post.image_url,
            published_at: post.published_at,
            tv_profile_id: post.tv_profile_id,
            tv_profile: profilesMap[post.tv_profile_id] || null,
            // Engagement fields (if they exist)
            likes_count: post.likes_count || 0,
            comments_count: post.comments_count || 0,
        }));

    } catch (error) {
        console.error('Error fetching TV posts:', error.message);
        return [];
    }
}

module.exports = { getTVPosts };
