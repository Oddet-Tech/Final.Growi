class Models {
  final String name;
  final String description;
  final int price;
  final String? imagePath;

  Models({
    required this.name,
    required this.description,
    required this.price,
    this.imagePath,
  });
}