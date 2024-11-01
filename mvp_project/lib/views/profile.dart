import 'dart:convert';
import 'dart:io';
import 'dart:typed_data'; // Import this for Uint8List
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mvp_project/models/user_data.dart';
import 'package:mvp_project/widgets/navbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _loginController;
  late TextEditingController _passwordController;
  late TextEditingController _birthdayController;
  late TextEditingController _addressController;
  late TextEditingController _postalCodeController;
  late TextEditingController _cityController;

  late TextEditingController _imageUrlController;
  late TextEditingController _titleController;
  late TextEditingController _sizeController;
  late TextEditingController _priceController;
  late TextEditingController _categorieController;
  late TextEditingController _marqueController;

  bool _isHovered = false; // Ajout de la variable d'état pour le hover
  final int _selectedIndex = 2; // 2 pour le profil par défaut

  String _base64Image = '';

  @override
  void initState() {
    super.initState();
    _loginController = TextEditingController();
    _passwordController = TextEditingController();
    _birthdayController = TextEditingController();
    _addressController = TextEditingController();
    _postalCodeController = TextEditingController();
    _cityController = TextEditingController();

    // Initialisez les contrôleurs pour le vêtement
    _imageUrlController = TextEditingController();
    _titleController = TextEditingController();
    _sizeController = TextEditingController();
    _priceController = TextEditingController();
    _categorieController = TextEditingController();
    _marqueController = TextEditingController();

    _fetchUserData();
  }

  void _fetchUserData() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    print('User ID: $userId');

    if (userId.isNotEmpty) {
      UserData? userData = await getUserData(userId);
      if (userData != null) {
        if (mounted) {
          _loginController.text = userData.login; // email
          _passwordController.text = userData.password;
          _birthdayController.text = userData.birthday;
          _addressController.text = userData.address;
          _postalCodeController.text = userData.postalCode.toString();
          _cityController.text = userData.city;
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Aucun utilisateur trouvé')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Utilisateur non connecté')),
        );
      }
    }
  }

  void _showSnackBar(String message) {
    Color backgroundColor = Colors.red;

    if (message == 'Profile mis à jour avec succès' ||
        message == 'Vêtement ajouté avec succès') {
      backgroundColor = Colors.green;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Center(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<bool> _updatePassword() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final newPassword = _passwordController.text;

      if (newPassword.length < 6) {
        _showSnackBar('Le mot de passe doit contenir au moins 6 caractères');
        return false;
      }

      try {
        await user.updatePassword(newPassword);
        //_showSnackBar('Mot de passe mis à jour avec succès');
        return true;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          _showSnackBar(
              'Erreur [firebase_auth]: Cette opération est sensible et nécessite une authentification récente. Veuillez vous reconnecter avant de réessayer cette demande.');
          await FirebaseAuth.instance.signOut();
        } else {
          print('Erreur lors de la mise à jour du mot de passe: $e');
          _showSnackBar('Erreur lors de la mise à jour du mot de passe');
        }
        return false;
      }
    }
    return false;
  }

  Future<void> _saveProfile() async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isNotEmpty) {
      bool passwordUpdated = await _updatePassword();

      if (!passwordUpdated) {
        return;
      }

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'birthday': _birthdayController.text,
          'password': _passwordController.text,
          'address': _addressController.text,
          'postalCode': int.tryParse(_postalCodeController.text) ?? 0,
          'city': _cityController.text,
        });
        _showSnackBar('Profile mis à jour avec succès');
        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        print('Erreur lors de la mise à jour du profil: $e');
        _showSnackBar('Erreur lors de la mise à jour du profil');
      }
    }
  }

  Future<void> _addClothing() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('vetement').add({
          'image': _base64Image, // Utiliser l'image encodée en base64
          'title': _titleController.text,
          'size': _sizeController.text,
          'price': double.tryParse(_priceController.text) ?? 0.0,
          'categorie': _categorieController.text,
          'marque': _marqueController.text,
          'userId': userId,
        });
        _showSnackBar('Vêtement ajouté avec succès');
      } catch (e) {
        print('Erreur lors de l\'ajout du vêtement: $e');
        _showSnackBar('Erreur lors de l\'ajout du vêtement');
      }
    }
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    _birthdayController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();

    // Dispose des contrôleurs de vêtement
    _imageUrlController.dispose();
    _titleController.dispose();
    _sizeController.dispose();
    _priceController.dispose();
    _categorieController.dispose();
    _marqueController.dispose();

    super.dispose();
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/panier');
        break;
      case 2:
        // Reste sur la page profil, vous pouvez mettre une autre logique si nécessaire
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 8.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Mon Profil',
              //style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 16.0),
            child: TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context, '/login');
              },
              child: Text(
                'Se déconnecter',
                style: TextStyle(
                    color: const Color.fromARGB(255, 200, 14, 14),
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          // Change Column to ListView
          children: [
            TextField(
              controller: _loginController,
              decoration: InputDecoration(labelText: 'Login'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Mot de passe'),
            ),
            TextField(
              controller: _birthdayController,
              decoration: InputDecoration(labelText: 'Anniversaire'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Adresse'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _postalCodeController,
              decoration: InputDecoration(labelText: 'Code postal'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _cityController,
              decoration: InputDecoration(labelText: 'Ville'),
            ),
            SizedBox(height: 25),
            Center(
              child: SizedBox(
                width: 180,
                height: 50,
                child: MouseRegion(
                  onEnter: (_) {
                    setState(() {
                      _isHovered = true;
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      _isHovered = false;
                    });
                  },
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isHovered
                          ? Colors.white
                          : const Color.fromARGB(255, 25, 137, 230),
                      foregroundColor: _isHovered ? Colors.blue : Colors.white,
                    ),
                    onPressed: _saveProfile,
                    child: Text(
                      'Valider',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddClothingDialog();
        },
        tooltip: 'Ajouter un vêtement',
        backgroundColor: const Color.fromARGB(255, 48, 144, 51),
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  void _showAddClothingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Nouveau vêtement'),
              content: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Afficher l'image sélectionnée
                    _base64Image.isNotEmpty
                        ? Image.memory(
                            base64Decode(_base64Image),
                            height: 150, // Ajustez la hauteur selon vos besoins
                            width: 150, // Ajustez la largeur selon vos besoins
                            fit: BoxFit.cover,
                          )
                        : Text('Aucune image sélectionnée'),

                    ElevatedButton(
                      onPressed: () async {
                        await _pickImage(
                            setState); // Passer setState à _pickImage
                      },
                      child: Text('Choisir une image'),
                    ),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(labelText: 'Titre'),
                    ),
                    TextField(
                      controller: _sizeController,
                      decoration: InputDecoration(labelText: 'Taille'),
                    ),
                    TextField(
                      controller: _priceController,
                      decoration: InputDecoration(labelText: 'Prix'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: _categorieController,
                      decoration: InputDecoration(labelText: 'Catégorie'),
                    ),
                    TextField(
                      controller: _marqueController,
                      decoration: InputDecoration(labelText: 'Marque'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _addClothing();
                    Navigator.of(context)
                        .pop(); // Fermer la boîte de dialogue après l'ajout
                  },
                  child: Text('Ajouter'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(); // Fermer la boîte de dialogue sans ajouter
                  },
                  child: Text('Annuler'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _pickImage(StateSetter setState) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        // Read the picked file as bytes
        final bytes = await pickedFile.readAsBytes();
        // Convert bytes to base64
        setState(() {
          _base64Image = base64Encode(bytes); // Update the base64 image string
        });
      }
    } catch (e) {
      print('Erreur lors de la sélection de l\'image: $e');
    }
  }
}
