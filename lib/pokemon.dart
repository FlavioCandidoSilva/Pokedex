class PokemonDB {
  int id;
  String name;
  String type;
  String img; // Add the 'img' property to hold the image URL

  PokemonDB({
    this.id,
    this.name,
    this.type,
    this.img, // Initialize the 'img' property in the constructor
  });

  // Create a factory constructor to convert a map to a PokemonDB object
  factory PokemonDB.fromMap(Map<String, dynamic> json) => PokemonDB(
        id: json['id'],
        name: json['name'],
        type: json['type'][
            0], // Assuming the 'type' field is a List, use the first element as the type
        img: json['img'], // Assign the image URL from the 'img' field
      );

  // Create a method to convert the PokemonDB object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'img': img, // Include the 'img' property in the map
    };
  }
}
