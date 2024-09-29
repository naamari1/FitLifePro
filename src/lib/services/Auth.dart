import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_planner/services/fitnessplan.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> createUserWithoutFitnessPlan({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'username': username,
        'email': email,
      });

      CollectionReference fitnessPlansCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('fitnessplans');

      CollectionReference mealPlansCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('mealplans');

      CollectionReference eventsCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('events'); 

      CollectionReference bodyCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('bodytracker');

      await fitnessPlansCollection.add({'name': 'data'});
      await mealPlansCollection.add({'name': 'data'});
      await eventsCollection.add({'events': []}); 
      await bodyCollection.add({'body': []});

      DocumentReference exercisesDocument =
          await FitnessPlanService().createExerciseCollection();

      DocumentReference foodsDocument =
          await FitnessPlanService().createFoodCollection();

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'foods': foodsDocument,
      });

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'exercises': exercisesDocument,
      });
    } catch (e) {
      print("Error creating user: $e");
    }
  }

  Future<String?> getUsername(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc['username'];
      }
    } catch (e) {
      print("Error fetching username: $e");
    }
    return null;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
