import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mvp_project/views/cart.dart';
import 'package:mvp_project/views/profile.dart';
import 'package:mvp_project/widgets/product_list.dart';
import 'package:mvp_project/widgets/navbar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 2) {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      Navigator.pushReplacementNamed(context, '/profile', arguments: userId);
    }

    if (index == 1) {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      Navigator.pushReplacementNamed(context, '/panier', arguments: userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.only(top: 20.0),
          child: Text(
              _selectedIndex == 0
                  ? 'Liste des Vetements'
                  : _selectedIndex == 1
                      ? 'Mon Panier'
                      : '',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              )),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      body: _selectedIndex == 0
          ? VetementsList()
          : _selectedIndex == 1
              ? PanierPage()
              : ProfilePage(),
    );
  }
}
