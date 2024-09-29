import 'package:fitness_planner/pages/addfitnessplan_page.dart';
import 'package:fitness_planner/pages/Userinfo_page.dart';
import 'package:fitness_planner/services/widgets/CommonWidgets.dart';
import 'package:fitness_planner/services/InfoUserService.dart';
import 'package:fitness_planner/services/widgets/widget_tree.dart';
import 'package:flutter/material.dart';
import 'package:fitness_planner/services/Auth.dart';
import 'package:fitness_planner/pages/detailfitness_page.dart';
import 'package:fitness_planner/services/fitnessplan.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> fitnessPlanNames = []; 

  CommonWidgets commonWidgets = CommonWidgets();
  bool _isExpanded = false;
  final User? user = Auth().currentUser;
  late Future<double> bmiFuture;

  void initState() {
    super.initState();
    _fetchFitnessPlanNames();
    bmiFuture = InfoUserService(user!.uid).calculateBMI();
  }

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _title() {
    return const Text('Fitness Planner');
  }

  Widget _userUid2() {
    return user != null
        ? FutureBuilder<String?>(
            future: Auth().getUsername(user!.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text(
                  'Welcome...',
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                );
              } else if (snapshot.hasData) {
                return RichText(
                  text: TextSpan(
                    text: 'Welcome ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(
                        text: '${snapshot.data}',
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Text(
                  'Welcome',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                );
              }
            },
          )
        : Text(
            'No User',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          );
  }

  Widget _signOutButton() {
    return ElevatedButton(
      onPressed: () {
        signOut();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const WidgetTree(),
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.logout),
          SizedBox(width: 8),
          Text('Sign Out'),
        ],
      ),
    );
  }

  Future<void> _fetchFitnessPlanNames() async {
    try {
      List<String> names =
          await FitnessPlanService().getFitnessPlanNames(user!.uid);
      setState(() {
        fitnessPlanNames = names;
      });
    } catch (e) {
      print('Error fetching fitness plan names: $e');
    }
  }

  Widget _fitnessPlanList() {
    if (fitnessPlanNames.isEmpty) {
      return Column(
        children: [
          Text('No fitness plans found.'),
          SizedBox(height: 10),
          _buildAddFitnessPlanButton(),
        ],
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExpansionPanelList(
              elevation: 1,
              expandedHeaderPadding: EdgeInsets.all(0),
              expansionCallback: (int index, bool isExpanded) {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              children: [
                ExpansionPanel(
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return ListTile(
                      title: Text(
                        'My Personal Fitness Plans',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                  body: _isExpanded
                      ? Container(
                          height: 200,
                          child: ListView(
                            shrinkWrap: true,
                            children: List.generate(
                              fitnessPlanNames.length,
                              (index) {
                                final fitnessPlanName = fitnessPlanNames[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        '${index + 1}.',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DetailFitness(
                                                fitnessPlanName:
                                                    fitnessPlanName,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                255, 121, 192, 39),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            fitnessPlanName,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
                  isExpanded: _isExpanded,
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAddFitnessPlanButton(),
                _userInfoButton(),
              ],
            ),
          ],
        ),
      );
    }
  }

  Widget _userInfoButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UserInfoPage(),
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.smart_button),
          SizedBox(width: 8),
          Text('Smart Planner'),
        ],
      ),
    );
  }

  Widget _buildAddFitnessPlanButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 6.0),
      child: ElevatedButton(
        onPressed: () async {
          List<String>? result = await Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AddFitnessPlan(userId: user!.uid),
            ),
          );

          if (result != null) {
            try {
              List<String> updatedFitnessPlans =
                  await FitnessPlanService().addFitnessPlan(
                user!.uid,
                result
                    .first, 
              );

              setState(() {
                fitnessPlanNames = updatedFitnessPlans;
              });

              print('Fitness plan added successfully.');
            } catch (e) {
              print('Error adding fitness plan: $e');
            }
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.dashboard_customize),
            SizedBox(width: 8),
            Text('Custom Planner'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
        actions: [
          _signOutButton(),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _userUid2(), 
              Image.asset('images/GymFood.png', height: 150, width: 150),
              _fitnessPlanList(), 
              SizedBox(height: 80),
              FutureBuilder<double>(
                future: bmiFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Container(
                      color: Colors.lightGreenAccent,
                      height: 220,
                      width: 220,
                      child: CommonWidgets.BmiGaugeSyncFusion(
                          bmi: snapshot
                              .data!), 
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
