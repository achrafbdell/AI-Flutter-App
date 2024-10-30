import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Vetement {
  final String imageBase64;
  final String title;
  final String size;
  final double price;
  final String categorie;
  final String marque;

  Vetement({
    required this.imageBase64,
    required this.title,
    required this.size,
    required this.price,
    required this.categorie,
    required this.marque,
  });

  String get imageUrl => imageBase64;

  factory Vetement.fromDocument(DocumentSnapshot doc) {
    final imageBase64 = doc['imageUrl'];
    return Vetement(
      imageBase64: imageBase64,
      title: doc['title'],
      size: doc['size'].toString(),
      price: doc['price'].toDouble(),
      categorie: doc['categorie'],
      marque: doc['marque'],
    );
  }

  Image decodeImage() {
    Uint8List bytes = base64Decode(imageBase64);
    return Image.memory(
      bytes,
      width: 120,
      height: 120,
      fit: BoxFit.cover,
    );
  }
}
