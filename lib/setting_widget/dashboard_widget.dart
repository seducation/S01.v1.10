import 'package:flutter/material.dart';

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({super.key});

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  // State variables to simulate dynamic data
  String karmaCount = "127,225";
  double followerPercentChange = -0.05;
  String followingCount = "1,234";
  String likesCount = "5,678";
  String savedCount = "42";
  String historyCount = "108";
  String gamesCount = "9";
  String lensCount = "3";
  String groupsCount = "7";
  String websitesCount = "21";
  String memoriesCount = "14";

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFollowerCard(),
          const SizedBox(width: 12),
          _buildDashboardStat("Following", followingCount),
          const SizedBox(width: 12),
          _buildDashboardStat("Likes", likesCount),
          const SizedBox(width: 12),
          _buildDashboardStat("Saved", savedCount),
          const SizedBox(width: 12),
          _buildDashboardStat("History", historyCount),
          const SizedBox(width: 12),
          _buildDashboardStat("Games", gamesCount),
          const SizedBox(width: 12),
          _buildDashboardStat("Lens", lensCount),
          const SizedBox(width: 12),
          _buildDashboardStat("Groups", groupsCount),
          const SizedBox(width: 12),
          _buildDashboardStat("Websites", websitesCount),
          const SizedBox(width: 12),
          _buildDashboardStat("Memories", memoriesCount),
        ],
      ),
    );
  }

  Widget _buildFollowerCard() {
    return Container(
      width: 180,
      height: 110,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Row: Label and Percentage
          Row(
            children: [
              const Text(
                "Follower",
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "$followerPercentChange%",
                style: const TextStyle(
                  color: Color(0xFFE57373), // Salmon/Red color
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          // Bottom Row: Price and Action Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                karmaCount,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                ),
              ),
              Container(
                height: 32,
                width: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFF8B2D2D), // Dark Red circle
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_downward,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardStat(String title, String count) {
    return Container(
      width: 160,
      height: 110,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
          ),
        ],
      ),
    );
  }
}
