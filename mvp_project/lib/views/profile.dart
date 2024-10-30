import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mvp_project/models/user_data.dart';

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

  @override
  void initState() {
    super.initState();
    _loginController = TextEditingController();
    _passwordController = TextEditingController();
    _birthdayController = TextEditingController();
    _addressController = TextEditingController();
    _postalCodeController = TextEditingController();
    _cityController = TextEditingController();
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

  if (message == 'Profil mis à jour avec succès') {
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
          _showSnackBar('Erreur [firebase_auth]: Cette opération est sensible et nécessite une authentification récente. Veuillez vous reconnecter avant de réessayer cette demande.');
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
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'birthday': _birthdayController.text,
          'password': _passwordController.text,
          'address': _addressController.text,
          'postalCode': int.tryParse(_postalCodeController.text) ?? 0,
          'city': _cityController.text,
        });
        _showSnackBar('Profil mis à jour avec succès');
        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        print('Erreur lors de la mise à jour du profil: $e');
        _showSnackBar('Erreur lors de la mise à jour du profil');
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
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mon Profil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _loginController,
              decoration: InputDecoration(labelText: 'Login'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true, // Masquer le mot de passe
              decoration: InputDecoration(labelText: 'Mot de passe'),
            ),
            TextField(
              controller: _birthdayController,
              decoration: InputDecoration(labelText: 'Anniversaire'),
            ),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Adresse'),
            ),
            TextField(
              controller: _postalCodeController,
              decoration: InputDecoration(labelText: 'Code postal'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _cityController,
              decoration: InputDecoration(labelText: 'Ville'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: Text('Valider'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context, '/login');
              },
              child: Text('Se déconnecter'),
            ),
          ],
        ),
      ),
    );
  }
}