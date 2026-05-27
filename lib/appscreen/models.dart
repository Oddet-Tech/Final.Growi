import 'dart:typed_data';
class Models {

  // PRODUCT INFORMATION
  final String id;
  final String name;
  final String description;

  // PRICING
  final double price;
  final double? discountPrice;

  // PRODUCT MEDIA
  final List<dynamic>? imagePath;

  // WEB IMAGE SUPPORT
  final List<Uint8List>? webImages;

  // PRODUCT OPTIONS
  final List<String> colors;

  // INVENTORY
  int stockQuantity;
  bool inStock;

  // PRODUCT CATEGORY
  final String category;

  // SHIPPING
  final bool requiresShipping;
  final double shippingFee;

  // PRODUCT STATUS
  final bool isFeatured;
  final bool isApproved;

  // SELLER INFORMATION
  final String sellerId;
  final String sellerName;

  // ANALYTICS
  final int views;
  final int purchases;

  // TIMESTAMPS
  final DateTime createdAt;

  Models({
    required this.id,
    required this.name,
    required this.description,

    required this.price,
    this.discountPrice,

    this.imagePath,
    this.webImages,

    required this.colors,

    required this.stockQuantity,
    required this.inStock,

    required this.category,

    required this.requiresShipping,
    required this.shippingFee,

    required this.isFeatured,
    required this.isApproved,

    required this.sellerId,
    required this.sellerName,

    required this.views,
    required this.purchases,

    required this.createdAt,
  });

  // FIRESTORE SUPPORT
  factory Models.fromMap(Map<String, dynamic> map) {

    return Models(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',

      price: (map['price'] ?? 0).toDouble(),
      discountPrice: map['discountPrice']?.toDouble(),

      imagePath: map['imagePath'],
      webImages: null,

      colors: List<String>.from(map['colors'] ?? []),

      stockQuantity: map['stockQuantity'] ?? 0,
      inStock: map['inStock'] ?? true,

      category: map['category'] ?? '',

      requiresShipping: map['requiresShipping'] ?? true,
      shippingFee: (map['shippingFee'] ?? 0).toDouble(),

      isFeatured: map['isFeatured'] ?? false,
      isApproved: map['isApproved'] ?? false,

      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',

      views: map['views'] ?? 0,
      purchases: map['purchases'] ?? 0,

      createdAt: DateTime.tryParse(
            map['createdAt'] ?? '',
          ) ??
          DateTime.now(),
    );
  }

  // FIRESTORE CONVERSION
  Map<String, dynamic> toMap() {

    return {
      'id': id,
      'name': name,
      'description': description,

      'price': price,
      'discountPrice': discountPrice,

      'imagePath': imagePath,

      'colors': colors,

      'stockQuantity': stockQuantity,
      'inStock': inStock,

      'category': category,

      'requiresShipping': requiresShipping,
      'shippingFee': shippingFee,

      'isFeatured': isFeatured,
      'isApproved': isApproved,

      'sellerId': sellerId,
      'sellerName': sellerName,

      'views': views,
      'purchases': purchases,

      'createdAt': createdAt.toIso8601String(),
    };
  }

  Models copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? discountPrice,
    List<dynamic>? imagePath,
    List<Uint8List>? webImages,
    List<String>? colors,
    int? stockQuantity,
    bool? inStock,
    String? category,
    bool? requiresShipping,
    double? shippingFee,
    bool? isFeatured,
    bool? isApproved,
    String? sellerId,
    String? sellerName,
    int? views,
    int? purchases,
    DateTime? createdAt,
  }) {
    return Models(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      imagePath: imagePath ?? this.imagePath,
      webImages: webImages ?? this.webImages,
      colors: colors ?? this.colors,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      inStock: inStock ?? this.inStock,
      category: category ?? this.category,
      requiresShipping: requiresShipping ?? this.requiresShipping,
      shippingFee: shippingFee ?? this.shippingFee,
      isFeatured: isFeatured ?? this.isFeatured,
      isApproved: isApproved ?? this.isApproved,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      views: views ?? this.views,
      purchases: purchases ?? this.purchases,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// ORDER ITEM MODEL
class OrderItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String color;
  final List<Uint8List>? webImages;
  final String sellerId;
  final String sellerName;

  OrderItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.color,
    this.webImages,
    required this.sellerId,
    required this.sellerName,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      color: map['color'] ?? '',
      webImages: null,
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'color': color,
      'sellerId': sellerId,
      'sellerName': sellerName,
    };
  }

  factory OrderItem.fromModel(Models model, String color) {
    return OrderItem(
      id: model.id,
      name: model.name,
      description: model.description,
      price: model.discountPrice ?? model.price,
      color: color,
      webImages: model.webImages,
      sellerId: model.sellerId,
      sellerName: model.sellerName,
    );
  }
}

