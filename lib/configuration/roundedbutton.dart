import 'package:aturuang/configuration/theme_config.dart';
import 'package:flutter/material.dart';

class ToggleButton extends StatefulWidget {
  @override
  _ToggleButtonState createState() => _ToggleButtonState();
  final List<bool> isSelected;
  final List<String> buttonLabels;
  final Function(int) onPressed;

  ToggleButton(
      {required this.isSelected,
      required this.buttonLabels,
      required this.onPressed});
}

class _ToggleButtonState extends State<ToggleButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      child: Card(
        color: primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
        child: ToggleButtons(
          isSelected: widget.isSelected,
          onPressed: (int index) {
            setState(() {
              for (int buttonIndex = 0;
                  buttonIndex < widget.isSelected.length;
                  buttonIndex++) {
                widget.isSelected[buttonIndex] = buttonIndex == index;
              }
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
        ),
      ),
    );
  }
}

const kTextFieldDecoration = InputDecoration(
  filled: true,
  fillColor: Color.fromARGB(242, 242, 242, 242),
  hintText: 'Fill A value',
  hintStyle: TextStyle(
      color: Colors.grey, fontFamily: 'Poppins-Reguler', fontSize: 12),
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

class RoundedButton extends StatelessWidget {
  RoundedButton(
      {required this.title,
      required this.onPressed,
      required this.width,
      required this.height,
      required Color color});
  final String title;
  final VoidCallback onPressed;

  final double width;
  final double height;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: primaryColor,
        borderRadius: BorderRadius.circular(8.0),
        child: MaterialButton(
          onPressed: onPressed,
          minWidth: width,
          height: height,
          child: Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
    );
  }
}
