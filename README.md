# 👕 MVP Vente de Vêtements

L'objectif de cette application est de créer un MVP (Produit Minimum Viable) de vente de vêtements. Elle comprendra une page de login sécurisée via Firebase, une liste de vêtements, des détails pour chaque article, un panier pour gérer les sélections et un profil utilisateur. Les utilisateurs pourront également ajouter de nouveaux vêtements avec une fonctionnalité d'IA intégrée via TFLite pour détecter automatiquement la catégorie lors de l'importation d'image.

# 📱 Fonctionnalités :

🔑 Page de Login : Connexion via Firebase.

<img width="386" alt="Capture d’écran 2024-11-04 à 01 39 59" src="https://github.com/user-attachments/assets/65155ddd-40dd-426b-aa1b-a07f75442816"> <br>

👗 Liste des Vêtements : Affichage de la liste de vêtements disponibles à l'achat.

<img width="386" alt="Capture d’écran 2024-11-04 à 01 42 52" src="https://github.com/user-attachments/assets/e7b857d9-0dba-4051-addd-d575b41ec30c"> <br>

🛒 Panier : Gestion des articles sélectionnés avant l'achat.

<img width="386" alt="Capture d’écran 2024-11-04 à 00 54 44" src="https://github.com/user-attachments/assets/7243d193-2dd1-4c9f-9d61-b9f679ac8491"> <br>

👤 Profil Utilisateur : Accès et modification des informations personnelles.

<img width="386" alt="Capture d’écran 2024-11-04 à 01 43 38" src="https://github.com/user-attachments/assets/e3ab159c-b151-4fa4-ab27-0bb98871827e"> <br>

➕ Ajout de Vêtement : Ajout d'un nouveau vêtement.

<img width="386" alt="Capture d’écran 2024-11-04 à 01 44 45" src="https://github.com/user-attachments/assets/b6900330-59bc-401f-8777-15774d677bd2"> <br>

🤖 Détection de Catégorie : Utilisation de l'IA avec TFLite pour identifier automatiquement la catégorie du vêtement lors de l'importation de l'image.

# 👤 Utilisateurs :

--> Utilisateur 1: <br>
Login: emsi@gmail.com <br>
Password: mvp123456 <br>

--> Utilisateur 2: <br>
Login: test@gmail.com <br>
Password: test12345 <br>

# Informations :

Le modèle d'IA a été entraîné avec Teachable Machine, ce qui m'a permis de générer les fichiers model_unquant.tflite et labels.txt, que j'ai ensuite intégrés dans mon projet dans le dossier assets. J'ai utilisé la dernière version de TFLite, mais j'ai rencontré l'erreur suivante : MissingPluginException(No implementation found for method loadModel on channel tflite). Malgré mes tentatives pour configurer les fichiers de configuration d'Android et d'essayer d'autres versions de TFLite, comme la 1.0.4, l'erreur persiste toujours. Cependant, je suis déterminé à continuer mes recherches jusqu'à ce que cette fonctionnalité soit résolue.