// PAYMENT INFO MODEL
class PaymentInfo {
  final String cardHolder;
  final String cardNumber;
  final String expiryDate;
  final String cvv;
  final String? storedCardId;

  PaymentInfo({
    required this.cardHolder,
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
    this.storedCardId,
  });

  factory PaymentInfo.fromMap(Map<String, dynamic> map) {
    return PaymentInfo(
      cardHolder: map['cardHolder'] ?? '',
      cardNumber: map['cardNumber'] ?? '',
      expiryDate: map['expiryDate'] ?? '',
      cvv: map['cvv'] ?? '',
      storedCardId: map['storedCardId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cardHolder': cardHolder,
      'cardNumber': '****${cardNumber.substring(cardNumber.length - 4)}',
      'expiryDate': expiryDate,
      'storedCardId': storedCardId,
    };
  }

  String getMaskedCardNumber() {
    if (cardNumber.length < 4) return cardNumber;
    return '****${cardNumber.substring(cardNumber.length - 4)}';
  }
}

// LOCATION INFO MODEL
class LocationInfo {
  final double latitude;
  final double longitude;
  final String address;
  final String storeName;
  final String storeType; // "PEP" or "POSTNET"

  LocationInfo({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.storeName,
    required this.storeType,
  });

  factory LocationInfo.fromMap(Map<String, dynamic> map) {
    return LocationInfo(
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      address: map['address'] ?? '',
      storeName: map['storeName'] ?? '',
      storeType: map['storeType'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'storeName': storeName,
      'storeType': storeType,
    };
  }
}

// ORDER MODEL
class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double totalAmount;
  final double taxAmount;
  final double finalTotal;
  final PaymentInfo paymentInfo;
  final LocationInfo locationInfo;
  final String status; // 'Pending', 'Shipped', 'Delivered', 'Cancelled'
  final DateTime orderDate;
  final DateTime? shippedDate;
  final DateTime? deliveredDate;
  final String? trackingNumber;
  final String? notes;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.taxAmount,
    required this.finalTotal,
    required this.paymentInfo,
    required this.locationInfo,
    required this.status,
    required this.orderDate,
    this.shippedDate,
    this.deliveredDate,
    this.trackingNumber,
    this.notes,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      taxAmount: (map['taxAmount'] ?? 0).toDouble(),
      finalTotal: (map['finalTotal'] ?? 0).toDouble(),
      paymentInfo: PaymentInfo.fromMap(
          map['paymentInfo'] as Map<String, dynamic>? ?? {}),
      locationInfo: LocationInfo.fromMap(
          map['locationInfo'] as Map<String, dynamic>? ?? {}),
      status: map['status'] ?? 'Pending',
      orderDate: DateTime.tryParse(map['orderDate'] ?? '') ?? DateTime.now(),
      shippedDate: map['shippedDate'] != null
          ? DateTime.tryParse(map['shippedDate'])
          : null,
      deliveredDate: map['deliveredDate'] != null
          ? DateTime.tryParse(map['deliveredDate'])
          : null,
      trackingNumber: map['trackingNumber'],
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'taxAmount': taxAmount,
      'finalTotal': finalTotal,
      'paymentInfo': paymentInfo.toMap(),
      'locationInfo': locationInfo.toMap(),
      'status': status,
      'orderDate': orderDate.toIso8601String(),
      'shippedDate': shippedDate?.toIso8601String(),
      'deliveredDate': deliveredDate?.toIso8601String(),
      'trackingNumber': trackingNumber,
      'notes': notes,
    };
  }

  int get itemCount => items.length;

  String getStatusColor() {
    switch (status) {
      case 'Pending':
        return 'FF9800'; // Orange
      case 'Shipped':
        return '2196F3'; // Blue
      case 'Delivered':
        return '4CAF50'; // Green
      case 'Cancelled':
        return 'F44336'; // Red
      default:
        return '9E9E9E'; // Grey
    }
  }
}
