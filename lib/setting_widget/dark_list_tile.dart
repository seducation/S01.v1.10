import 'package:flutter/material.dart';

enum ItemType { history, navigation }

class MenuItem {
  final String title;
  final ItemType type;

  MenuItem({required this.title, required this.type});
}

class DarkListTile extends StatelessWidget {
  final MenuItem item;

  const DarkListTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Handle tap
      },
      // InkWell highlight color for visual feedback
      highlightColor: Colors.white.withAlpha(12),
      splashColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Title Text
            Text(
              item.title,
              style: const TextStyle(
                color: Color(0xFF9E9E9E), // Light grey text
                fontSize: 17,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.5,
              ),
            ),
            
            // Trailing Icon Logic
            if (item.type == ItemType.history)
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF333333), width: 1),
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(
                  Icons.history,
                  color: Color(0xFF5CA1D6), // Muted blue/grey for history
                  size: 16,
                ),
              )
            else
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFF555555), // Darker grey for chevron
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}
