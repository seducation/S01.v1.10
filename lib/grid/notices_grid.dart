import 'package:flutter/material.dart';
import 'package:my_app/models/product.dart' as real;
import 'package:my_app/appwrite_service.dart';
import 'package:my_app/product_detailed_page.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NoticesGridWidget extends StatefulWidget {
  const NoticesGridWidget({super.key});

  @override
  State<NoticesGridWidget> createState() => _NoticesGridWidgetState();
}

class _NoticesGridWidgetState extends State<NoticesGridWidget> {
  late Future<List<real.Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    final appwriteService = Provider.of<AppwriteService>(
      context,
      listen: false,
    );
    _productsFuture = _getProducts(appwriteService);
  }

  Future<List<real.Product>> _getProducts(AppwriteService service) async {
    try {
      final response = await service.getProducts();
      return response.rows
          .map((row) => real.Product.fromMap(row.data, row.$id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching products for notices: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'New Notices',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 250,
          child: FutureBuilder<List<real.Product>>(
            future: _productsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                return const Center(child: Text('No notices available.'));
              }

              final products = snapshot.data!;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductDetailPage(product: product),
                        ),
                      );
                    },
                    child: Container(
                      width: 150,
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: product.imageId != null
                                  ? CachedNetworkImage(
                                      imageUrl: context
                                          .read<AppwriteService>()
                                          .getFileViewUrl(product.imageId!),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      placeholder: (context, url) =>
                                          const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    )
                                  : Container(
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.image),
                                    ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
