import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final String login;
  final String password;
  final String address;
  final String birthday;
  final int postalCode;
  final String city;
  String userId;

  UserData(
    {required this.login, 
    required this.password,
    required this.address,
    required this.birthday, 
    required this.postalCode,
    required this.city,
    required this.userId
    });

  factory UserData.fromDocument(DocumentSnapshot doc) {
    return UserData(
      login: doc['login'],
      password: doc['password'],
      address: doc['address'],
      birthday: doc['birthday'],
      postalCode: doc['postalCode'],
      city: doc['city'],
      userId: doc['userId']
    );
  }
}

// ignore: body_might_complete_normally_nullable
Future<UserData?> getUserData(String uid) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('userId', isEqualTo: uid)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      for (var doc in querySnapshot.docs) {
        return UserData.fromDocument(doc); 
      }
    } else {
      print('Utilisateur non trouvé');
      return null;
    }
  } catch (e) {
    print('Erreur de récupération des données utilisateur: $e');
    return null;
  }
}


