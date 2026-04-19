import 'package:aturuang/models/laporan_model.dart';
import 'package:aturuang/pages/table_reporting.dart';
import 'package:aturuang/utils/restapi.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../configuration/list_configuration.dart';
import '../configuration/theme_config.dart';

class ReportList extends StatefulWidget {
  List<LaporanKeuanganModel> lapKeuFiltered = [];
  String selectedTipe = '';
  String kategori = '';

  @override
  _ReportListState createState() => _ReportListState();
  ReportList(
      {Key? key,
      required List<LaporanKeuanganModel> lapKeuFiltered,
      required String selectedTipe,
      required String kategori})
      : super(key: key) {
    this.lapKeuFiltered = lapKeuFiltered;
    this.selectedTipe = selectedTipe;
    this.kategori = kategori;
  }
}

class _ReportListState extends State<ReportList> {
  int totalIncome = 0;
  int totalSpending = 0;
  int total = 0;
  DataService ds = DataService();
  User? currentUser = FirebaseAuth.instance.currentUser;

  List<String> filterOptions = [
    'All List',
    'Salary',
    'Invest',
    'Daily',
    'Other'
  ];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: primaryColor,
          ),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context, 'reporting', (route) => false),
        ),
        title: Text(
            "${widget.kategori} Reporting ${widget.selectedTipe == 'All' ? '' : '(${widget.selectedTipe})'}",
            style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: ListView.builder(
          itemCount: widget.lapKeuFiltered.length,
          itemBuilder: (context, index) {
            final reversedIndex = widget.lapKeuFiltered.length - 1 - index;
            return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportingTable(
                        lapKeuFiltered: widget.lapKeuFiltered,
                        kategori: widget.lapKeuFiltered[reversedIndex].kategori,
                        tipe: widget.selectedTipe,
                      ),
                    ),
                  );
                },
                child: ListReporting(
                    title: '${widget.lapKeuFiltered[reversedIndex].kategori}',
                    time:
                        '${DateTime.parse(widget.lapKeuFiltered[reversedIndex].tanggal).hour}:${DateTime.parse(widget.lapKeuFiltered[reversedIndex].tanggal).minute}',
                    date:
                        '${DateTime.parse(widget.lapKeuFiltered[reversedIndex].tanggal).day} ${getMonthName(DateTime.parse(widget.lapKeuFiltered[reversedIndex].tanggal).month)} ${DateTime.parse(widget.lapKeuFiltered[reversedIndex].tanggal).year}',
                    nominal:
                        '${formatCurrency(int.parse(widget.lapKeuFiltered[reversedIndex].nominal))}',
                    isIncome:
                        widget.lapKeuFiltered[reversedIndex].tipe_keuangan ==
                            'Income'));
          }),
    );
  }

  // VALUE FILTER
  Widget _buildFilterDropdown() {
    return PopupMenuButton(
      icon: Icon(
        Icons.filter_list,
        color: Colors.black,
      ),
      onSelected: (value) {
        _selectFilterOption(value.toString());
      },
      itemBuilder: (BuildContext context) => filterOptions
          .map((value) => PopupMenuItem(
                value: value,
                child: Row(
                  children: [
                    Text(value),
                  ],
                ),
              ))
          .toList(),
    );
  }

  void _selectFilterOption(String option) {
    setState(() {
      widget.selectedTipe = option;
    });
  }
}
