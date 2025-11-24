import 'package:flutter/material.dart';

// Data model for each navigation item
class TravelOption {
  final IconData icon;
  final String label;

  TravelOption(this.icon, this.label);
}

// List of all travel options
final List<TravelOption> travelOptions = [
  TravelOption(Icons.flight, 'Flights'),
  TravelOption(Icons.business, 'Hotels'), // Represents buildings/hotels
  TravelOption(Icons.directions_bus, 'Buses'),
  TravelOption(Icons.train, 'Trains'),
  TravelOption(Icons.directions_car, 'Cabs'),
];

// The main card component
class TravelNavigationCard extends StatelessWidget {
  const TravelNavigationCard({super.key});

  @override
  Widget build(BuildContext context) {
    // The main card container with rounded corners and shadow
    return Card(
      elevation: 6,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Keep the column compact
          children: [
            // --- 1. Horizontal Row of Navigation Icons ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: travelOptions.map((option) {
                return _NavigationItem(
                  icon: option.icon,
                  label: option.label,
                  onTap: () {
                    // Handle navigation to the selected category
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tapped on ${option.label}')),
                    );
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 20),

            // --- 2. Downward Chevron/Expand Icon ---
            GestureDetector(
              onTap: () {
                // Action to expand the card or show more options
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tapped on Expand/More Options')),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: 32,
                  color: Color(0xFFE53935), // The signature Red color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable widget for an individual icon and label combination
class _NavigationItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  
  // Define the consistent red color used in the UI
  static const Color iconColor = Color(0xFFE53935);

  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circular container for the icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withAlpha(25), // Light red background
              ),
              child: Icon(
                icon,
                color: iconColor, // Red icon foreground
                size: 28,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Label text
            Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
