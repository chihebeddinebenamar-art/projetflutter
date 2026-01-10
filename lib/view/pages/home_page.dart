import 'package:flutter/material.dart';
import '../../const/constants.dart';
import '../../models/product.dart';
import '../../models/category.dart';
import '../../services/cart_service.dart';
import '../widgets/cards/product_card.dart';
import '../widgets/inputs/glass_text_field.dart';
import 'product_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<Category> categories = [];
  List<Product> products = [];
  bool isLoading = true;
  String selectedCategory = 'Tous';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final CartService _cartService = CartService();

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          categories = _getDemoCategories();
          products = _getDemoProducts();
          isLoading = false;
        });
      }
    });
  }

  // --- Demo Data Suppliers ---
  List<Category> _getDemoCategories() {
    return [
      Category(id: 1, name: 'Tous', productCount: 12),
      Category(id: 2, name: 'Homme', productCount: 5),
      Category(id: 3, name: 'Femme', productCount: 4),
      Category(id: 4, name: 'Mixte', productCount: 3),
    ];
  }

  String _getProductImagePath(int productId, String categoryName) {
    switch (productId) {
      case 1: return 'assets/images/products/categorieFemmeProduit1.jpg';
      case 2: return 'assets/images/products/categorieFemmeProduit1.jpg';
      case 3: return 'assets/images/products/categoriehommeProduit1.jpg';
      case 4: return 'assets/images/products/categorieMixteProduit1.jpg';
      case 5: return 'assets/images/products/categoriehommeProduit2.jpg';
      case 6: return 'assets/images/products/categorieFemmeProduit1.jpg';
      default:
        if (categoryName == 'Femme') return 'assets/images/products/categorieFemmeProduit1.jpg';
        if (categoryName == 'Homme') return 'assets/images/products/categoriehommeProduit1.jpg';
        return 'assets/images/products/categorieMixteProduit1.jpg';
    }
  }

  List<Product> _getDemoProducts() {
  return [

    // 🟣 FEMME
    Product(
      id: 1,
      name: 'T-shirt sport femme',
      description: 'T-shirt léger et respirant, idéal pour le fitness et le training.',
      price: 70.0,
      finalPrice: 63.0,
      size: 'M',
      color: 'Noir',
      stockQuantity: 40,
      categoryId: 3,
      categoryName: 'Femme',
      discount: 10,
      discountActive: true,
      images: [ProductImage(id: 1, url: _getProductImagePath(1, 'Femme'), productId: 1)],
      rating: 4.4,
    ),

    // 🔵 HOMME
    Product(
      id: 2,
      name: 'T-shirt sport homme noir',
      description: 'T-shirt confortable pour entraînement intensif.',
      price: 75.0,
      size: 'L',
      color: 'Noir',
      stockQuantity: 50,
      categoryId: 2,
      categoryName: 'Homme',
      discount: null,
      discountActive: false,
      images: [ProductImage(id: 2, url: _getProductImagePath(3, 'Homme'), productId: 2)],
      rating: 4.2,
    ),

    Product(
      id: 3,
      name: 'T-shirt sport homme gris',
      description: 'T-shirt moderne, tissu respirant et résistant.',
      price: 80.0,
      size: 'XL',
      color: 'Gris',
      stockQuantity: 35,
      categoryId: 2,
      categoryName: 'Homme',
      discount: 5,
      discountActive: true,
      images: [ProductImage(id: 3, url: _getProductImagePath(5, 'Homme'), productId: 3)],
      rating: 4.5,
    ),

    Product(
      id: 4,
      name: 'Chaussures sport homme',
      description: 'Chaussures légères pour running et salle de sport.',
      price: 120.0,
      size: '42',
      color: 'Noir',
      stockQuantity: 25,
      categoryId: 2,
      categoryName: 'Homme',
      discount: null,
      discountActive: false,
      images: [ProductImage(id: 4, url: _getProductImagePath(5, 'Homme'), productId: 4)],
      rating: 4.3,
    ),

    // 🔴 MIXTE – Compléments

    Product(
      id: 5,
      name: 'Whey Protein',
      description: 'Protéine whey pour prise de masse musculaire et récupération rapide.',
      price: 180.0,
      size: '2kg',
      color: 'Noir',
      stockQuantity: 60,
      categoryId: 4,
      categoryName: 'Mixte',
      discount: 10,
      discountActive: true,
      images: [ProductImage(id: 5, url: _getProductImagePath(4, 'Mixte'), productId: 5)],
      rating: 4.7,
    ),

    Product(
      id: 6,
      name: 'Plant Protein',
      description: 'Protéine végétale naturelle adaptée aux hommes et femmes.',
      price: 165.0,
      size: '1.8kg',
      color: 'Vert',
      stockQuantity: 45,
      categoryId: 4,
      categoryName: 'Mixte',
      discount: null,
      discountActive: false,
      images: [ProductImage(id: 6, url: _getProductImagePath(4, 'Mixte'), productId: 6)],
      rating: 4.6,
    ),

    Product(
      id: 7,
      name: 'Mass Gainer',
      description: 'Complément riche en calories pour prise de poids rapide.',
      price: 200.0,
      size: '3kg',
      color: 'Gris',
      stockQuantity: 30,
      categoryId: 4,
      categoryName: 'Mixte',
      discount: 8,
      discountActive: true,
      images: [ProductImage(id: 7, url: _getProductImagePath(4, 'Mixte'), productId: 7)],
      rating: 4.5,
    ),
  ];
}


  List<Product> get filteredProducts {
    List<Product> filtered = products;
    if (selectedCategory != 'Tous') {
      filtered = filtered.where((p) => p.categoryName == selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) {
        final nameMatch = p.name.toLowerCase().contains(_searchQuery);
        final descriptionMatch = p.description.toLowerCase().contains(_searchQuery);
        return nameMatch || descriptionMatch;
      }).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
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
          
          SafeArea(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : CustomScrollView(
                    slivers: [
                      // Header & Search
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Find Your\nPerfect Uniform',
                                style: AppTextStyles.displayMedium.copyWith(height: 1.1),
                              ),
                              const SizedBox(height: 20),
                              GlassTextField(
                                controller: _searchController,
                                label: 'Search',
                                hint: 'Search products...',
                                prefixIcon: Icons.search,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Categories
                      SliverToBoxAdapter(
                        child: Container(
                          height: 70,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              final category = categories[index];
                              final isSelected = category.name == selectedCategory;
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: ChoiceChip(
                                  label: Text(category.name),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      selectedCategory = category.name;
                                    });
                                  },
                                  selectedColor: AppColors.primary,
                                  backgroundColor: AppColors.surface,
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.black : Colors.white,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: isSelected ? AppColors.primary : AppColors.glassWhite,
                                      width: 1,
                                    ),
                                  ),
                                  showCheckmark: false,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      
                      // Product Grid
                      SliverPadding(
                        padding: const EdgeInsets.all(20),
                        sliver: filteredProducts.isEmpty
                            ? SliverToBoxAdapter(
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 50),
                                    child: Column(
                                      children: [
                                        Icon(Icons.search_off, size: 60, color: AppColors.textSecondary.withOpacity(0.5)),
                                        const SizedBox(height: 10),
                                        Text(
                                          'No products found',
                                          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : SliverGrid(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.65,
                                  crossAxisSpacing: 15,
                                  mainAxisSpacing: 15,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final product = filteredProducts[index];
                                    return ProductCard(
                                      product: product,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProductDetailPage(product: product),
                                          ),
                                        );
                                      },
                                      onAddToCart: () {
                                        _cartService.addToCart(product);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('${product.name} added to cart'),
                                            backgroundColor: AppColors.success,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  childCount: filteredProducts.length,
                                ),
                              ),
                      ),
                      
                      // Bottom Spacing
                      const SliverToBoxAdapter(child: SizedBox(height: 80)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
