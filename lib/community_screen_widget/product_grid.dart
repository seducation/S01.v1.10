import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'product_model.dart';

class ProductGrid extends StatelessWidget {
  final List<Product> products = [
    Product(
      imageUrl: 'https://via.placeholder.com/150',
      title: 'Product 1',
      price: 19.99,
      vendor: 'Vendor 1',
      rating: 4.5,
      reviewCount: 10,
    ),
    Product(
      imageUrl: 'https://via.placeholder.com/150',
      title: 'Product 2',
      price: 29.99,
      vendor: 'Vendor 2',
      rating: 4.2,
      reviewCount: 20,
    ),
    Product(
      imageUrl: 'https://via.placeholder.com/150',
      title: 'Product 3',
      price: 39.99,
      vendor: 'Vendor 3',
      rating: 4.8,
      reviewCount: 30,
    ),
    Product(
      imageUrl: 'https://via.placeholder.com/150',
      title: 'Product 4',
      price: 49.99,
      vendor: 'Vendor 4',
      rating: 4.0,
      reviewCount: 40,
    ),
  ];

  ProductGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
      ),
      itemBuilder: (context, index) {
        return ProductCard(product: products[index]);
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0),
              ),
              child: CachedNetworkImage(
                imageUrl: product.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  '\u20b9${product.price}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 4.0),
                Row(
                  children: [
                    const Icon(Icons.store, size: 16.0),
                    const SizedBox(width: 4.0),
                    Text(
                      product.vendor,
                      style: const TextStyle(
                        fontSize: 12.0,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
                const Text(
                  'Free delivery',
                  style: TextStyle(
                    fontSize: 12.0,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 4.0),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16.0, color: Colors.amber),
                    const SizedBox(width: 4.0),
                    Text(
                      '${product.rating} (${product.reviewCount})',
                      style: const TextStyle(
                        fontSize: 12.0,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
