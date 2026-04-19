import 'package:aturuang/configuration/theme_config.dart';
import 'package:aturuang/configuration/api_configuration.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ListReporting extends StatelessWidget {
  final String title;
  final String time;
  final String date;
  final String nominal;
  final bool isIncome;

  ListReporting({
    required this.title,
    required this.time,
    required this.date,
    required this.nominal,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 16, left: 16, top: 8, bottom: 8),
      child: ClipRect(
        child: Container(
          child: ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            tileColor: primaryColor,
            dense: true,
            leading: InkWell(
              onTap: () {},
              child: Icon(
                // Tampilkan ikon panah sesuai dengan jenis transaksi
                isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                color: isIncome ? arrowUp : arrowDown,
                size: 30,
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'Poppins-SemiBold',
                      color: Colors.white),
                ),
                SizedBox(
                  height: 3,
                ),
                Row(
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                          fontSize: 10,
                          fontFamily: 'Poppins-Bold',
                          color: Colors.black),
                    ),
                    SizedBox(
                      width: 6,
                    ),
                    Text(
                      date,
                      style: TextStyle(
                          fontSize: 10,
                          fontFamily: 'Poppins-Regular',
                          color: Colors.black),
                    )
                  ],
                )
              ],
            ),
            trailing: Text(
              nominal,
              style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Poppins-SemiBold',
                  color: Colors.white),
            ),
          ),
        ),
      ),
    );
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

class ListGoals extends StatelessWidget {
  final String id_goal;
  final String goals;
  final String collected;
  final String target;
  final String imagePath;
  final VoidCallback onPressed;

  ListGoals({
    required this.id_goal,
    required this.goals,
    required this.collected,
    required this.target,
    required this.onPressed,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, 'goals_detail', arguments: [id_goal]);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: border,
            width: 2.0,
          ),
        ),
        child: ListTile(
          dense: true,
          leading: Container(
            width: 57,
            height: 39,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(fileUri + imagePath),
              ),
            ),
          ),
          tileColor: primaryColor,
          title: Text(
            goals,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins-Bold',
              color: Colors.white,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Collected : ${formatCurrency(int.parse(collected))}",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w100,
                  fontFamily: 'Poppins-Reguler',
                  color: Colors.white,
                ),
              ),
              Text(
                "Target : ${formatCurrency(int.parse(target))}",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w100,
                  fontFamily: 'Poppins-Reguler',
                  color: Colors.white,
                ),
              ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete_sharp, color: Colors.white),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}
