import 'package:aturuang/pages/login.dart';
import 'package:aturuang/configuration/api_configuration.dart';
import 'package:aturuang/configuration/theme_config.dart';
import 'package:aturuang/utils/restapi.dart';
import 'package:aturuang/configuration/roundedbutton.dart';
import 'package:aturuang/utils/validator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aturuang/utils/fire_auth.dart';

const kTextFieldDecoration = InputDecoration(
  filled: true,
  fillColor: Color.fromARGB(242, 242, 242, 242),
  hintText: 'Fill A value',
  hintStyle: TextStyle(
      color: Colors.grey, fontFamily: 'Poppins-Regular', fontSize: 12),
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: UnderlineInputBorder(
    borderSide: BorderSide(color: Colors.black),
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
  ),
  enabledBorder: UnderlineInputBorder(
    borderSide: BorderSide(color: Colors.black),
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide:
        BorderSide(color: Color.fromARGB(255, 20, 165, 182), width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
  ),
);

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  DataService ds = DataService();
  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<FirebaseApp> _initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Navigator.pushReplacementNamed(context, 'home');
    }
    return firebaseApp;
  }

  final _registerFormKey = GlobalKey<FormState>();
  final _usernameTextController = TextEditingController();
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _focusUsername = FocusNode();
  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();
  bool _isProcessing = false;

  bool _isObsecured = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 50, right: 50, top: 15, bottom: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SvgPicture.asset(
              'assets/undraw_my_password_re_ydq7.svg',
              height: 250,
              width: 250,
            ),
            const SizedBox(height: 5.0),
            Form(
                key: _registerFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Username',
                      style: TextStyle(
                          fontFamily: 'Poppins-Regular',
                          fontSize: 15.0,
                          color: primaryColor),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    TextFormField(
                      controller: _usernameTextController,
                      focusNode: _focusUsername,
                      validator: (value) => Validator.validateUsername(
                        username: value,
                      ),
                      keyboardType: TextInputType.text,
                      decoration: kTextFieldDecoration.copyWith(
                          hintText: 'Enter username'),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    const SizedBox(height: 10.0),
                    Text('Email',
                        style: TextStyle(
                            fontFamily: 'Poppins-Regular',
                            fontSize: 15.0,
                            color: const Color.fromARGB(255, 20, 165, 162))),
                    SizedBox(
                      height: 5.0,
                    ),
                    TextFormField(
                      controller: _emailTextController,
                      focusNode: _focusEmail,
                      validator: (value) => Validator.validateEmail(
                        email: value,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      decoration: kTextFieldDecoration.copyWith(
                          hintText: 'Enter your email'),
                    ),
                    const SizedBox(height: 20.0),
                    Text('Password',
                        style: TextStyle(
                            fontFamily: 'Poppins-Regular',
                            fontSize: 15.0,
                            color: const Color.fromARGB(255, 20, 165, 162))),
                    SizedBox(
                      height: 5.0,
                    ),
                    TextFormField(
                      controller: _passwordTextController,
                      focusNode: _focusPassword,
                      obscureText: _isObsecured,
                      onChanged: (value) {
                        setState(() {});
                      },
                      validator: (value) => Validator.validatePassword(
                        password: value,
                        confirmPassword: _passwordTextController.text,
                      ),
                      decoration: kTextFieldDecoration.copyWith(
                        hintText: 'Enter your password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObsecured
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObsecured = !_isObsecured;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 15.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _isProcessing
                          ? [const CircularProgressIndicator()]
                          : [
                              RoundedButton(
                                color: primaryColor,
                                title: 'Sign Up',
                                onPressed: () async {
                                  _focusUsername.unfocus();
                                  _focusEmail.unfocus();
                                  _focusPassword.unfocus();
                                  if (_registerFormKey.currentState!
                                      .validate()) {
                                    setState(() {
                                      _isProcessing = true;
                                    });

                                    try {
                                      User? user = await FireAuth
                                          .registerUsingEmailPassword(
                                        name: _usernameTextController.text,
                                        email: _emailTextController.text,
                                        password: _passwordTextController.text,
                                      );

                                      if (user != null) {
                                        User? currentUser =
                                            FirebaseAuth.instance.currentUser;

                                        await ds.insertUser(
                                            appid, currentUser!.uid, '-');

                                        Navigator.of(context)
                                            .pushAndRemoveUntil(
                                          MaterialPageRoute(
                                            builder: (context) => LoginScreen(),
                                          ),
                                          ModalRoute.withName('/'),
                                        );
                                      }
                                    } on FirebaseAuthException catch (e) {
                                      if (e.code == 'email-already-in-use') {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                "Email Already in Use, Please Use Another Email"),
                                          ),
                                        );
                                      }
                                    } finally {
                                      setState(() {
                                        _isProcessing = false;
                                      });
                                    }
                                  }
                                },
                                width: 200.0,
                                height: 50.0,
                              ),
                            ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Already have an account ?',
                          style: TextStyle(
                              fontFamily: 'Poppins-Regular',
                              fontSize: 12.0,
                              color: Colors.black),
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  Navigator.pushReplacementNamed(
                                      context, 'login');
                                });
                              },
                              child: Text(
                                "Sign In",
                                style: TextStyle(
                                    fontFamily: 'Poppins-Regular',
                                    fontSize: 12.0,
                                    color: primaryColor),
                              ),
                            )),
                      ],
                    )
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
