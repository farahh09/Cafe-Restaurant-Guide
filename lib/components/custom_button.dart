import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String textButton;
  final Function()? onTap;

  const CustomButton({
    super.key,
    required this.textButton,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Container(
          padding: const EdgeInsets.all(10),

          decoration: BoxDecoration(
            color: Colors.lightBlue[800],
            borderRadius: BorderRadius.circular(35), // Rounded corners
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4,  offset: Offset(0, 3),),],
          ),

          child: Center( child: Text(
            textButton,
            style: TextStyle( color: Colors.white, fontSize: 25,),),
          ),

        ),

      ),

    );

  }
}

//Colors.lightBlue[800]