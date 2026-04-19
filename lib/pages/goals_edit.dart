import 'dart:convert';
import 'package:aturuang/configuration/api_configuration.dart';
import 'package:aturuang/configuration/roundedbutton.dart';
import 'package:aturuang/configuration/theme_config.dart';
import 'package:aturuang/models/nabung_model.dart';
import 'package:aturuang/utils/restapi.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

class GoalsEdit extends StatefulWidget {
  GoalsEdit({Key? key}) : super(key: key);
  List<bool> isSelected = [false, false, false];
  List<String> buttonLabels = ['Day', 'Week', 'Month'];
  String selectedOption = '-';
  @override
  _GoalsDetail createState() => _GoalsDetail();
}

class _GoalsDetail extends State<GoalsEdit> {
  DateTime now = DateTime.now();
  String profpic = "-";
  DataService ds = DataService();
  User? currentUser = FirebaseAuth.instance.currentUser;
  bool loadData = false;

  List<NabungModel> nabung = [];
  String foto = "-";
  String periode = '-';

  FilePickerResult? picked;

  Future pickImage() async {
    try {
      picked = await FilePicker.pickFiles(withData: true);

      if (picked != null && picked!.files.isNotEmpty) {
        setState(() {
          //refresh UI
        });
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  selectIdGoal(String id) async {
    List data = [];

    data = jsonDecode(await ds.selectId(token, project, 'nabung', appid, id));
    nabung = data.map((e) => NabungModel.fromJson(e)).toList();
    setState(() {
      _goalsTextController.text = nabung[0].nama;
      _targetTextController.text = nabung[0].target;
      foto = nabung[0].foto;
      periode = nabung[0].periode;
      widget.selectedOption = nabung[0].periode;
    });
    if (nabung[0].periode == "Day") {
      widget.isSelected = [true, false, false];
    } else if (nabung[0].periode == "Week") {
      widget.isSelected = [false, true, false];
    } else if (nabung[0].periode == "Month") {
      widget.isSelected = [false, false, true];
    }
  }

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

  final _goalsTextController = TextEditingController();
  final _targetTextController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isAtLeastOneSelected = false;

  final _focusGoals = FocusNode();
  final _focusTarget = FocusNode();

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as List<String>;
    if (loadData == false) {
      selectIdGoal(args[0]);
      loadData = true;
    }
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
          "Update Goals",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 59),
              child: GestureDetector(
                onTap: () => pickImage(),
                child: SizedBox(
                  height: 142,
                  width: 142,
                  child: picked == null
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(fileUri + foto),
                          backgroundColor: Colors.grey[300],
                        )
                      : CircleAvatar(
                          backgroundImage: MemoryImage(
                              picked?.files.first.bytes ?? Uint8List(0)),
                          backgroundColor: Colors.grey[300],
                        ),
                ),
              ),
            ),
            Text(profpic),
            SizedBox(
              height: 35,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 29),
              child: Column(
                children: [
                  Container(
                    height: 40,
                    child: Card(
                      color: primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0)),
                      child: ToggleButtons(
                        isSelected: widget.isSelected,
                        onPressed: (int index) {
                          setState(() {
                            for (int buttonIndex = 0;
                                buttonIndex < widget.isSelected.length;
                                buttonIndex++) {
                              widget.isSelected[buttonIndex] =
                                  widget.isSelected[buttonIndex] = false;
                            }
                            widget.isSelected[index] = true;
                          });
                          isAtLeastOneSelected =
                              widget.isSelected.contains(true);
                          if (widget.isSelected.contains(true)) {
                            widget.selectedOption = widget
                                .buttonLabels[widget.isSelected.indexOf(true)];
                          } else {
                            widget.selectedOption = '';
                          }
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
                      ),
                    ),
                  ),
                  SizedBox(height: 31),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: kTextFieldDecoration.copyWith(
                            hintText: 'Goals name',
                          ),
                          validator: (value) => isNotEmptyValidate(
                              value: value, field: "Goals name"),
                          focusNode: _focusGoals,
                          controller: _goalsTextController,
                        ),
                        SizedBox(height: 31),
                        TextFormField(
                          decoration: kTextFieldDecoration.copyWith(
                            hintText: 'Target',
                          ),
                          focusNode: _focusTarget,
                          controller: _targetTextController,
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              isNotEmptyValidate(value: value, field: 'Target'),
                        ),
                        SizedBox(height: 44),
                        RoundedButton(
                          color: primaryColor,
                          title: 'Update',
                          onPressed: () async {
                            if (picked != null) {
                              var response = await ds.upload(
                                  token,
                                  project,
                                  picked!.files.first.bytes!,
                                  picked!.files.first.extension.toString());
                              var file = jsonDecode(response);
                              foto = file['file_name'];
                            }

                            bool updateStatus = await ds.updateId(
                                'nama~target~periode~foto',
                                _goalsTextController.text +
                                    '~' +
                                    _targetTextController.text +
                                    '~' +
                                    widget.selectedOption +
                                    '~' +
                                    foto,
                                token,
                                project,
                                'nabung',
                                appid,
                                args[0]);
                            if (updateStatus) {
                              Navigator.pop(context, true);
                            }
                          },
                          width: 180,
                          height: 50,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
