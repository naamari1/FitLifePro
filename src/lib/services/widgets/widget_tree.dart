import 'package:fitness_planner/pages/Progression_page.dart';
import 'package:fitness_planner/services/widgets/Calender_widget.dart';
import 'package:fitness_planner/pages/Meal_page.dart';
import 'package:fitness_planner/pages/Login_page.dart';
import 'package:flutter/material.dart';
import 'package:fitness_planner/services/Auth.dart';
import '../../pages/home_page.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({Key? key}) : super(key: key);

  @override
  _WidgetTreeState createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _buildWithBottomNavBar();
        } else {
          return LoginPage();
        }
      },
    );
  }

  Widget _buildWithBottomNavBar() {
    return Scaffold(
      body: _getBody(_currentIndex),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.green,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(.60),
          selectedFontSize: 20,
          unselectedFontSize: 14,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.food_bank),
              label: 'Meals',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Calendar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.track_changes),
              label: 'Tracker',
            ),
          ],
        ),
      ),
    );
  }

  Widget _getBody(int index) {
    switch (index) {
      case 0:
        return HomePage();
      case 1:
        return MealPage();
      case 2:
        return CalenderWidget();
      case 3:
        return BodyProgressionPage();
      case 4:
        return const Placeholder(
          color: Colors.grey,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
