/**
 * TV Post Injector
 * Injects TV posts into the organic feed at controlled intervals
 * Similar to adInjector but with different frequency rules
 */

const TV_RULES = {
    FREQUENCY_CAP: 10,    // Min organic posts between TV posts (testing: 10)
    MAX_PER_FEED: 5,      // Max TV posts in one feed batch
    MIN_POSITION: 3,      // Don't inject before position 3
};

/**
 * Find valid positions to inject TV posts
 * @param {Array} feed - Current feed items
 * @param {Object} sessionContext - Session context
 * @returns {Array} Array of valid injection indices
 */
function findTVOpportunities(feed, sessionContext) {
    const opportunities = [];
    let lastTVIndex = -TV_RULES.FREQUENCY_CAP; // Allow first injection after FREQUENCY_CAP

    for (let i = TV_RULES.MIN_POSITION; i < feed.length; i++) {
        const item = feed[i];

        // Skip if this position already has an ad or TV post
        if (item.type === 'ad' || item.type === 'tv_post') {
            if (item.type === 'tv_post') {
                lastTVIndex = i;
            }
            continue;
        }

        // Check frequency cap
        if (i - lastTVIndex >= TV_RULES.FREQUENCY_CAP) {
            opportunities.push(i);
            lastTVIndex = i;
        }
    }

    return opportunities.slice(0, TV_RULES.MAX_PER_FEED);
}

/**
 * Inject TV posts into feed at opportunity windows
 * @param {Array} organicFeed - Feed with organic posts (and possibly ads)
 * @param {Array} tvPosts - Available TV posts to inject
 * @param {Object} sessionContext - Session context
 * @returns {Array} Feed with TV posts injected
 */
function injectTVPosts(organicFeed, tvPosts, sessionContext) {
    if (!tvPosts || tvPosts.length === 0) {
        return organicFeed;
    }

    const feed = [...organicFeed];
    const opportunities = findTVOpportunities(feed, sessionContext);

    let tvIndex = 0;
    let injected = 0;

    for (const position of opportunities) {
        if (tvIndex >= tvPosts.length) break;

        const tvPost = tvPosts[tvIndex];

        // Mark the TV post for frontend rendering
        const markedTVPost = {
            ...tvPost,
            type: 'tv_post',
            _injectionPosition: position,
        };

        // Insert at position (adjusting for previous insertions)
        feed.splice(position + injected, 0, markedTVPost);
        injected++;
        tvIndex++;
    }

    return feed;
}

module.exports = { injectTVPosts, findTVOpportunities, TV_RULES };
