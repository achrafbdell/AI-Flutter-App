// ignore_for_file: unnecessary_null_comparison
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mvp_project/models/vetements.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailPage extends StatelessWidget {
  final Vetement vetement;

  const DetailPage({super.key, required this.vetement});




@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        vetement.title,
        style: const TextStyle(fontSize: 28, fontFamily: 'Noto Sans Mono', fontWeight: FontWeight.w900)
      ),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image dans une carte
          Card(
            elevation: 4, // Ajoute une ombre à la card
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: vetement.image != null
                  ? Image.memory(
                      base64Decode(vetement.image),
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : const Placeholder(fallbackHeight: 250),
            ),
          ),
          const SizedBox(height: 16),
          // Informations du produit dans une card
          Container(
            width: double.infinity, //  card occupe toute la largeur de page
            child: Card(
              elevation: 4, // Ajoute une ombre a  card
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text('Catégorie: ${vetement.categorie}',  
                    style: const TextStyle(fontSize: 15, fontFamily: 'Noto Sans Mono')
                    ),
                    const SizedBox(height: 8),
                    Text('Taille: ${vetement.size}', 
                     style: const TextStyle(fontSize: 15, fontFamily: 'Noto Sans Mono')
                    ),
                    const SizedBox(height: 8),
                    Text('Marque: ${vetement.marque}', 
                    style: const TextStyle(fontSize: 15, fontFamily: 'Noto Sans Mono')
                    ),
                    const SizedBox(height: 45),
                    // Prix 
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 55, 161, 59), // Couleur de fond verte
                          borderRadius: BorderRadius.circular(10), // Bord arrondi
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Espacement interne
                        child: Text(
                          '${vetement.price} MAD',
                          style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold), // Couleur du texte en blanc
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Boutons d'action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Retour'),
              ),
              ElevatedButton(
                onPressed: () {
                  addToCart(context, vetement);
                },
                child: const Text('Ajouter au panier'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}






  void addToCart(BuildContext context, Vetement vetement) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String userId = user.uid;
    FirebaseFirestore.instance.collection('panier').doc(userId).collection('vetement').add({
      'title': vetement.title, // ajouter title dans firestore
      'price': vetement.price, // ajouter price dans firestore
      'size': vetement.size, // ajout size dans firestore
      'categorie': vetement.categorie, // ajout categorie dans firestore
      'marque': vetement.marque, // ajout marque dans firestore
      'image': vetement.image, // ajout image dans firestore
    }).then((_) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Ajouté au panier avec succès', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        ),
      );
      //print('${vetement.title} ajouté au panier');
    }).catchError((error) {
      //print('Erreur lors de l\'ajout au panier: $error');
    });
  }
}