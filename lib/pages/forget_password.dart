import 'package:aturuang/configuration/theme_config.dart';
import 'package:aturuang/configuration/roundedbutton.dart';
import 'package:aturuang/utils/validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const kTextFieldDecoration = InputDecoration(
  filled: true,
  fillColor: Color.fromARGB(242, 242, 242, 242),
  hintText: 'Masukkan Nilai',
  hintStyle: TextStyle(
    color: Colors.grey,
    fontFamily: 'Poppins-Regular',
    fontSize: 12,
  ),
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

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({Key? key}) : super(key: key);
  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final _formKey = GlobalKey<FormState>();
  final _emailTextController = TextEditingController();

  final _focusEmail = FocusNode();

  String _errorText = '';
  bool _isEmailValidated = false;

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _emailTextController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully sent password reset to your email'),
            duration: Duration(seconds: 3),
          ),
        );

        setState(() {
          _isEmailValidated =
              true; // Setelah mengirim email, tandai sebagai sudah divalidasi
        });

        print('Email reset password berhasil terkirim');
        Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
      } catch (e) {
        setState(() {
          _errorText = 'Error reset password. try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: primaryColor,
          ),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context, 'login', (route) => false),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 50, right: 50, top: 100, bottom: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SvgPicture.asset(
              'undraw_forgot_password_re_hxwm.svg',
              width: 250,
              height: 250,
            ),
            const SizedBox(
              height: 5.0,
            ),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Enter a valid Email',
                    style: TextStyle(
                      fontFamily: 'Poppins-Regular',
                      fontSize: 15.0,
                      color: const Color.fromARGB(255, 20, 165, 162),
                    ),
                  ),
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
                      hintText: 'Enter Valid Email',
                    ),
                    onTap: () {
                      setState(() {
                        _errorText = '';
                        _isEmailValidated = false; // Sembunyikan field password
                      });
                    },
                  ),
                  Center(
                    child: RoundedButton(
                      title: 'Reset Password',
                      onPressed: _resetPassword,
                      width: 200.0,
                      height: 50,
                      color: primaryColor,
                    ),
                  ),
                  if (_errorText.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        _errorText,
                        style: TextStyle(
                          color: Colors.red,
                          fontFamily: 'Poppins-Regular',
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
