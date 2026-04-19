import 'dart:convert';

import 'package:aturuang/configuration/list_configuration.dart';
import 'package:aturuang/configuration/theme_config.dart';
import 'package:aturuang/models/laporan_model.dart';
import 'package:aturuang/pages/report_list.dart';
import 'package:aturuang/pages/table_reporting.dart';
import 'package:aturuang/utils/restapi.dart';
import 'package:aturuang/configuration/api_configuration.dart';
import 'package:chart_it/chart_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.rectangle,
          ),
        ),
        SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins-Medium',
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class ReportingPage extends StatefulWidget {
  @override
  _ReportingPageState createState() => _ReportingPageState();
  List<bool> isSelected = [true, false, false];
  List<String> buttonLabels = ['All', 'Income', 'Spending'];
  String selectedOption = 'All';
  String selectedCategory = 'All';
  ReportingPage({Key? key}) : super(key: key);
}

class _ReportingPageState extends State<ReportingPage> {
  int totalIncome = 0;
  int totalSpending = 0;
  int total = 0;
  List<LaporanKeuanganModel> lapKeu = [];
  List<String> availableCategories = ['All', 'Salary', 'Invest', 'Daily'];
  List<String> getOtherCategories() {
    List<String> otherCategories = [];
    for (LaporanKeuanganModel keuangan in lapKeu) {
      if (!availableCategories.contains(keuangan.kategori)) {
        otherCategories.add(keuangan.kategori);
      }
    }
    return otherCategories.toSet().toList(); // Menghapus duplikat jika ada
  }

  List<String> getDropdownCategories() {
    List<String> dropdownCategories = [...availableCategories];
    dropdownCategories.addAll(getOtherCategories());
    return dropdownCategories;
  }

  DataService ds = DataService();
  User? currentUser = FirebaseAuth.instance.currentUser;

