import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:moneygoals/models/goals.dart';
import 'package:moneygoals/providers/constants.dart';
import 'package:moneygoals/providers/database.dart';
import 'package:intl/intl.dart';

class addgoal extends StatefulWidget {
  addgoal({Key? key}) : super(key: key);

  @override
  _addgoalState createState() => _addgoalState();
}

class _addgoalState extends State<addgoal> {
  final List<TextEditingController> _controller =
      List.generate(4, (i) => TextEditingController());
  bool validate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: constant.backgroundColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: constant.backgroundColor,
        elevation: 0.0,
        title: const Text('Шаг 2', style: TextStyle(color: Color(0xFF897BF2))),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                  child: Text('Давайте создадим\nвашу цель!',
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
                            inputRowName('Название цели'),
                            inputRow("Введите название цели", 0, _controller[0],
                                false, TextInputType.text),
                            const SizedBox(height: 40),
                            inputRowName('Сумма цели'),
                            inputRow('Введите сумму цели', 0, _controller[1],
                                false, TextInputType.number),
                            const SizedBox(height: 40),
                            inputRowName('Дата достижения цели'),
                            inputRow('Выберите дату достижения цели', 2,
                                _controller[2], true, TextInputType.none),
                            const SizedBox(height: 40),
                            inputRowName('Иконка цели'),
                            inputRow('Выберите иконку', 3, _controller[3], true,
                                TextInputType.none),
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

  _nothing() async {
    debugPrint('Hello world');
  }

  _pickIcon() async {
    IconData? icon = await FlutterIconPicker.showIconPicker(context,
        iconPackMode: IconPack.lineAwesomeIcons,
        iconColor: constant.buttonColor,
        backgroundColor: constant.backgroundColor,
        title: const Text('Выберите иконку'),
        closeChild: const Text('Закрыть'),
        searchHintText: 'Поиск');

    setState(() {
      _controller[3].text = icon!.codePoint.toString();
    });
  }

  Positioned buttonContainer() {
    return Positioned(
        top: MediaQuery.of(context).size.height * .50,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(50)),
              color: constant.buttonColor),
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
                      Text('Создать цель',
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

  TextField inputRow(
      String hint,
      int operationType,
      TextEditingController _controller,
      bool _isEditable,
      TextInputType textInputType) {
    return TextField(
        keyboardType: textInputType,
        readOnly: _isEditable,
        controller: _controller,
        onTap: () {
          switch (operationType) {
            case 2:
              _pickDate();
              break;
            case 3:
              _pickIcon();
              break;
            default:
              () => _nothing();
          }
        },
        decoration: InputDecoration.collapsed(
            hintText: '$hint...', hintStyle: const TextStyle(fontSize: 16)),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18));
  }

  Future<void> _createGoal() async {
    await DBHelper.instance
        .createGoal(Goals(
            title: _controller[0].text,
            amount: _controller[1].text,
            date: _controller[2].text,
            icon: _controller[3].text,
            status: 0))
        .whenComplete(() => Navigator.pop(context));
    // Необходимо внедрить проверку на пустые поля
  }

  onPressed() {
    _controller[0].text.isEmpty ||
            _controller[1].text.isEmpty ||
            _controller[2].text.isEmpty ||
            _controller[3].text.isEmpty
        ? validate = true
        : validate = false;
    if (!validate) {
      _createGoal();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.white,
        content: Text("Все поля должны быть заполнены",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ));
    }
  }
}
