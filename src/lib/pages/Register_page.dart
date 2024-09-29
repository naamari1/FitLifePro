import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_planner/services/Auth.dart';
import 'package:fitness_planner/pages/Login_page.dart';
import 'package:fitness_planner/pages/Userinfo_page.dart';
import 'package:fitness_planner/services/InputValidator.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String errorMessage = '';
  bool isLoading = false; 

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerConfirmPassword =
      TextEditingController(); 
  final TextEditingController _controllerUserName = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> createUserWithoutFitnessPlan() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true; 
      });

      try {
        await Auth().createUserWithoutFitnessPlan(
          email: _controllerEmail.text,
          password: _controllerPassword.text,
          username: _controllerUserName.text,
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => UserInfoPage(),
          ),
        );
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          setState(() {
            errorMessage = e.message.toString();
          });
        }
      } finally {
        setState(() {
          isLoading = false;
        });
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
      onPressed: isLoading ? null : createUserWithoutFitnessPlan,
      child: isLoading
          ? CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
          : Text('Register'),
    );
  }

  Widget _loginOrRegisterButton() {
    return TextButton(
      onPressed: isLoading
          ? null
          : () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              );
            },
      child: Text('Login instead'),
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
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Image.asset('images/GymFood.png', height: 250, width: 250),
                _entryField(
                    'email', _controllerEmail, InputValidator.validateEmail),
                _entryField('password', _controllerPassword,
                    InputValidator.validatePassword),
                _entryField('confirm password', _controllerConfirmPassword,
                    (value) {
                  if (value != _controllerPassword.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                }),
                _entryField('username', _controllerUserName,
                    InputValidator.validateUsername),
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
