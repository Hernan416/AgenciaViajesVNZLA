class Place {
  final int id;
  final String name;
  final String description;
  final String address;
  final String thumbnailUrl;
  final double rating;

  Place({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.thumbnailUrl,
    required this.rating,
  });

  factory Place.fromMap(Map<String, dynamic> map) {
    return Place(
      id: map['id'],
      name: map['name'],
      description: map['description'] ?? '',
      address: map['address'] ?? '',
      thumbnailUrl: map['thumbnail_url'] ?? 'https://via.placeholder.com/300',
      rating: (map['rating_average'] ?? 0.0).toDouble(),
    );
  }
}