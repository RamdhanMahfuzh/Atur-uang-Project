import 'package:Aturuang/utils/restapi.dart';
import 'package:Aturuang/utils/restapi.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Aturuang/configuration/api_configuration.dart';
import 'package:Aturuang/configuration/theme_config.dart';
import 'package:Aturuang/configuration/rounded button.dart';
//text
const kTextFieldDecoration = InputDecoration(
  filled: true,
  fillColor: Color.fromARGB(242, 242, 242, 242),
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

class CountingScreen extends StatefulWidget {
  @override
  _CountingScreenState createState() => _CountingScreenState();
  List<bool> isSelected = [false, true];
  List<String> buttonLabels = ['Income', 'Spending'];
  String selectedOption = 'Spending';

  CountingScreen({super.key});
}

class _CountingScreenState extends State<CountingScreen> {
  DataService ds = DataService();
  DateTime now = DateTime.now();
  User? currentUser = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();
  }

  final _financialcategoryTextController = TextEditingController();
  final _AmountTextController = TextEditingController();
  final _descriptionTextController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _focusfinancial = FocusNode();
  final _focusamount = FocusNode();
  final _focusdescription = FocusNode();

  List<String> financialCategory = ['Salary', 'Invest', 'Daily', 'Custom'];
  String? selectedFinancialCategory;

  bool isCustomCategory = false;

  static String? isNotEmptyValidate(
      {required String? value, required String? field}) {
    if (value == null) {
      return null;
    }

    if (value.isEmpty) {
      return '${field} is required!';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: primaryColor,
            size: 25,
          ),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context, 'home', (route) => false),
        ),
        title: Text(
          "Counting Page",
          style: TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontFamily: 'Poppins-SemiBold'),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 40,
            ),
            Container(
                height: 40,
                child: Card(
                    color: primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0)),
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
                              widget.isSelected[0] ? 'Income' : 'Spending';
                        });
                      },
                      selectedColor: secondaryColor,
                      fillColor: secondaryColor,
                      children: List.generate(
                        widget.buttonLabels.length,
                        (index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35),
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
                    ))),
            SizedBox(
              height: 23,
            ),
            Container(),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 8.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, right: 29, left: 29),
                    child: DropdownButtonFormField<String>(
                      decoration: kTextFieldDecoration.copyWith(
                        hintText: 'Financial Category',
                      ),
                      initialValue: selectedFinancialCategory,
                      validator: (value) =>
                          value == null ? 'Select a financial category!' : null,
                      items: [
                        ...financialCategory.map((Category) {
                          return DropdownMenuItem<String>(
                            value: Category,
                            child: Text(Category),
                          );
                        }),
                        if (isCustomCategory &&
                            _financialcategoryTextController.text.isNotEmpty)
                          DropdownMenuItem<String>(
                            value: _financialcategoryTextController.text,
                            child: Text(_financialcategoryTextController.text),
                          )
                      ],
                      onChanged: (value) {
                        setState(
                          () {
                            selectedFinancialCategory = value;
                            if (value == 'Custom') {
                              _showCustomCategoryDialog();
                            }
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, right: 29, left: 29),
                    child: TextFormField(
                      controller: _AmountTextController,
                      focusNode: _focusamount,
                      keyboardType: TextInputType.number,
                      decoration: kTextFieldDecoration.copyWith(
                        hintText: 'Amount',
                      ),
                      validator: (value) =>
                          isNotEmptyValidate(value: value, field: "Amount"),
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Padding(
                      padding:
                          const EdgeInsets.only(top: 8, right: 29, left: 29),
                      child: TextFormField(
                        controller: _descriptionTextController,
                        focusNode: _focusdescription,
                        keyboardType: TextInputType.multiline,
                        minLines: 4,
                        maxLines: 6,
                        decoration: kTextFieldDecoration.copyWith(
                          hintText: 'Description(Optional)',
                        ),
                      )),
                  SizedBox(
                    height: 10.0,
                  ),
                ],
              ),
            ),
            RoundedButton(
              colour: primaryColor,
              title: "Save",
              onPressed: () async {
                _focusamount.unfocus();
                _focusdescription.unfocus();
                _focusfinancial.unfocus();

                if (_formKey.currentState?.validate() ?? false) {
                  await ds.insertLaporanKeuangan(
                      appid,
                      selectedFinancialCategory!,
                      now.toString(),
                      widget.selectedOption,
                      _AmountTextController.text,
                      _descriptionTextController.text,
                      currentUser!.uid);
                  Navigator.pushNamedAndRemoveUntil(
                      context, 'home', (route) => false);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Complete all data!'),
                    ),
                  );
                }
              },
              width: 150.0,
              height: 50.0,
            )
          ],
        ),
      ),
    );
  }

  void _showCustomCategoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Custom Financial Category'),
          content: TextField(
            controller: _financialcategoryTextController,
            decoration: kTextFieldDecoration.copyWith(
              hintText: 'Enter custom category',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  String newCategory = _financialcategoryTextController.text;
                  financialCategory.insert(
                      financialCategory.length - 1, newCategory);
                  selectedFinancialCategory = newCategory;
                });
                Navigator.pop(context);
              },
              child: Text('Add to Dropdown'),
            ),
          ],
        );
      },
    );
  }
}
