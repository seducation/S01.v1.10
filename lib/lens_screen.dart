import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' hide Row;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import 'webview_screen.dart';

class LensScreen extends StatefulWidget {
  const LensScreen({super.key});

  @override
  State<LensScreen> createState() => _LensScreenState();
}

class _LensScreenState extends State<LensScreen> {
  // Replace with your Appwrite project ID and endpoint
  final String appwriteEndpoint = 'https://sgp.cloud.appwrite.io/v1';
  final String appwriteProjectId = '691948bf001eb3eccd77';
  final String appwriteDatabaseId = '691963ed003c37eb797f';
  final String appwriteCollectionId = 'image';
  final String appwriteBucketId = 'lens-s';

  late Client client;
  late Databases databases;
  late Storage storage;
  final List<Document> _items = [];
  bool _isLoading = false;
  String? _error;
  bool _hasMore = true;
  String? _lastDocumentId;

  final _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    client = Client();
    client
        .setEndpoint(appwriteEndpoint)
        .setProject(appwriteProjectId);

    databases = Databases(client);
    storage = Storage(client);
    _fetchData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _fetchData();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      List<String> queries = [Query.limit(10)];
      if (_lastDocumentId != null) {
        queries.add(Query.cursorAfter(_lastDocumentId!));
      }
      // ignore: deprecated_member_use
      final response = await databases.listDocuments(
        databaseId: appwriteDatabaseId,
        collectionId: appwriteCollectionId,
        queries: queries,
      );

      if (response.documents.isNotEmpty) {
        setState(() {
          _items.addAll(response.documents);
          _lastDocumentId = response.documents.last.$id;
          if (response.documents.length < 10) {
            _hasMore = false;
          }
        });
      } else {
        setState(() {
          _hasMore = false;
        });
      }
    } on AppwriteException catch (e) {
      setState(() {
        _error = e.message;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _items.clear();
      _lastDocumentId = null;
      _hasMore = true;
    });
    await _fetchData();
  }

  Future<void> _uploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }

    final link = await _showLinkDialog();

    setState(() {
      _isLoading = true;
    });

    try {
      final file = await storage.createFile(
        bucketId: appwriteBucketId,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: image.path),
      );

      final imageUrl =
          '$appwriteEndpoint/storage/buckets/$appwriteBucketId/files/${file.$id}/view?project=$appwriteProjectId';

      // ignore: deprecated_member_use
      await databases.createDocument(
        databaseId: appwriteDatabaseId,
        collectionId: appwriteCollectionId,
        documentId: ID.unique(),
        data: {
          'title': 'New Image',
          'description': 'A beautiful new image',
          'imageUrl': imageUrl,
          'link': link,
        },
      );

      // Refresh data after upload
      await _refreshData();
    } on AppwriteException catch (e) {
      setState(() {
        _error = e.message;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

    Future<String?> _showLinkDialog() async {
    final TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add a link (optional)'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "https://example.com"),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Upload'),
            onPressed: () => Navigator.of(context).pop(controller.text),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    if (kIsWeb) {
      final Uri url = Uri.parse(urlString);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $urlString')),
        );
      }
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WebViewScreen(url: urlString),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            title: const Text('Lens'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _refreshData,
              ),
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  context.go('/profile');
                },
              ),
            ],
            pinned: true,
            floating: true,
          ),
          SliverToBoxAdapter(
            child: GestureDetector(
              onTap: _uploadImage,
              child: const Card(
                margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined),
                      SizedBox(width: 8),
                      Text('Camera'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_error != null)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error: $_error'),
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.all(4.0),
            sliver: SliverGrid(
              gridDelegate: SliverQuiltedGridDelegate(
                crossAxisCount: 2,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                pattern: const [
                  QuiltedGridTile(2, 2),
                  QuiltedGridTile(1, 1),
                  QuiltedGridTile(1, 1),
                ],
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = _items[index];
                  final isBigTile = (index % 3) == 0;
                  return GestureDetector(
                     onTap: () {
                      final link = item.data['link'];
                      if (link != null && link.isNotEmpty) {
                        _launchUrl(link);
                      }
                    },
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.data['imageUrl'] != null)
                            Expanded(
                              child: Image.network(
                                item.data['imageUrl'],
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(child: CircularProgressIndicator());
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.error);
                                },
                              ),
                            ),
                          if (item.data['title'] != null)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                item.data['title'],
                                style:
                                    const TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          if (item.data['description'] != null && !isBigTile)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                item.data['description'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: _items.length,
              ),
            ),
          ),
          if (_isLoading)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
