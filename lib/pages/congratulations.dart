import 'package:flutter/material.dart';
import 'package:moneygoals/models/goals.dart';
import 'package:moneygoals/providers/constants.dart';
import 'package:moneygoals/providers/database.dart';

class congratulations extends StatefulWidget {
  int idGoal;
  congratulations(this.idGoal);

  @override
  _congratulationsState createState() => _congratulationsState();
}

class _congratulationsState extends State<congratulations> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: constant.backgroundColor,
        body: SafeArea(
            child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
              const Text('Поздравляем Вас\nс достижением цели!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
              Image.asset('assets/congratulations.png',
                  width: MediaQuery.of(context).size.width),
              buttonContainer(),
            ]))));
  }

  ElevatedButton buttonContainer() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: const Color(0xFF6261FE),
            fixedSize: Size(MediaQuery.of(context).size.width * .75, 45),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0))),
        child: const Text('Продолжить'),
        onPressed: () {
          DBHelper.instance.updateGoal(1, widget.idGoal).whenComplete(() =>
              {Navigator.popUntil(context, ModalRoute.withName('/home'))});
        });
  }
}
