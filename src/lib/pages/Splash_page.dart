import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fitness_planner/services/widgets/widget_tree.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 20),
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 10 * 2 * 3.14159, 
    ).animate(
      CurvedAnimation(
        parent: _rotationController,
        curve: Curves.easeInOut, 
      ),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_fadeController);

    _rotationController.repeat();

    Timer(Duration(seconds: 4), () {
      _rotationController.stop();
      _fadeController.forward();
      _navigateToWidgetTree();
    });
  }

  void _navigateToWidgetTree() {
    Timer(Duration(seconds: 3), () {
      _fadeController.reverse();
      _navigateToWidgetTreeDelayed();
    });
  }

  void _navigateToWidgetTreeDelayed() {
    Timer(Duration(seconds: 1), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => WidgetTree(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'Welcome to FitLifePro',
                style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 26, 94, 29)),
              ),
            ),
            SizedBox(height: 16),
            RotationTransition(
              turns: _rotationAnimation,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        'images/GymFood.png'), 
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }
}
