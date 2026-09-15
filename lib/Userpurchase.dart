import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:growi_project/admin.dart';
import 'package:growi_project/appscreen/models.dart';
import 'package:growi_project/appscreen/payment.dart';
import 'package:growi_project/services/firebase_service.dart';

// A single reusable brand color so it isn't repeated everywhere.
const kBrandGreen = Color(0xFF1F7A4C);
const kBackgroundCream = Color(0xFFF8EED2);

/// Represents one line in the shopping cart.
/// Using a small class instead of a raw Map makes the code type-safe
/// and self-documenting (no more cart[i]['item'] as Models).
class CartItem {
  final Models product;
  final String color;

  CartItem({required this.product, required this.color});
}

class UserPurchese extends StatefulWidget {
  const UserPurchese({super.key});

  @override
  State<UserPurchese> createState() => _UserPurcheseState();
}

class _UserPurcheseState extends State<UserPurchese> {
  final List<CartItem> cart = [];
  final Map<int, String> selectedColors = {};
  bool showCart = false;
  bool _showCartAddedAnimation = false;
  Timer? _cartAddedTimer;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await FirebaseService.getProducts();
      if (!mounted) return;
      setState(() {
        globalPhonesList
          ..clear()
          ..addAll(products);
      });
    } catch (e) {
      if (mounted) {
        _showSnackBar('Unable to load products: $e', color: Colors.red);
      }
    }
  }

  // Total is now calculated on demand instead of being tracked as
  // mutable state that can drift out of sync with the cart contents.
  double get totalPrice =>
      cart.fold(0, (sum, item) => sum + item.product.price);

  // ---------------------------------------------------------------
  // Cart actions
  // ---------------------------------------------------------------

  void _showSnackBar(String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  void addToCart(Models product, int index) {
    final color = selectedColors[index];

    if (color == null) {
      _showSnackBar("Please select a color");
      return;
    }

    if (!product.inStock || product.stockQuantity <= 0) {
      _showSnackBar("This product is sold out", color: Colors.red);
      return;
    }
    setState(() {
      cart.add(CartItem(product: product, color: color));

      product.stockQuantity -= 1;
      if (product.stockQuantity <= 0) {
        product.inStock = false;
      }
    });
    _cartAddedTimer?.cancel();
    setState(() => _showCartAddedAnimation = true);
    _cartAddedTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _showCartAddedAnimation = false);
      }
    });
    _showSnackBar("${product.name} added ($color)", color: Colors.green);
  }

  @override
  void dispose() {
    _cartAddedTimer?.cancel();
    super.dispose();
  }

  void removeFromCart(int index) {
    setState(() {
      final removed = cart[index];
      removed.product.stockQuantity += 1;
      removed.product.inStock = true;
      cart.removeAt(index);
    });
  }
  void checkout() {
    if (cart.isEmpty) {
      _showSnackBar("Cart is empty");
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          cartItems: cart.map((item) => item.product).toList(),
          totalPrice: totalPrice,
          pickupLocation: "PEP",
          themeColor: kBrandGreen,
        ),
      ),
    );
  }
  void openImage(dynamic img) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _FullScreenImageView(image: img)),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundCream,
      appBar: _buildAppBar(),
      body: showCart ? _buildCartView() : _buildShopView(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: kBackgroundCream,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        "Growi Dress Store",
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: _CartIconWithBadge(
            itemCount: cart.length,
            showAddedAnimation: _showCartAddedAnimation,
            onTap: () => setState(() => showCart = !showCart),
          ),
        ),
      ],
    );
  }

  Widget _buildShopView() {
    if (globalPhonesList.isEmpty) {
      return const Center(
        child: Text("No Products Available", style: TextStyle(fontSize: 18)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: globalPhonesList.length,
      itemBuilder: (_, index) {
        final product = globalPhonesList[index];
        return ProductCard(
          product: product,
          selectedColor: selectedColors[index],
          onColorSelected: (color) =>
              setState(() => selectedColors[index] = color),
          onImageTap: openImage,
          onAddToCart: () => addToCart(product, index),
        );
      },
    );
  }

  Widget _buildCartView() {
    if (cart.isEmpty) {
      return const Center(
        child: Text("Cart Empty", style: TextStyle(fontSize: 20)),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: cart.length,
            itemBuilder: (_, index) {
              final item = cart[index];
              final stillAvailable = globalPhonesList.any(
                (product) => product.id == item.product.id,
              );

              return CartItemTile(
                item: item,
                stillAvailable: stillAvailable,
                onRemove: () => removeFromCart(index),
              );
            },
          ),
        ),
        CartSummary(totalPrice: totalPrice, onCheckout: checkout),
      ],
    );
  }
}

class _CartIconWithBadge extends StatelessWidget {
  final int itemCount;
  final bool showAddedAnimation;
  final VoidCallback onTap;

