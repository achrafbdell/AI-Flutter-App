import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mvp_project/models/vetements.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailPage extends StatelessWidget {
  final Vetement vetement;

  const DetailPage({super.key, required this.vetement});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(vetement.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(vetement.imageUrl, height: 200),
            const SizedBox(height: 16),
            Text(vetement.title,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Catégorie: ${vetement.categorie}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Taille: ${vetement.size}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Marque: ${vetement.marque}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Prix: ${vetement.price} MAD',
                style: const TextStyle(fontSize: 18, color: Colors.green)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Retour'),
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
    FirebaseFirestore.instance
        .collection('panier')
        .doc(userId)
        .collection('vetement')
        .add({
      'title': vetement.title,
      'price': vetement.price,
      'size': vetement.size,
      'categorie': vetement.categorie,
      'marque': vetement.marque,
      'imageUrl': vetement.imageUrl,
    }).then((_) {
      // Affichez le Snackbar vert en cas de succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Ajouté au panier avec succès',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        ),
      );
      print('${vetement.title} ajouté au panier');
    }).catchError((error) {
      print('Erreur lors de l\'ajout au panier: $error');
    });
  }
}
