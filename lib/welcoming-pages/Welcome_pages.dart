import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../configuration/theme_config.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:aturuang/configuration/rounded button.dart';

class onBoardingPage extends StatelessWidget {
  const onBoardingPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: 'WELCOME TO Aturuang',
          body:
              "Aturuang is your go-to solution for efficient and hassle-free financial management.",
          image: SvgPicture.asset(
            'assets/undraw_note_list_re_r4u9.svg',
            height: 600,
          ),
          decoration: buildDecoration(),
        ),
        PageViewModel(
          title: 'Income and Expense',
          body:
              'You can enter your income and expenses with the results of digital recording.',
          image: SvgPicture.asset(
            'assets/undraw_transfer_money_re_6o1h.svg',
            height: 600,
          ),
          decoration: buildDecoration(),
        ),
        PageViewModel(
          title: 'Savings',
          body: 'manage your savings by entering your income over time',
          image: SvgPicture.asset(
            'assets/undraw_vault_re_s4my.svg',
            height: 600,
          ),
          decoration: buildDecoration(),
        ),
        PageViewModel(
          title: 'Goals',
          body:
              'reach your savings target with the progress bar display results',
          image: SvgPicture.asset(
            'assets/undraw_personal_goals_re_iow7.svg',
            height: 600,
          ),
          decoration: buildDecoration(),
        ),
      ],
      next: Icon(
        Icons.navigate_next_outlined,
        size: 50,
        color: const Color.fromARGB(255, 20, 165, 182),
      ),
      done: Text('Done',
          style: TextStyle(
              fontFamily: 'Poppins-SemiBold',
              color: const Color.fromARGB(255, 20, 162, 182),
              fontSize: 30)),
      onDone: () => goToHome(context),
      showSkipButton: true,
      skip: Text(
        'Skip',
        style: TextStyle(
            fontFamily: 'Poppins-SemiBold',
            color: const Color.fromARGB(255, 20, 165, 182),
            fontSize: 30),
      ),
      onSkip: () => goToHome(context),
      dotsDecorator: getDotDecoration(),
      animationDuration: 400,
      globalBackgroundColor: Colors.white,
    );
  }

  DotsDecorator getDotDecoration() => DotsDecorator(
      color: Colors.grey,
      size: Size(10, 10),
      activeColor: const Color.fromARGB(255, 20, 165, 182),
      activeSize: Size(22, 10),
      activeShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ));

  void goToHome(BuildContext context) => Navigator.of(context)
      .pushReplacement(MaterialPageRoute(builder: (_) => WelcomingPage()));

  PageDecoration buildDecoration() => PageDecoration(
      titleTextStyle: TextStyle(
          fontFamily: 'Poppins-Regular',
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: const Color.fromARGB(255, 20, 165, 182)),
      bodyTextStyle: TextStyle(
        fontSize: 22,
      ),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.all(18.0),
      bodyPadding: EdgeInsets.only(bottom: 1.0));
}

class WelcomingPage extends StatefulWidget {
  const WelcomingPage({Key? key}) : super(key: key);

  @override
  State<WelcomingPage> createState() => _HomePageState();
}

class _HomePageState extends State<WelcomingPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Image.asset('assets/Logo_without_text.png', width: 250),
        SizedBox(height: 20),
        Text("Welcome!",
            style: TextStyle(
                fontFamily: 'Poppins-SemiBold',
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        SizedBox(height: 10),
        Text("Start managing your money easily",
            style: TextStyle(
                fontFamily: 'Poppins-Regular',
                fontSize: 15,
                fontWeight: FontWeight.w100,
                color: Colors.white)),
        SizedBox(height: 30),
        RoundedButton(
          colour: primaryColor,
          title: "Sign In",
          onPressed: () {
            Navigator.pushReplacementNamed(context, 'login');
          },
          width: 273,
          height: 57,
        ),
        RoundedButton(
          colour: primaryColor,
          title: "Sign Up",
          onPressed: () {
            Navigator.pushReplacementNamed(context, 'register');
          },
          width: 273,
          height: 57,
        )
      ])),
    );

    // Positioned(bottom: 200, child: Image.asset('assets/Ellipse3.png'))
  }
}
