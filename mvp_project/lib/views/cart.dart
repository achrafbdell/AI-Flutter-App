import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mvp_project/models/vetements.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mvp_project/widgets/navbar.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';


class PanierPage extends StatefulWidget {
  const PanierPage({super.key});

  @override
  _PanierPageState createState() => _PanierPageState();
}

class _PanierPageState extends State<PanierPage> {
  int _selectedIndex = 1; // 1 pour Panier

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Mon Panier',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 0, 0, 0),
            fontFamily: 'Noto Sans Mono',
          ),
        ),
        backgroundColor: Color.fromARGB(0, 255, 255, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: StreamBuilder<List<Vetement>>(
          stream: fetchPanierItems(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print('Erreur lors du chargement du panier: ${snapshot.error}');
              return Center(
                  child: Text('Erreur lors du chargement du panier.'));
            } else if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            } else {
              final vetements = snapshot.data!;
              if (vetements.isEmpty) {
                return Center(child: Text('Votre panier est vide.'));
              }

              double total = vetements.fold(0, (sum, item) => sum + item.price);

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: vetements.length,
                      itemBuilder: (context, index) {
                        final vetement = vetements[index];
                        return Column(
                          children: [
                            Card(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: Image.memory(
                                      base64Decode(vetement.image),
                                      fit: BoxFit.cover, // Remplit le conteneur
                                    ),
                                  ),
                                ),
                                title: Text(
                                  vetement.title,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                    'Taille: ${vetement.size}, Prix: ${vetement.price} MAD'),
                                trailing: IconButton(
                                  icon: Icon(Icons.close, color: Colors.red),
                                  onPressed: () {
                                    removeItemFromPanier(vetement);
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 16), // Espace entre les articles
                          ],
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 0, 60, 109),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        'Total :  $total MAD',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Merriweather',
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            // Reste sur la page du panier
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
    );
  }

  Stream<List<Vetement>> fetchPanierItems() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value([]); // Return empty cart if no user is logged in
    }

    String userId = user.uid;
    return FirebaseFirestore.instance
        .collection('panier')
        .doc(userId)
        .collection('vetement')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Vetement.fromDocument(doc)).toList();
    });
  }

  void removeItemFromPanier(Vetement vetement) {
    final user =
        FirebaseAuth.instance.currentUser; // Récupérer l'utilisateur connecté
    if (user == null) return; // Si aucun utilisateur connecté, ne rien faire

    String userId = user.uid; // Utiliser l'ID de l'utilisateur connecté
    FirebaseFirestore.instance
        .collection('panier')
        .doc(userId)
        .collection('vetement')
        .where('title', isEqualTo: vetement.title)
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete().then((_) {
          print('${vetement.title} retiré du panier');
        });
      }
    });
  }
}
