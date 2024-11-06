import 'package:flutter/material.dart';

class IconCustomButton extends StatelessWidget {
  final Function() onTap;
  final Icon icon;
  final double margin;
  const IconCustomButton({
    super.key,
    required this.onTap,
    required this.icon,
    this.margin = 0,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        margin: EdgeInsets.only(right: margin),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              blurStyle: BlurStyle.outer,
              offset: Offset(1, 1),
              blurRadius: 1,
              spreadRadius: 1,
            ),
          ],
        ),
        child: icon,
      ),
    );
  }
}
