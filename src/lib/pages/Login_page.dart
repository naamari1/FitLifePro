import 'package:fitness_planner/pages/Register_page.dart';
import 'package:fitness_planner/services/InputValidator.dart';
import 'package:fitness_planner/services/widgets/widget_tree.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_planner/services/Auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String errorMessage = '';

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> signInWithEmailAndPassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        await Auth().signInWithEmailAndPassword(
          email: _controllerEmail.text,
          password: _controllerPassword.text,
        );

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WidgetTree(), 
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          setState(() {
            if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
              errorMessage = 'Invalid login credentials';
            } else {
              errorMessage = 'Invalid login attempt';
            }
          });
        }
      }
    }
  }

  Widget _title() {
    return const Text('Fitness Planner');
  }

 Widget _entryField(String title, TextEditingController controller,
      String? Function(String?)? validator) {
    return TextFormField(
      controller: controller,
      obscureText: title.toLowerCase() == 'password' ||
          title.toLowerCase() == 'confirm password',
      decoration: InputDecoration(
        labelText: title,
      ),
      validator: validator,
    );
  }

  Widget _errorMessage() {
    return errorMessage.isEmpty
        ? SizedBox.shrink()
        : Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              errorMessage,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          );
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed: signInWithEmailAndPassword,
      child: Text('Login'),
    );
  }

  Widget _loginOrRegisterButton() {
    return TextButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RegisterPage(),
          ),
        );
      },
      child: Text('Register instead'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            color: Colors.lightGreenAccent,
            height: MediaQuery.of(context)
                .size
                .height, 
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Image.asset('images/GymFood.png', height: 250, width: 250),

                _entryField(
                    'email', _controllerEmail, InputValidator.validateEmail),
                _entryField('password', _controllerPassword,
                    InputValidator.validatePassword),
                _submitButton(),
                _loginOrRegisterButton(),
                _errorMessage(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
