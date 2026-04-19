import 'package:flutter/material.dart';
import 'package:aturuang/configuration/api_configuration.dart';
import 'package:aturuang/models/laporan_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';

import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

import '../models/user_model.dart';
import '../utils/restapi.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  DataService ds = DataService();
  User? currentUser = FirebaseAuth.instance.currentUser;

  final TextEditingController _usernameController = TextEditingController();
  String profpic = "-";
  String id = "-";
  late ValueNotifier<int> _notifier;

  List<UserModel> user = [];
  List<LaporanKeuanganModel> lapKeu = [];

  int totalIncome = 0;
  int totalSpending = 0;

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();

    if (currentUser == null) {
      Navigator.pushReplacementNamed(context, 'login');
    }
  }

  selectWhereUser() async {
    List data = [];
    data = jsonDecode(await ds.selectWhere(
        token, project, 'user', appid, 'user_id', currentUser!.uid));
    user = data.map((e) => UserModel.fromJson(e)).toList();

    profpic = user[0].foto;
    id = user[0].id.toString();
  }

  selectWhereLaporan() async {
    List data = [];
    data = jsonDecode(await ds.selectWhere(token, project, 'laporan_keuangan',
        appid, 'user_id', currentUser?.uid ?? ''));

    if (data.isNotEmpty) {
      lapKeu = data.map((e) => LaporanKeuanganModel.fromJson(e)).toList();

      List<LaporanKeuanganModel> income = [];
      List<LaporanKeuanganModel> spending = [];

      for (LaporanKeuanganModel keuangan in lapKeu) {
        if (keuangan.tipe_keuangan == "Income") {
          income.add(keuangan);
        } else if (keuangan.tipe_keuangan == "Spending") {
          spending.add(keuangan);
        }
      }

      totalIncome =
          income.fold(0, (sum, keuangan) => sum + int.parse(keuangan.nominal));
      totalSpending = spending.fold(
          0, (sum, keuangan) => sum + int.parse(keuangan.nominal));
    }
  }

  //Info
  Future reloadDataUser(dynamic value) async {
    setState(() {
      selectWhereUser();
    });
  }

  //Profic
  File? image;
  String? imageProfpic;

  Future pickImage(String id) async {
    try {
      var picked = await FilePicker.pickFiles(withData: true);

      if (picked != null) {
        var response = await ds.upload(token, project,
            picked.files.first.bytes!, picked.files.first.extension.toString());

        var file = jsonDecode(response);

        await ds.updateId(
            'foto', file['file_name'], token, project, 'user', appid, id);

        _notifier.value++;
        setState(() {
          profpic = file['file_name'];
        });
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  // Fungsi untuk logout
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, 'login');
    } catch (e) {
      print("Error during sign out: $e");
    }
  }

  //alert sebelum logout
  Future<void> _showLogoutConfirmation(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('Are you sure you want to Log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _signOut();
              },
              child: Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteAccountConfirmation(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(10.0),
          content: Container(
            height: 100,
            child: Column(
              children: [
                Text(
                    'To Confirm, type: "i want to delete ${currentUser?.displayName} account" in the box below'),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: 'Type here'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (currentUser != null) {
                  await currentUser?.reload();
                  await currentUser?.getIdToken(true);

                  if (_usernameController.text ==
                      'i want to delete ${currentUser?.displayName} account') {
                    await _deleteAccount();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Your type not match!'),
                    ));
                    Navigator.pop(context);
                  }
                }
              },
              child: Text('Delete Account'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    try {
      if (currentUser != null) {
        await currentUser?.delete();
        Navigator.pushNamedAndRemoveUntil(context, 'welcome', (route) => false);
      }
    } catch (e) {
      print("Error during delete account: $e");

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  String formatCurrency(int amount) {
    final NumberFormat formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return formatter.format(amount);
  }

  @override
  void initState() {
    _notifier = ValueNotifier<int>(0);
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeFirebase();
    });
  }

  @override
  Widget build(BuildContext) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<dynamic>(
        future: Future.wait<dynamic>([selectWhereUser(), selectWhereLaporan()]),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              {
                return const Text('none');
              }
            case ConnectionState.waiting:
              {
                return const Center(child: CircularProgressIndicator());
              }
            case ConnectionState.active:
              {
                return const Text('Active');
              }
            case ConnectionState.done:
              {
                if (snapshot.hasError) {
                  return Text('${snapshot.error}',
                      style: const TextStyle(color: Colors.red));
                } else {
                  return SingleChildScrollView(
                    child: Expanded(
                      child: Column(
                        children: [
                          Container(
                            height: 250,
                            width: double.infinity,
                            child: Stack(
                                alignment: Alignment.center,
                                // clipBehavior: Clip.none,
                                children: [
                                  Image.asset(
                                    'assets/background.png',
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                      top: 30,
                                      child: Text(
                                        'YOUR PROFILE',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontFamily: 'Poppins-SemiBold'),
                                      )),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 120),
                                    child: GestureDetector(
                                      onTap: () => pickImage(id),
                                      child: SizedBox(
                                        height: 185,
                                        width: 185,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.grey[300],
                                          backgroundImage:
                                              NetworkImage(fileUri + profpic),
                                          child: profpic == '-'
                                              ? Icon(
                                                  color: Colors.grey[500],
                                                  Icons.person,
                                                  size: 70.0,
                                                )
                                              : SizedBox.shrink(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ]),
                          ),
                          //Username
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  child: Center(
                                    child: Text(
                                      currentUser != null
                                          ? currentUser?.displayName ?? ''
                                          : '',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontFamily: 'Poppins-SemiBold'),
                                    ),
                                  ),
                                ),
                                //Email
                                Container(
                                  width: double.infinity,
                                  child: Center(
                                    child: Text(
                                      currentUser != null
                                          ? currentUser?.email ?? ''
                                          : '',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontFamily: 'Poppins-Regular'),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 35,
                                ),
                                // Your Financial
                                Container(
                                  width: double.infinity,
                                  // color: Colors.green,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 16.0,
                                          right: 16.0,
                                        ),
                                        child: Text(
                                          "Your Financial",
                                          style: TextStyle(
                                              fontFamily: 'Poppins-Medium',
                                              fontSize: 16,
                                              color: Colors.black),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 6.0,
                                      ),
                                    ],
                                  ),
                                ),
                                //financial income and outcome card
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 12.0, right: 12.0, bottom: 7.0),
                                  child: Card(
                                    color: Color.fromARGB(255, 20, 165, 182),
                                    child: Padding(
                                      padding: const EdgeInsets.all(7.0),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  child: Card(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6.0),
                                                    ),
                                                    child: Icon(
                                                      Icons
                                                          .arrow_upward_rounded,
                                                      size: 50,
                                                      color: Color.fromARGB(
                                                          255, 38, 243, 169),
                                                    ),
                                                  ),
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                        left: 10,
                                                      ),
                                                      child: Expanded(
                                                        child: Text(
                                                          'Income',
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              fontFamily:
                                                                  'Poppins-Regular',
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                        left: 10,
                                                      ),
                                                      child: Expanded(
                                                        child: Text(
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          formatCurrency(
                                                                  totalIncome)
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              fontFamily:
                                                                  'Poppins-SemiBold',
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                //
                                                SizedBox(
                                                  width: 25,
                                                ),
                                                Container(
                                                  child: Card(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6.0),
                                                    ),
                                                    child: Icon(
                                                      Icons
                                                          .arrow_downward_rounded,
                                                      size: 50,
                                                      color: Color.fromARGB(
                                                          255, 255, 85, 71),
                                                    ),
                                                  ),
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                        left: 10,
                                                      ),
                                                      child: Expanded(
                                                        child: Text(
                                                          'Spending',
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              fontFamily:
                                                                  'Poppins-Regular',
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                        left: 10,
                                                      ),
                                                      child: Expanded(
                                                        child: Text(
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          formatCurrency(
                                                                  totalSpending)
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              fontFamily:
                                                                  'Poppins-SemiBold',
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // three button below
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 50, left: 12, right: 12, bottom: 50),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: Card(
                                          color:
                                              Color.fromARGB(255, 20, 165, 182),
                                          child: ListTile(
                                            onTap: () {
                                              Navigator.pushNamed(
                                                  context, 'goalist');
                                            },
                                            leading: Image.asset(
                                                'assets/Mygoals.png'),
                                            title: Text(
                                              'My Goals',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontFamily: 'Poppins-Medium',
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: Card(
                                          color:
                                              Color.fromARGB(255, 20, 165, 182),
                                          child: ListTile(
                                            onTap: () {
                                              _showDeleteAccountConfirmation(
                                                  context);
                                            },
                                            leading: Image.asset(
                                                'assets/delete account.png'),
                                            title: Text(
                                              'Delete Account',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontFamily: 'Poppins-Medium',
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: Card(
                                          color:
                                              Color.fromARGB(255, 20, 165, 182),
                                          child: ListTile(
                                            onTap: () {
                                              _showLogoutConfirmation(context);
                                            },
                                            leading: Image.asset(
                                                'assets/logout.png'),
                                            title: Text(
                                              'Log Out',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontFamily: 'Poppins-Medium',
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }
              }
          }
        },
      ),
    );
  }
}