  List<LaporanKeuanganModel> filteredLapKeu() {
    if (widget.selectedOption == 'All' && widget.selectedCategory == 'All') {
      return lapKeu;
    } else if (widget.selectedOption == 'All') {
      return lapKeu
          .where((keuangan) => keuangan.kategori == widget.selectedCategory)
          .toList();
    } else {
      return lapKeu
          .where((keuangan) =>
              keuangan.tipe_keuangan == widget.selectedOption &&
              (widget.selectedCategory == 'All' ||
                  keuangan.kategori == widget.selectedCategory))
          .toList();
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
    total = totalIncome + totalSpending;
  }

  String getMonthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return 'Invalid month!';
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

  String selectedFilter = 'Option 1';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<dynamic>(
        future: selectWhereLaporan(),
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
                    physics: NeverScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        Container(
                          child: Stack(
                            children: [
                              Container(
                                height: 500,
                                width: double.infinity,
                                child: Image.asset(
                                  'assets/background.png',
                                  // width: double.infinity,
                                  // height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              AppBar(
                                leadingWidth: 100,
                                leading: IconButton(
                                  icon: Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamedAndRemoveUntil(
                                        context, 'home', (route) => false);
                                  },
                                ),
                                // Warna latar belakang transparan
                                backgroundColor: Colors.transparent,
                                // Atur elevasi ke 0 untuk menghilangkan bayangan AppBar
                                elevation: 0,
                                centerTitle: true,
                                title: Text('Reporting',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Poppins-SemiBold',
                                        fontSize: 20)),
                              ),

                              //Chart Start
                              Center(
                                child: PieChart(
                                  chartStyle: RadialChartStyle(
                                      backgroundColor: Colors.transparent),
                                  animationDuration:
                                      const Duration(milliseconds: 500),
                                  height: 400,
                                  width: 350,
                                  // animateOnUpdate: true,
                                  // animateOnLoad: true,
                                  data: PieSeries(
                                    donutRadius: 70.0,
                                    donutSpaceColor: Colors.transparent,
                                    donutLabel: () =>
                                        '${(totalIncome == 0 || totalSpending == 0) ? "Chart Not Available!" : formatCurrency(total)}',
                                    donutLabelStyle: ChartTextStyle(
                                        textStyle: TextStyle(
                                            fontFamily: 'Poppins-SemiBold',
                                            fontSize: 15,
                                            color: Colors.white)),
                                    slices: <SliceData>[
                                      SliceData(
                                          style: SliceDataStyle(
                                            radius: 100,
                                            color: Color.fromARGB(
                                                255, 38, 243, 169),
                                            labelPosition: 130,
                                            strokeWidth: 0.0,
                                            strokeColor: Colors.white,
                                          ),
                                          label: (_, value) =>
                                              '${formatCurrency(totalIncome)}',
                                          labelStyle: ChartTextStyle(
                                              textStyle: TextStyle(
                                                  fontFamily: 'Poppins-Medium',
                                                  fontSize: 12,
                                                  color: Colors.white)),
                                          value: totalIncome),
                                      SliceData(
                                          style: SliceDataStyle(
                                            radius: 100,
                                            color: Color.fromARGB(
                                                255, 255, 84, 71),
                                            labelPosition: 130,
                                            strokeWidth: 0.0,
                                            strokeColor: Colors.white,
                                          ),
                                          label: (_, value) =>
                                              '${formatCurrency(totalSpending)}',
                                          labelStyle: ChartTextStyle(
                                              textStyle: TextStyle(
                                                  fontFamily: 'Poppins-Medium',
                                                  fontSize: 12,
                                                  color: Colors.white)),
                                          value: totalSpending),
                                    ],
                                  ),
                                ),
                              ),

                              //chart end

//Legend Start
                              Padding(
                                padding: const EdgeInsets.only(top: 400.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    LegendItem(
                                      color: const Color.fromARGB(
                                          255, 38, 243, 169),
                                      label: 'Income',
                                    ),
                                    SizedBox(width: 20),
                                    LegendItem(
                                      color: Color.fromARGB(255, 255, 84, 71),
                                      label: 'Spending',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        //Toggle Button
                        Container(
                          child: Center(
                            child: Card(
                              color: primaryColor,
                              child: ToggleButtons(
                                isSelected: widget.isSelected,
                                onPressed: (index) {
                                  setState(() {
                                    for (int buttonIndex = 0;
                                        buttonIndex < widget.isSelected.length;
                                        buttonIndex++) {
                                      widget.isSelected[buttonIndex] =
                                          buttonIndex == index;
                                    }
                                    widget.selectedOption =
                                        widget.buttonLabels[index];
                                  });
                                },
                                selectedColor: secondaryColor,
                                fillColor: secondaryColor,
                                children: List.generate(
                                  widget.buttonLabels.length,
                                  (index) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 35),
                                    child: Text(
                                      widget.buttonLabels[index],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Poppins-SemiBold',
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // all list
                              // Padding(
                              //   padding:
                              //       const EdgeInsets.only(left: 30, right: 30),
                              //   child: Text(
                              //     '${widget.selectedCategory}',
                              //     style: TextStyle(
                              //         fontFamily: 'Poppins-Medium',
                              //         fontSize: 15,
                              //         color: Colors.black),
                              //   ),
                              // ),
                              // SizedBox(
                              //   height: 6.0,
                              // ),
                            ],
                          ),
                        ),

                        SingleChildScrollView(
                            // sengaja dikasih ini biar kalo banyak ngga overflow
                            child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  DropdownButton<String>(
                                    value: widget.selectedCategory,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        widget.selectedCategory = newValue!;
                                      });
                                    },
                                    items: getDropdownCategories()
                                        .map<DropdownMenuItem<String>>(
                                      (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value,
                                            style: TextStyle(
                                              fontFamily: 'Poppins-SemiBold',
                                              fontSize: 15,
                                              color: Colors.black,
                                            ),
                                          ),
                                        );
                                      },
                                    ).toList(),
                                  ),
                                ],
                              ),
                            ),
                            ListView.builder(
                                shrinkWrap: true,
                                itemCount: filteredLapKeu().length > 3
                                    ? 3
                                    : filteredLapKeu().length < 1
                                        ? 1
                                        : filteredLapKeu().length,
                                itemBuilder: (context, index) {
                                  final reversedIndex =
                                      filteredLapKeu().length - 1 - index;
                                  return filteredLapKeu().isNotEmpty
                                      ? GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ReportingTable(
                                                  lapKeuFiltered:
                                                      filteredLapKeu(),
                                                  kategori: filteredLapKeu()[
                                                          reversedIndex]
                                                      .kategori,
                                                  tipe: filteredLapKeu()[
                                                          reversedIndex]
                                                      .tipe_keuangan,
                                                ),
                                              ),
                                            );
                                          },
                                          child: ListReporting(
                                            title:
                                                '${filteredLapKeu()[reversedIndex].kategori}',
                                            time:
                                                '${DateTime.parse(filteredLapKeu()[reversedIndex].tanggal).hour}:${DateTime.parse(filteredLapKeu()[reversedIndex].tanggal).minute}',
                                            date:
                                                '${DateTime.parse(filteredLapKeu()[reversedIndex].tanggal).day} ${getMonthName(DateTime.parse(filteredLapKeu()[reversedIndex].tanggal).month)} ${DateTime.parse(filteredLapKeu()[reversedIndex].tanggal).year}',
                                            nominal:
                                                '${formatCurrency(int.parse(filteredLapKeu()[reversedIndex].nominal))}',
                                            isIncome:
                                                filteredLapKeu()[reversedIndex]
                                                        .tipe_keuangan ==
                                                    "Income",
                                          ),
                                        )
                                      : Padding(
                                          padding: EdgeInsets.only(top: 70.0),
                                          child: Center(
                                            child: Text("Data tidak tersedia"),
                                          ),
                                        );
                                }),
                          ],
                        )),
                        SizedBox(height: 9),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReportList(
                                    lapKeuFiltered:
                                        filteredLapKeu(), // nilai dari lapKeu
                                    selectedTipe: widget
                                        .selectedOption, // nilai dari selectedOption
                                    kategori: widget.selectedCategory,
                                  ),
                                ),
                              );
                            },
                            child: filteredLapKeu().isNotEmpty
                                ? Text(
                                    "See More",
                                    style: TextStyle(
                                      fontFamily: 'Poppins-Reguler',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: primaryColor,
                                      decoration: TextDecoration.underline,
                                    ),
                                  )
                                : SizedBox(width: 0, height: 0),
                          ),
                        )
                      ],
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
