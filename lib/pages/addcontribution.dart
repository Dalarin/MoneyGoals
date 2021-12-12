import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moneygoals/models/contributions.dart';
import 'package:moneygoals/pages/congratulations.dart';
import 'package:moneygoals/providers/database.dart';
import 'package:intl/intl.dart';

class addcontribution extends StatefulWidget {
  int idGoal, moneyAmount, goalAmount;
  addcontribution(this.idGoal, this.moneyAmount, this.goalAmount);

  @override
  _addcontributionState createState() => _addcontributionState();
}

class _addcontributionState extends State<addcontribution> {
  final List<TextEditingController> _controller =
      List.generate(3, (i) => TextEditingController());
  bool validate = false;

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
                                _controller[0], TextInputType.text),
                            const SizedBox(height: 40),
                            inputRowName('Сумма операции'),
                            inputRow('Введите сумму операции', 0,
                                _controller[1], TextInputType.number),
                            const SizedBox(height: 40),
                            inputRowName('Дата операции'),
                            inputRow('Выберите дату проведения операции', 2,
                                _controller[2], TextInputType.none),
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
        locale: const Locale('ru'));
    if (picked != null) {
      setState(() {
        _controller[2].text =
            DateFormat('yyyy-MM-dd').format(picked).toString();
      });
    }
  }

  Future<void> _createOperation() async {
    await DBHelper.instance
        .createContribution(Contributions(
            id_goal: widget.idGoal,
            amount: _controller[1].text,
            comment: _controller[0].text,
            date: _controller[2].text))
        .whenComplete(() => {
              if (widget.moneyAmount + int.parse(_controller[1].text) >=
                  widget.goalAmount)
                {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => congratulations(widget.idGoal)))
                }
              else
                {Navigator.pop(context)}
            });
  }

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
              SizedBox(height: MediaQuery.of(context).size.height * .06),
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
                  onPressed: () => onPressed(),
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
    return Text(name,
        style: const TextStyle(
            color: Color(0xFFB4B7BD),
            fontSize: 17,
            fontWeight: FontWeight.bold));
  }

  TextField inputRow(String hint, int operationType,
      TextEditingController _controller, TextInputType inputType) {
    return TextField(
        keyboardType: inputType,
        controller: _controller,
        onTap: () {
          operationType == 2 ? _pickDate() : null;
        },
        decoration: InputDecoration.collapsed(
            hintText: '$hint...', hintStyle: const TextStyle(fontSize: 16)),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18));
  }

  onPressed() {
    _controller[0].text.isEmpty ||
            _controller[1].text.isEmpty ||
            _controller[2].text.isEmpty
        ? validate = true
        : validate = false;
    if (!validate) {
      _createOperation();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.white,
        content: Text("Все поля должны быть заполнены",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ));
    }
  }
}
