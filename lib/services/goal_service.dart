import 'package:aimimi/models/goal.dart';
import 'package:aimimi/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoalService {
  final String uid;
  GoalService({this.uid});

  final CollectionReference<Map<String, dynamic>> goalCollection =
      FirebaseFirestore.instance.collection("goals");

  final CollectionReference<Map<String, dynamic>> userCollection =
      FirebaseFirestore.instance.collection("users");

  Stream<List<Goal>> get goals {
    return goalCollection.snapshots().map(
        (QuerySnapshot<Map<String, dynamic>> querySnapshot) =>
            querySnapshot.docs
                .map((DocumentSnapshot<Map<String, dynamic>> goal) => (Goal(
                      title: goal.data()["title"],
                      category: goal.data()["category"],
                      period: goal.data()["period"],
                      frequency: goal.data()["frequency"],
                      timespan: goal.data()["timespan"],
                      publicity: goal.data()["publicity"],
                      description: goal.data()["description"],
                    )))
                .toList());
  }

  List<UserGoal> _createUserGoals(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return snapshot
        .data()["goals"]
        .map<UserGoal>((userGoal) => UserGoal(
              accuracy: userGoal["accuracy"],
              checkIn: userGoal["checkIn"],
              checkInSuccess: userGoal["checkInSuccess"],
              checkedIn: userGoal["checkedIn"],
              dayPassed: 0,
              goalID: "BZh5Rh9WzmxM0fyqKeM4",
              goal: Goal(
                title: userGoal["goal"]["title"],
                category: userGoal["goal"]["category"],
                period: userGoal["goal"]["period"],
                frequency: userGoal["goal"]["frequency"],
                timespan: userGoal["goal"]["timespan"],
                publicity: userGoal["goal"]["publicity"],
                description: userGoal["goal"]["description"],
              ),
            ))
        .toList();
  }

  Stream<List<UserGoal>> get userGoals {
    return userCollection.doc(uid).snapshots().map(_createUserGoals);
  }
}