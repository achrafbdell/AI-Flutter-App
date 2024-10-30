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
                  'Erreur lors du chargement de la base de donnée Firebase !'));
        } else if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else {
          final vetements = snapshot.data!;
          return ListView.builder(
            itemCount: vetements.length,
            itemBuilder: (context, index) {
              final vetement = vetements[index];
              return ListTile(
                leading: Image.network(
                  vetement.imageUrl,
                  width: 80,
                  height: 80,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                        Icons.error); // Show error icon if image fails to load
                  },
                ),
                title: Text(vetement.title),
                subtitle: Text(
                    'Taille: ${vetement.size}, Prix: ${vetement.price} MAD'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPage(vetement: vetement),
                    ),
                  );
                },
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
      'imageUrl': vetement.imageUrl,
      'title': vetement.title,
      'size': vetement.size,
      'price': vetement.price,
      'categorie': vetement.categorie,
      'marque': vetement.marque,
    }).then((value) => print('${vetement.title} ajouté au panier.'));
  }
}
