
import 'package:flutter/material.dart';

class TabManagerScreen extends StatefulWidget {
  final List<String> tabs;
  final Function(int, int) onReorder;
  final Function(String) onAddTab;

  const TabManagerScreen({
    super.key,
    required this.tabs,
    required this.onReorder,
    required this.onAddTab,
  });

  @override
  State<TabManagerScreen> createState() => _TabManagerScreenState();
}

class _TabManagerScreenState extends State<TabManagerScreen> {
  final TextEditingController _addTabController = TextEditingController();

  void _handleAddTab() {
    if (_addTabController.text.isNotEmpty) {
      widget.onAddTab(_addTabController.text);
      _addTabController.clear();
      FocusScope.of(context).unfocus(); // Dismiss keyboard
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage Tabs',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            // --- Add New Tab UI ---
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _addTabController,
                        decoration: const InputDecoration(
                          labelText: 'New Tab Name',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _handleAddTab(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                      onPressed: _handleAddTab,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 24),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Reorder Tabs',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            // --- Reorderable List ---
            Card(
              clipBehavior: Clip.antiAlias,
              child: ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onReorder: widget.onReorder,
                children: [
                  for (int i = 0; i < widget.tabs.length; i++)
                    ListTile(
                      key: ValueKey(widget.tabs[i]),
                      title: Text(widget.tabs[i]),
                      leading: const Icon(Icons.drag_handle),
                    ),
                ],
              ),
            ),
             const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Note: "shorts" and "feature" tabs cannot be reordered or removed.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
