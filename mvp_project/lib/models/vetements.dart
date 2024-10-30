import 'package:cloud_firestore/cloud_firestore.dart';

class Vetement {
  
  final String imageUrl;
  final String title;
  final String size;
  final double price;
  String categorie;
  String marque;

  Vetement(
    {
      required this.imageUrl, 
      required this.title, 
      required this.size, 
      required this.price,
      required this.categorie,
      required this.marque
    }
  );

  // Convertir un document Firebase en un objet Vetement
  factory Vetement.fromDocument(DocumentSnapshot doc) {
    
    final imageUrl = doc['imageUrl'];
    print('Image URL: $imageUrl');

    return Vetement(
      imageUrl: doc['imageUrl'],
      title: doc['title'],
      size: doc['size'].toString(),
      price: doc['price'].toDouble(),
      categorie: doc['categorie'],
      marque: doc['marque']
    );
  }
}
