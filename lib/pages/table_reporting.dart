import 'package:Aturuang/configuration/theme_config.dart';
import 'package:Aturuang/models/laporan_model.dart';
import 'package:flutter/material.dart';
import 'package:Aturuang/configuration/mobile_exporting.dart';
// import 'package:Aturuang/configuration/web_exporting.dart';
import 'package:Aturuang/configuration/roundedbutton.dart';
import 'package:intl/intl.dart';

class ReportingTable extends StatefulWidget {
  List<LaporanKeuanganModel> lapKeuFiltered = [];
  String kategori = '';
  String tipe = '';
  ReportingTable(
      {Key? key,
      required List<LaporanKeuanganModel> lapKeuFiltered,
      required String kategori,
      required String tipe})
      : super(key: key) {
    this.lapKeuFiltered = lapKeuFiltered;
    this.kategori = kategori;
    this.tipe = tipe;
  }

  @override
  _ReportingTableState createState() => _ReportingTableState();
}

class Report {
  String? date;
  String? category;
  String? description;
  double amount;

  Report({
    required this.date,
    required this.category,
    required this.description,
    required this.amount,
  });
}

class _ReportingTableState extends State<ReportingTable> {
  List<Report> reports = [];
  @override
  void initState() {
    super.initState();
    convertDataToReports();
  }

  void convertDataToReports() {
    for (var data in widget.lapKeuFiltered) {
      if (data.kategori == widget.kategori) {
        Report report = Report(
          date: data.tanggal,
          category: data.kategori,
          description: data.deskripsi,
          amount: double.parse(data.nominal),
        );
        reports.add(report);
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: primaryColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Export ${widget.kategori} Reporting",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 29, vertical: 10),
          child: Column(
            children: <Widget>[
              SingleChildScrollView(
                child: DataTable(
                  headingRowColor: WidgetStateColor.resolveWith(
                      (states) => Color.fromARGB(255, 20, 165, 182)),
                  dataRowColor:
                      WidgetStateColor.resolveWith((states) => Colors.white),
                  columns: [
                    DataColumn(
                      label: Text('Date',
                          style: TextStyle(
                            fontFamily: 'Poppins-Regular',
                            color: Colors.white,
                          )),
                      numeric: false,
                    ),
                    DataColumn(
                      label: Text('Description',
                          style: TextStyle(
                            fontFamily: 'Poppins-Regular',
                            color: Colors.white,
                          )),
                      numeric: false,
                    ),
                    DataColumn(
                      label: Text('Amount',
                          style: TextStyle(
                            fontFamily: 'Poppins-Regular',
                            color: Colors.white,
                          )),
                      numeric: false,
                    ),
                  ],
                  rows: [
                    ...reports.reversed.map(
                      (report) => DataRow(cells: [
                        DataCell(Text(
                          report.date != null
                              ? DateFormat('dd/MM/yy')
                                  .format(DateTime.parse(report.date!))
                              : '',
                        )),
                        DataCell(
                          Flexible(
                            child: Text(
                              report.description ?? '',
                            ),
                          ),
                        ),
                        DataCell(
                            Text('${formatCurrency(report.amount.toInt())}')),
                      ]),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 500),
                child: RoundedButton(
                  title: 'Export',
                  onPressed: () async {
                    try {
                      await ExportingPDF.exportToUserSelectedDirectory(reports);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Export PDF successful'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to export PDF'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  width: 336,
                  height: 51,
                  color: primaryColor,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
