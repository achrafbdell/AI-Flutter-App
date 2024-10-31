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
                'Erreur lors du chargement de la base de données Firebase !'),
          );
        } else if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else {
          final vetements = snapshot.data!;
          return Padding(
            padding: EdgeInsets.only(top: 0.0), // Espacement en haut
            child: ListView.builder(
              itemCount: vetements.length,
              itemBuilder: (context, index) {
                final vetement = vetements[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetailPage(vetement: vetement),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.all(16), // Padding interne
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  //color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Colors.grey.withOpacity(0.1)),
                                ),
                                child: vetement
                                    .decodeImage(), // Méthode pour afficher l'image
                              ),
                            ),
                            SizedBox(width: 15),
                            // Informations du vêtement
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vetement.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 19,
                                      fontFamily: 'Noto Sans Mono',
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Taille : ${vetement.size}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal:
                                            12), // Padding interne du conteneur
                                    decoration: BoxDecoration(
                                      color: Colors
                                          .green[700], // Couleur de fond verte
                                      borderRadius: BorderRadius.circular(
                                          10), // Border radius
                                    ),
                                    child: Text(
                                      '${vetement.price} MAD',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white, // Couleur du texte
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}
