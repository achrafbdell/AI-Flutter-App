import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Vetement {
  final String image;
  final String title;
  final String size;
  final double price;
  final String categorie;
  final String marque;

  Vetement({
    required this.image,
    required this.title,
    required this.size,
    required this.price,
    required this.categorie,
    required this.marque,
  });

  factory Vetement.fromDocument(DocumentSnapshot doc) {
    final image = doc['image'];
    return Vetement(
      image: image,
      title: doc['title'],
      size: doc['size'].toString(),
      price: doc['price'].toDouble(),
      categorie: doc['categorie'],
      marque: doc['marque'],
    );
  }

  Image decodeImage() {
    Uint8List bytes = base64Decode(image);
    return Image.memory(
      bytes,
      width: 120,
      height: 120,
      fit: BoxFit.cover,
    );
  }
}
