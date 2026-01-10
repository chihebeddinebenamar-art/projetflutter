import 'package:flutter/material.dart';
import '../../../const/constants.dart';
import '../../../services/cart_service.dart';

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: AppDecorations.glassBox(
        radius: AppDimensions.radiusM,
        tint: AppColors.surface.withOpacity(0.6),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 90,
              height: 90,
              color: Colors.transparent,
              child: product.images.isNotEmpty
                  ? Image.asset(
                      product.images.first.url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(child: Icon(Icons.broken_image, color: AppColors.textSecondary)),
                    )
                  : Center(child: Icon(Icons.image, color: AppColors.textSecondary)),
            ),
          ),
          const SizedBox(width: 15),
          // Informations
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                      onPressed: onRemove,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                
                Text(
                  '${product.size} • ${product.color}',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (product.hasDiscount)
                          Text(
                            '${product.price.toStringAsFixed(2)} DT',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        Text(
                          '${product.displayPrice.toStringAsFixed(2)} DT',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.primary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    
                    // Quantity
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.glassWhite),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _QuantityBtn(
                            icon: Icons.remove,
                            onTap: item.quantity > 1 ? () => onQuantityChanged(item.quantity - 1) : null,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              item.quantity.toString(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          _QuantityBtn(
                            icon: Icons.add,
                            onTap: item.quantity < product.stockQuantity ? () => onQuantityChanged(item.quantity + 1) : null,
                          ),
                        ],
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

class _QuantityBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QuantityBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 14, color: onTap != null ? AppColors.textPrimary : AppColors.textSecondary.withOpacity(0.5)),
      onPressed: onTap,
      padding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(),
      splashRadius: 16,
    );
  }
}

