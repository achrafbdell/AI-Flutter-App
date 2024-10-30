import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mvp_project/models/vetements.dart';
import '../views/product_detail.dart';

class VetementsList extends StatelessWidget {
  Stream<List<Vetement>> fetchVetements() {
    return FirebaseFirestore.instance
        .collection('vetement')
        .snapshots()
        .map((snapshot) {
      print('Snapshot data: ${snapshot.docs.length} documents fetched');
      return snapshot.docs.map((doc) => Vetement.fromDocument(doc)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Vetement>>(
      stream: fetchVetements(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
          return Center(
              child: Text(
                  'Erreur lors du chargement de la base de données Firebase !'));
        } else if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else {
          final vetements = snapshot.data!;
          return ListView.builder(
            itemCount: vetements.length,
            itemBuilder: (context, index) {
              final vetement = vetements[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                elevation: 4,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(vetement: vetement),
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image carrée du vêtement avec bord arrondi
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: vetement.decodeImage(),
                        ),
                        SizedBox(width: 16),
                        // Informations sur le vêtement
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vetement.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18, // Agrandir le titre
                                ),
                              ),
                              SizedBox(height: 30), // Espacement entre les champs
                              Text(
                                'Taille : ${vetement.size}',
                                style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8), // Espacement entre les champs
                              Text(
                                'Prix : ${vetement.price} MAD',
                                style: TextStyle(fontSize: 14, color: const Color.fromARGB(255, 25, 156, 7),fontWeight: FontWeight.bold ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  void addItemToPanier(Vetement vetement) {
    String userId = 'AAAEEE123'; // Remplacez par l'identifiant de l'utilisateur connecté
    FirebaseFirestore.instance
        .collection('panier')
        .doc(userId)
        .collection('vetement')
        .add({
      'imageUrl': vetement.imageBase64, // Enregistre l'image encodée en base64
      'title': vetement.title,
      'size': vetement.size,
      'price': vetement.price,
      'categorie': vetement.categorie,
      'marque': vetement.marque,
    }).then((value) => print('${vetement.title} ajouté au panier.'));
  }
}
