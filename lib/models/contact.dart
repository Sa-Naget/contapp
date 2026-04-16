class Contact {
  final int? id;
  final String name;
  final String phone;
  final String? photoPath;

  Contact({this.id, required this.name, required this.phone, this.photoPath});

  // Convert a Contact into a Map (for database storage)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'photoPath': photoPath,
    };
  }

  // Convert a Map back into a Contact object
  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      photoPath: map['photoPath'],
    );
  }
}