  const _CartIconWithBadge({
    required this.itemCount,
    required this.showAddedAnimation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: child,
            ),
            child: showAddedAnimation
                ? const Text(
                    '+1',
                    key: ValueKey('cart-added'),
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  )
                : const Icon(
                    Icons.shopping_cart,
                    key: ValueKey('cart-icon'),
                    color: Colors.black,
                  ),
          ),
          onPressed: onTap,
        ),
        if (itemCount > 0 && !showAddedAnimation)
          Positioned(
            right: 2,
            top: 2,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                itemCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
class _FullScreenImageView extends StatelessWidget {
  final dynamic image;

  const _FullScreenImageView({required this.image});

  Widget _errorPlaceholder() => const Center(
        child: Text(
          'Unable to display image',
          style: TextStyle(color: Colors.white),
        ),
      );

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (image is Uint8List) {
      imageWidget = Image.memory(
        image,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _errorPlaceholder(),
      );
    } else if (image is String) {
      imageWidget = Image.network(
        image,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _errorPlaceholder(),
      );
    } else {
      imageWidget = _errorPlaceholder();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      body: Center(child: InteractiveViewer(child: imageWidget)),
    );
  }
}
class ProductCard extends StatelessWidget {
  final Models product;
  final String? selectedColor;
  final ValueChanged<String> onColorSelected;
  final ValueChanged<dynamic> onImageTap;
  final VoidCallback onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.selectedColor,
    required this.onColorSelected,
    required this.onImageTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.webImages != null && product.webImages!.isNotEmpty)
            _ProductImageCarousel(
              images: product.webImages!,
              soldOut: !product.inStock,
              onImageTap: onImageTap,
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: TextStyle(color: Colors.grey.shade700, height: 1.4),
                ),
                const SizedBox(height: 18),
                _StockBadge(quantity: product.stockQuantity),
                const SizedBox(height: 18),
                if (product.colors.isNotEmpty)
                  _ColorPicker(
                    colors: product.colors,
                    selectedColor: selectedColor,
                    onSelected: onColorSelected,
                  ),
                const SizedBox(height: 20),
                _PriceAndAddButton(
                  price: product.price,
                  inStock: product.inStock,
                  onAddToCart: onAddToCart,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class _ProductImageCarousel extends StatefulWidget {
  final List<Uint8List> images;
  final bool soldOut;
  final ValueChanged<dynamic> onImageTap;

  const _ProductImageCarousel({
    required this.images,
    required this.soldOut,
    required this.onImageTap,
  });

  @override
  State<_ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<_ProductImageCarousel> {
  int _currentImage = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 240,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: PageView.builder(
              itemCount: widget.images.length,
              onPageChanged: (index) => setState(() => _currentImage = index),
              itemBuilder: (_, index) {
                final img = widget.images[index];
                return GestureDetector(
                  onTap: () => widget.onImageTap(img),
                  child: Image.memory(
                    img,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (widget.images.length > 1)
          Positioned(
            left: 0,
            right: 0,
            bottom: 12,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${_currentImage + 1}/${widget.images.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        if (widget.soldOut)
          Positioned(
            top: 18,
            left: -40,
            child: Transform.rotate(
              angle: -0.7,
              child: Container(
                width: 180,
                padding: const EdgeInsets.symmetric(vertical: 10),
                color: Colors.red,
                child: const Center(
                  child: Text(
                    "SOLD OUT",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Small green pill showing how many units are left in stock.
class _StockBadge extends StatelessWidget {
  final int quantity;

  const _StockBadge({required this.quantity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.inventory_2, color: kBrandGreen),
          const SizedBox(width: 8),
          Text(
            "Remaining: $quantity",
            style: const TextStyle(fontWeight: FontWeight.bold, color: kBrandGreen),
          ),
        ],
      ),
    );
  }
}

/// Row of selectable color chips for a product.
class _ColorPicker extends StatelessWidget {
  final List<String> colors;
  final String? selectedColor;
  final ValueChanged<String> onSelected;

  const _ColorPicker({
    required this.colors,
    required this.selectedColor,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((color) {
        return ChoiceChip(
          selectedColor: Colors.green.shade200,
          label: Text(color),
          selected: selectedColor == color,
          onSelected: (_) => onSelected(color),
        );
      }).toList(),
    );
  }
}

/// Price on the left, "Add to cart" (or "Sold Out") button on the right.
class _PriceAndAddButton extends StatelessWidget {
  final double price;
  final bool inStock;
  final VoidCallback onAddToCart;

  const _PriceAndAddButton({
    required this.price,
    required this.inStock,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "R${price.toStringAsFixed(2)}",
          style: const TextStyle(color: kBrandGreen, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: kBrandGreen,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: inStock ? onAddToCart : null,
          icon: const Icon(Icons.shopping_cart),
          label: Text(inStock ? "Add" : "Sold Out"),
        ),
      ],
    );
  }
}

/// One row in the cart list: thumbnail, name, color, price, delete button.
class CartItemTile extends StatelessWidget {
  final CartItem item;
  final bool stillAvailable;
  final VoidCallback onRemove;

  const CartItemTile({
    super.key,
    required this.item,
    required this.stillAvailable,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final hasImage = product.webImages != null && product.webImages!.isNotEmpty;

    final statusColor = stillAvailable ? Colors.green : Colors.red;
    final statusText = stillAvailable ? 'Still Available' : 'Sold Out';

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 7),
            color: statusColor,
            child: Text(
              statusText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            minLeadingWidth: 60,
            contentPadding: const EdgeInsets.all(14),
            leading: hasImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      product.webImages!.first,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 48,
                        height: 48,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  )
                : const Icon(Icons.phone_android),
            title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Color: ${item.color}"),
                Text("R${product.price.toStringAsFixed(2)}"),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onRemove,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom bar showing the running total and a "Checkout" button.
class CartSummary extends StatelessWidget {
  final double totalPrice;
  final VoidCallback onCheckout;

  const CartSummary({super.key, required this.totalPrice, required this.onCheckout});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                "R${totalPrice.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kBrandGreen),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kBrandGreen,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              onPressed: onCheckout,
              child: const Text("Checkout", style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}