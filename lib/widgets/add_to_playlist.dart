import 'package:flutter/material.dart';

class SaveToBottomSheet extends StatefulWidget {
  const SaveToBottomSheet({super.key});

  @override
  State<SaveToBottomSheet> createState() => _SaveToBottomSheetState();
}

class _SaveToBottomSheetState extends State<SaveToBottomSheet> {
  // State to track if playlists are checked
  bool isWatchLaterSelected = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Hug the content height
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Drag Handle (The small grey bar at the top)
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // 2. Title "Save to..."
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Save to...",
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                // Optional: Close button usually found on the right (not circled but UX best practice)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 3. The "Watch later" List Item
          _buildPlaylistItem(
            title: "Watch later",
            subtitle: "Private",
            isChecked: isWatchLaterSelected,
            hasThumbnail: true, 
            onTap: (value) {
              setState(() {
                isWatchLaterSelected = value ?? false;
              });
              
              // Optional: Show a snackbar when saved
              if (isWatchLaterSelected) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Saved to Watch later"),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
          ),

          // Divider similar to standard UI lists
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(),
          ),

          // 4. "+ New playlist" Button
          InkWell(
            onTap: () {
              // Action for new playlist
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Create new playlist clicked")),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Row(
                children: [
                  const Icon(Icons.add, size: 28),
                  const SizedBox(width: 20),
                  Text(
                    "New playlist",
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to build the playlist rows
  Widget _buildPlaylistItem({
    required String title,
    required String subtitle,
    required bool isChecked,
    required ValueChanged<bool?> onTap,
    bool hasThumbnail = false,
  }) {
    final theme = Theme.of(context);
    return CheckboxListTile(
      value: isChecked,
      onChanged: onTap,
      activeColor: Colors.blueAccent, // Color of the checkbox when ticked
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      controlAffinity: ListTileControlAffinity.trailing, // Checkbox on the right
      
      // Custom Layout for the "Secondary" (Leading) widget
      // We use a Row here to combine the thumbnail and text on the left side
      title: Row(
        children: [
          // The Thumbnail (Purple/Dark box from screenshot)
          if (hasThumbnail)
            Container(
              width: 50,
              height: 30,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Center(
                child: Icon(Icons.access_time, size: 16, color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
          
          // The Text Column
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.lock, size: 12, color: theme.disabledColor),
                  const SizedBox(width: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.disabledColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}