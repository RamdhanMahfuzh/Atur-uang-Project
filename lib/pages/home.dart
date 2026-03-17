import 'dart:convert';

import 'package:Aturuang/configuration/list_configuration.dart';
import 'package:Aturuang/configuration/theme_config.dart';
import 'package:Aturuang/configuration/api_configuration.dart';
import 'package:Aturuang/models/laporan_model.dart';
import 'package:Aturuang/models/nabung_model.dart';
import 'package:Aturuang/utils/restapi.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DataService ds = DataService();
  User? currentUser = FirebaseAuth.instance.currentUser;

  String username = '';
  late ValueNotifier<int> _notifier;
  int saving = 0;

  List<NabungModel> nabung = [];
  List<NabungModel> tabungan = [];
  List<LaporanKeuanganModel> lapKeu = [];

  List data = [];

  int totalIncome = 0;
  int totalSpending = 0;

  List<String> idTabungan = [];
  List<String> fotoTabungan = [];
  List<int> target = [];
  List<String> id_goals = [];
  List<String> goals = [];
  List<String> periode = [];
  List<int> collectedArray = [];
  List<int> collected = [];
  bool statusNabung = true;

  @override
  void initState() {
    _notifier = ValueNotifier<int>(0);
    selectWhereNabung();
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeFirebase();
    });
  }

  Future reloadDataTabungan(dynamic value) async {
    setState(() {
      selectWhereNabung();
      idTabungan.clear();
      id_goals.clear();
      goals.clear();
      collected.clear();
      collectedArray.clear();
      target.clear();
      periode.clear();
      fotoTabungan.clear();
    });
  }

  selectWhereNabung() async {
    statusNabung = true;
    List data = [];
    data = jsonDecode(await ds.selectWhere(
        token, project, 'nabung', appid, 'user_id', currentUser!.uid));
    nabung = data.map((e) => NabungModel.fromJson(e)).toList();

    for (NabungModel tabungan in nabung) {
      idTabungan.add(tabungan.id);
      fotoTabungan.add(tabungan.foto);
      goals.add(tabungan.nama);
      id_goals.add(tabungan.id);
      target.add(int.parse(tabungan.target));
      periode.add(tabungan.periode);
      collectedArray = jsonDecode(tabungan.nominal).cast<int>();
      collected.add(collectedArray.fold(
          0, (previousValue, element) => previousValue + element));
    }
    if (nabung.isEmpty) {
      statusNabung = false;
    }
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();

    if (currentUser == null) {
      Navigator.pushReplacementNamed(context, 'login');
    } else {
      setState(() {
        selectWhereNabung();
      });
    }
  }

  selectWhereLaporan() async {
    List data = [];
    data = jsonDecode(await ds.selectWhere(token, project, 'laporan_keuangan',
        appid, 'user_id', currentUser?.uid ?? ''));
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
    totalSpending =
        spending.fold(0, (sum, keuangan) => sum + int.parse(keuangan.nominal));
    saving = totalIncome - totalSpending;
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
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: FutureBuilder<dynamic>(
            future: Future.wait<dynamic>(
                [selectWhereLaporan(), selectWhereNabung()]),
            builder: (context, AsyncSnapshot<dynamic> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  {
                    return const Text('none');
                  }
                case ConnectionState.waiting:
                  {
                    return Padding(
                      padding: const EdgeInsets.only(top: 350),
                      child: const Center(child: CircularProgressIndicator()),
                    );
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
                      return SafeArea(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 39,
                            ),
                            // Heading Area
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 29),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Welcome, ${currentUser!.displayName}",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontFamily: 'Poppins-SemiBold',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 21),
                                  AspectRatio(
                                    aspectRatio: 317 / 155,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Stack(
                                        children: [
                                          Image.asset('assets/moneycard.png'),
                                          Positioned(
                                              top: 90,
                                              left: 27,
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text("Total Cash Flow",
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            fontFamily:
                                                                'Poppins-Reguler',
                                                            color:
                                                                Colors.white)),
                                                    Text(
                                                        formatCurrency(saving)
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            fontFamily:
                                                                'Poppins-Reguler',
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color:
                                                                Colors.white)),
                                                  ]))
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Menu APPS Area
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 30, right: 30, top: 30),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.pushNamed(
                                                    context, 'goals_menu');
                                              },
                                              child: Column(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    child: Container(
                                                      color: primaryColor,
                                                      padding:
                                                          EdgeInsets.all(8),
                                                      child: Image.asset(
                                                        "assets/IconGoals.png",
                                                        height: 35,
                                                        width: 35,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 5),
                                                  Text("Goals"),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 40),
                                        Column(
                                          children: [
                                            GestureDetector(
                                              // Navigation to financial counting
                                              onTap: () {
                                                Navigator
                                                    .pushNamedAndRemoveUntil(
                                                        context,
                                                        'counting',
                                                        (route) => false);
                                              },
                                              child: Column(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    child: Container(
                                                      color: primaryColor,
                                                      padding:
                                                          EdgeInsets.all(8),
                                                      child: Image.asset(
                                                        "assets/IconCounting.png",
                                                        height: 35,
                                                        width: 35,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 5),
                                                  Text("Counting"),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 40),
                                        Column(
                                          children: [
                                            GestureDetector(
                                              // Navigation to reporting
                                              onTap: () {
                                                Navigator.pushReplacementNamed(
                                                    context, 'reporting');
                                              },
                                              child: Column(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    child: Container(
                                                      color: primaryColor,
                                                      padding:
                                                          EdgeInsets.all(8),
                                                      child: Image.asset(
                                                        "assets/IconReporting.png",
                                                        height: 35,
                                                        width: 35,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 5),
                                                  Text("Reporting"),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 29),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: Container(
                                      height: 3,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 24),
                                  // Financial Display Report Area
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: screenWidth * 0.13,
                                          height: screenWidth * 0.13,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                screenWidth * 0.02),
                                            border: Border.all(
                                              width: screenWidth * 0.002,
                                              color: Colors.grey[900]!,
                                            ),
                                            color: cardGrey,
                                          ),
                                          child: Icon(
                                            Icons.arrow_upward_sharp,
                                            size: screenWidth * 0.10,
                                            color: arrowUp,
                                          ),
                                        ),
                                        SizedBox(width: screenWidth * 0.02),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Income",
                                              style: TextStyle(
                                                fontFamily: 'Poppins-Bold',
                                                fontSize: screenWidth * 0.033,
                                                fontWeight: FontWeight.w300,
                                                color: secondaryColor,
                                              ),
                                            ),
                                            SizedBox(
                                                height: screenWidth * 0.02),
                                            //Ambil data INCOME dari API
                                            Text(
                                              formatCurrency(totalIncome)
                                                  .toString(),
                                              style: TextStyle(
                                                fontFamily: 'Poppins-Bold',
                                                fontSize: screenWidth * 0.035,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: screenWidth * 0.10),
                                        Container(
                                          width: screenWidth * 0.13,
                                          height: screenWidth * 0.13,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                screenWidth * 0.02),
                                            border: Border.all(
                                              width: screenWidth * 0.002,
                                              color: Colors.grey[900]!,
                                            ),
                                            color: cardGrey,
                                          ),
                                          child: Icon(
                                            Icons.arrow_downward_sharp,
                                            size: screenWidth * 0.10,
                                            color: Colors.red,
                                          ),
                                        ),
                                        SizedBox(width: screenWidth * 0.02),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Spending",
                                              style: TextStyle(
                                                fontFamily: 'Poppins-Bold',
                                                fontSize: screenWidth * 0.033,
                                                fontWeight: FontWeight.w300,
                                                color: secondaryColor,
                                              ),
                                            ),
                                            SizedBox(
                                                height: screenWidth * 0.02),
                                            // ambil data spending dari API
                                            Text(
                                              formatCurrency(totalSpending)
                                                  .toString(),
                                              style: TextStyle(
                                                fontFamily: 'Poppins-Bold',
                                                fontSize: screenWidth * 0.035,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 50),
                                  // GoalList Area
                                  statusNabung == false
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text("Goals List",
                                                style: TextStyle(
                                                    fontFamily:
                                                        'Poppins-Reguler',
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500,
                                                    color: primaryColor)),
                                            SizedBox(height: 9),
                                            Text(
                                                "You don't have any goals, Go create it!")
                                          ],
                                        )
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // batasi Item countnya 2
                                            Text("Goals List",
                                                style: TextStyle(
                                                    fontFamily:
                                                        'Poppins-Reguler',
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500,
                                                    color: primaryColor)),
                                            SizedBox(height: 9),
                                            ListGoals(
                                                id_goal: id_goals[
                                                    id_goals.length - 1],
                                                goals: goals[goals.length - 1],
                                                collected: collected[
                                                        collected.length - 1]
                                                    .toString(),
                                                target:
                                                    target[target.length - 1]
                                                        .toString(),
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: const Text(
                                                            "Warning"),
                                                        content: Text(
                                                            "Remove ${goals[goals.length - 1]} from your Goals?"),
                                                        actions: <Widget>[
                                                          TextButton(
                                                            child: const Text(
                                                                'Cancel'),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          ),
                                                          TextButton(
                                                            child: const Text(
                                                                'Remove',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .red)),
                                                            onPressed:
                                                                () async {
                                                              bool response =
                                                                  await ds.removeId(
                                                                      token,
                                                                      project,
                                                                      'nabung',
                                                                      appid,
                                                                      '${idTabungan[idTabungan.length - 1]}');

                                                              if (response) {
                                                                Navigator.pop(
                                                                    context,
                                                                    true);
                                                                reloadDataTabungan(
                                                                    true);
                                                              }
                                                            },
                                                          )
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                                imagePath:
                                                    "${fotoTabungan[fotoTabungan.length - 1]}"),
                                            SizedBox(height: 9),
                                            (id_goals.length / 4) >= 2
                                                ? ListGoals(
                                                    id_goal: id_goals[
                                                        id_goals.length - 2],
                                                    goals:
                                                        goals[goals.length - 2],
                                                    collected: collected[
                                                            collected.length -
                                                                2]
                                                        .toString(),
                                                    target: target[
                                                            target.length - 2]
                                                        .toString(),
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        barrierDismissible:
                                                            false,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            title: const Text(
                                                                "Warning"),
                                                            content: Text(
                                                                "Remove ${goals[goals.length - 2]} from your Goals?"),
                                                            actions: <Widget>[
                                                              TextButton(
                                                                child: const Text(
                                                                    'Cancel'),
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                              ),
                                                              TextButton(
                                                                child: const Text(
                                                                    'Remove',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .red)),
                                                                onPressed:
                                                                    () async {
                                                                  bool
                                                                      response =
                                                                      await ds.removeId(
                                                                          token,
                                                                          project,
                                                                          'nabung',
                                                                          appid,
                                                                          '${idTabungan[idTabungan.length - 2]}');

                                                                  if (response) {
                                                                    Navigator.pop(
                                                                        context,
                                                                        true);
                                                                    reloadDataTabungan(
                                                                        true);
                                                                  }
                                                                },
                                                              )
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    },
                                                    imagePath:
                                                        "${fotoTabungan[fotoTabungan.length - 2]}",
                                                  )
                                                : SizedBox(height: 9),

                                            SizedBox(height: 10),

                                            Center(
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.pushNamed(
                                                      context, 'goalist');
                                                },
                                                child: Text(
                                                  "See More",
                                                  style: TextStyle(
                                                    fontFamily:
                                                        'Poppins-Reguler',
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: primaryColor,
                                                    decoration: TextDecoration
                                                        .underline,
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  }
              }
            }),
      ),
    );
  }
}
