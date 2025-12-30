const { DATABASE_ID, COLLECTIONS } = require('../config/constants');
const { Query } = require('node-appwrite');

/**
 * Run ad auction to select best ads for user
 * @param {Object} databases - Appwrite Databases instance
 * @param {Array} userInterests - User's interest tags
 * @param {number} limit - Maximum ads to return
 * @returns {Promise<Array>} Ranked ads by eCPM
 */
async function runAdAuction(databases, userInterests, limit = 5) {
    try {
        // Get active ads matching user interests with available budget
        const adCandidates = await databases.listDocuments(
            DATABASE_ID,
            COLLECTIONS.ADS,
            [
                Query.equal('isActive', true),
                Query.greaterThan('budget', 0),
                Query.limit(20) // Over-fetch for auction
            ]
        );

        // Filter ads that match user interests (client-side filtering)
        const relevantAds = adCandidates.documents.filter(ad => {
            if (!ad.targetTags || ad.targetTags.length === 0) return true; // Untargeted ads
            return ad.targetTags.some(tag => userInterests.includes(tag));
        });

        // Calculate eCPM for each ad
        const rankedAds = relevantAds
            .map(ad => {
                const eCPM = (ad.bidCpm || 0) * (ad.clickProbability || 0.01);
                return {
                    ...ad,
                    eCPM,
                    type: 'ad'
                };
            })
            .sort((a, b) => b.eCPM - a.eCPM)
            .slice(0, limit);

        return rankedAds;
    } catch (error) {
        // Handle missing collection error gracefully or provide fallback
        console.warn('Ad auction failed or collection missing, using fallback ad:', error.message);

        // Return a fallback Propeller Ad or Partner Ad
        return [{
            $id: 'fallback_ad_' + Date.now(),
            advertiserId: 'propeller_ads',
            content: 'Check out our partners for amazing offers!',
            mediaUrl: 'https://cdn.pixabay.com/photo/2016/10/09/08/32/digital-marketing-1725340_1280.jpg',
            linkUrl: 'https://otieu.com/4/10334985',
            targetTags: [],
            eCPM: 5.0,
            type: 'ad',
            isActive: true
        }];
    }
}

module.exports = { runAdAuction };
