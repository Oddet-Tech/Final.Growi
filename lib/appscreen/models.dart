class Models {

  final String name;
  final String description;
  final int price;
  final List<String>? imagePath;
  final List<String> colors;

  Models({
    required this.name,
    required this.description,
    required this.price,
    this.imagePath,
    required this.colors,
  });
}