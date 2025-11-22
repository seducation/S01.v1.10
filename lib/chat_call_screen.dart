import 'package:my_app/model/panggilan.dart';
import 'package:my_app/provider/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Panggilan extends StatefulWidget {
  const Panggilan({super.key});

  @override
  State<Panggilan> createState() => _PanggilanState();
}

class _PanggilanState extends State<Panggilan> {
  void showSnackbar(String nama) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 1),
        content: Text(nama),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Consumer<ThemeModel>(
      builder: (context, ThemeModel themeNotifier, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: themeNotifier.isDark
                ? const Color.fromARGB(255, 91, 90, 90)
                : const Color.fromARGB(255, 70, 113, 148),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              "Panggilan",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: width * 0.05,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert_rounded),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color.fromARGB(255, 69, 168, 248),
            onPressed: () {},
            child: Icon(
              Icons.call,
              color: themeNotifier.isDark ? Colors.white : Colors.white,
            ),
          ),
          body: SizedBox(
            width: width,
            height: height,
            child: ListView.builder(
              itemCount: panggilanItems.length,
              itemBuilder: (context, index) {
                final items = panggilanItems[index];
                return ListTile(
                  onTap: () => showSnackbar(items.nama),
                  leading: SizedBox(
                    height: 50,
                    width: 50,
                    child: ClipOval(
                      child: Image.network(
                        items.image,
                        fit: BoxFit.fill,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.person, size: 50);
                        },
                      ),
                    ),
                  ),
                  title: Text(items.nama),
                  subtitle: Row(
                    children: [
                      const Icon(
                        Icons.call_made,
                        color: Colors.green,
                        size: 15,
                      ),
                      Expanded(
                        child: Text(
                          items.subtitle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.call,
                    color: Colors.blue,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
