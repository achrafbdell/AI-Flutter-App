import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mvp_project/models/vetements.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mvp_project/widgets/navbar.dart';

class PanierPage extends StatefulWidget {
  @override
  _PanierPageState createState() => _PanierPageState();
}

class _PanierPageState extends State<PanierPage> {
  int _selectedIndex = 1; // 1 pour Panier

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Container(
        padding: const EdgeInsets.only(top: 40.0), // Ajout de padding en haut
        child: Text(
          'Mon Panier',
          style: TextStyle(
            fontWeight: FontWeight.bold, // Rendre le texte en gras
          ),
        ),
      ),
    ),
    body: Padding(
      padding: const EdgeInsets.only(top: 50.0), // Padding en haut du body
      child: StreamBuilder<List<Vetement>>(
        stream: fetchPanierItems(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur lors du chargement du panier.'));
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
                      return ListTile(
                        leading: Image.network(vetement.imageUrl, width: 50, height: 50),
                        title: Text(vetement.title),
                        subtitle: Text('Taille: ${vetement.size}, Prix: ${vetement.price} MAD'),
                        trailing: IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            removeItemFromPanier(vetement); // Supprimer l'article du panier
                          },
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 41, 128, 216),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      'Total :  $total MAD',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Merriweather'),
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
        // Naviguer vers d'autres pages en fonction de l'index
        if (index == 0) {
          Navigator.pushReplacementNamed(context, '/home'); // Remplacez '/acheter' par le nom de votre route d'achat
        } else if (index == 1) {
          // Reste sur la page du panier
        } else if (index == 2) {
          Navigator.pushReplacementNamed(context, '/profile'); // Remplacez '/profile' par le nom de votre route de profil
        }
      },
    ),
  );
}


  Stream<List<Vetement>> fetchPanierItems() {
    final user =
        FirebaseAuth.instance.currentUser; // Récupérer l'utilisateur connecté
    if (user == null) {
      return Stream.value(
          []); // Aucun utilisateur connecté, retourne un panier vide
    }
    String userId = user.uid; // Utiliser l'ID de l'utilisateur connecté
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
