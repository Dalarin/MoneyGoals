import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moneygoals/models/contributions.dart';
import 'package:moneygoals/providers/database.dart';
import 'package:intl/intl.dart';

class addcontribution extends StatefulWidget {
  late int idGoal;
  addcontribution({Key? key, required int idGoal}) : super(key: key) {
    this.idGoal = idGoal;
  }

  @override
  _addcontributionState createState() => _addcontributionState(idGoal);
}

class _addcontributionState extends State<addcontribution> {
  late int idGoal;
  List<TextEditingController> _controller =
      List.generate(4, (i) => TextEditingController());

  _addcontributionState(int idGoal) {
    this.idGoal = idGoal;
  }

  @override
  void initState() {
    super.initState();
    _controller[2].text =
        DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9EBF1),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFFE9EBF1),
        title: const Text('Добавление операции',
            style: TextStyle(color: Color(0xFF897BF2))),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                  child: Text('Давайте добавим\n операцию к цели!',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
                  padding: EdgeInsets.symmetric(vertical: 25, horizontal: 15)),
              Stack(children: [
                Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    decoration: const BoxDecoration(
                        borderRadius:
                            BorderRadius.only(topLeft: Radius.circular(50)),
                        color: Colors.white),
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 45, horizontal: 35),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            inputRowName('Комментарий к операции'),
                            inputRow("Введите комментарий к операции", 0,
                                _controller[0]),
                            SizedBox(height: 40),
                            inputRowName('Сумма операции'),
                            inputRow(
                                'Введите сумму операции', 0, _controller[1]),
                            const SizedBox(height: 40),
                            inputRowName('Дата операции'),
                            inputRow('Выберите дату проведения операции', 2,
                                _controller[2]),
                          ],
                        ))),
                buttonContainer()
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2018),
        lastDate: DateTime(2045),
        fieldHintText: 'Выберите дату',
        helpText: 'Выберите дату',
        cancelText: 'Отмена',
        confirmText: 'OK',
        locale: const Locale('ru'));
    if (picked != null) {
      setState(() {
        _controller[2].text =
            DateFormat('yyyy-MM-dd').format(picked).toString();
      });
    }
  }

  void _createOperation() {
    DBHelper.instance.createContribution(Contributions(
        id_goal: idGoal,
        amount: _controller[1].text,
        comment: _controller[0].text,
        date: _controller[2].text));
    Navigator.pop(context);
  }
  // void _createGoal() {
  //   DBHelper.instance.createContribution(Co(
  //       title: _controller[0].text,
  //       amount: _controller[1].text,
  //       date: _controller[2].text,
  //       icon: _controller[3].text,
  //       status: 0));
  //   Navigator.pop(context);
  // }

  Positioned buttonContainer() {
    return Positioned(
        top: MediaQuery.of(context).size.height * .50,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(50)),
              color: Color(0xFF442BEB)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * .1),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 15,
                      shadowColor: Colors.black,
                      primary: Colors.white,
                      fixedSize:
                          Size(MediaQuery.of(context).size.width - 75, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      )),
                  onPressed: () => _createOperation(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('Добавить операцию',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 15))
                    ],
                  ))
            ],
          ),
        ));
  }

  Text inputRowName(String name) {
    return Text('$name',
        style: TextStyle(
            color: Color(0xFFB4B7BD),
            fontSize: 17,
            fontWeight: FontWeight.bold));
  }

  TextField inputRow(
      String hint, int operationType, TextEditingController _controller) {
    return TextField(
        controller: _controller,
        onTap: () {
          operationType == 2 ? _pickDate() : null;
        },
        decoration: new InputDecoration.collapsed(
            hintText: '$hint...', hintStyle: TextStyle(fontSize: 16)),
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18));
  }
}
