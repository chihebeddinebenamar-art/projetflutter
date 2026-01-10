import 'package:flutter/material.dart';
import 'dart:ui';
import '../../const/constants.dart';
import '../../models/product.dart';
import '../../services/cart_service.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;
  int currentImageIndex = 0;
  final CartService _cartService = CartService();
  bool _isAddingToCart = false;

  @override
  Widget build(BuildContext context) {
     final product = widget.product;
    final images = product.images.isNotEmpty
        ? product.images
        : [ProductImage(id: 0, url: '', productId: product.id)];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: AppDecorations.glassBox(
              radius: 50,
              tint: AppColors.glassBlack,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.darkGradient,
              ),
            ),
          ),
          
          Column(
            children: [
              // Product Image Area
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    // Main Image with Hero Logic (if any) or Transition
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Container(
                        key: ValueKey(currentImageIndex),
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                        ),
                        child: images[currentImageIndex].url.isNotEmpty
                          ? Image.asset(
                              images[currentImageIndex].url,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(Icons.broken_image, size: 60, color: Colors.white24),
                              ),
                            )
                          : const Center(child: Icon(Icons.image, size: 60, color: Colors.white24)),
                      ),
                    ),
                    
                    // Gradient Overlay at bottom for seamless merge
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 100,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.backgroundDark,
                            ],
                          ),
                        ),
                      ),
                    ),

                     // Discount Badge
                    if (product.hasDiscount)
                      Positioned(
                        top: 100,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.error.withOpacity(0.5),
                                blurRadius: 15,
                              )
                            ]
                          ),
                          child: Text(
                            '-${product.discount}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Product Details
              Expanded(
                flex: 6,
                child: Container(
                   padding: const EdgeInsets.symmetric(horizontal: 24),
                   decoration: const BoxDecoration(
                     color: Colors.transparent,
                   ),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                        // Title & Rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                style: AppTextStyles.displayMedium.copyWith(fontSize: 24),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (product.rating != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: AppDecorations.glassBox(radius: 12),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star, color: AppColors.warning, size: 16),
                                    const SizedBox(width: 5),
                                    Text(
                                      product.rating!.toStringAsFixed(1),
                                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        
                        const SizedBox(height: 10),
                        
                        // Price
                        Row(
                          children: [
                             Text(
                               '${product.displayPrice.toStringAsFixed(2)} DT',
                               style: AppTextStyles.displayLarge.copyWith(
                                 color: AppColors.primary,
                                 fontSize: 32,
                               ),
                             ),
                             if (product.hasDiscount) ...[
                               const SizedBox(width: 10),
                               Text(
                                 '${product.price.toStringAsFixed(2)} DT',
                                 style: AppTextStyles.bodyMedium.copyWith(
                                   decoration: TextDecoration.lineThrough,
                                   color: AppColors.textSecondary,
                                 ),
                               ),
                             ],
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Info Chips
                        Row(
                          children: [
                            _buildInfoChip(Icons.category_outlined, product.categoryName),
                            const SizedBox(width: 10),
                            _buildInfoChip(Icons.palette_outlined, product.color),
                            const SizedBox(width: 10),
                            _buildInfoChip(Icons.straighten_outlined, product.size),
                          ],
                        ),

                        const SizedBox(height: 20),
                        
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              product.description,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),

                        // Quantity & Cart Action
                        Row(
                          children: [
                            Container(
                              decoration: AppDecorations.glassBox(radius: 30),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, color: Colors.white),
                                    onPressed: quantity > 1 ? () => setState(() => quantity--) : null,
                                  ),
                                  Text(
                                    '$quantity', 
                                    style: AppTextStyles.titleLarge,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, color: Colors.white),
                                    onPressed: quantity < product.stockQuantity ? () => setState(() => quantity++) : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: GestureDetector(
                                onTap: (product.stockQuantity > 0 && !_isAddingToCart) ? _addToCart : null,
                                child: Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.5),
                                        blurRadius: 20,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: _isAddingToCart
                                    ? const SizedBox(
                                        height: 24, width: 24,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                                          const SizedBox(width: 10),
                                          Text(
                                            'ADD TO CART',
                                            style: AppTextStyles.button.copyWith(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                     ],
                   ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassWhite),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _addToCart() async {
    setState(() => _isAddingToCart = true);
    await Future.delayed(const Duration(milliseconds: 500));
    _cartService.addToCart(widget.product, quantity: quantity);
    
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} added to cart'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
                 
    setState(() => _isAddingToCart = false);
  }
}
