import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:moneygoals/models/goals.dart';
import 'package:moneygoals/pages/home.dart';
import 'package:moneygoals/providers/database.dart';
import 'package:intl/intl.dart';

class addgoal extends StatefulWidget {
  addgoal({Key? key}) : super(key: key);

  @override
  _addgoalState createState() => _addgoalState();
}

class _addgoalState extends State<addgoal> {
  List<TextEditingController> _controller =
      List.generate(4, (i) => TextEditingController());
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    print(MaterialLocalizations.of(context));

    return Scaffold(
      backgroundColor: Color(0xFFE9EBF1),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Color(0xFFE9EBF1),
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
                  child: Text('Давайте создадим\n вашу цель!',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
                  padding: EdgeInsets.symmetric(vertical: 25, horizontal: 15)),
              Stack(children: [
                Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 270,
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
                            inputRow(
                                "Введите название цели", 0, _controller[0]),
                            SizedBox(height: 40),
                            inputRowName('Сумма цели'),
                            inputRow('Введите сумму цели', 0, _controller[1]),
                            const SizedBox(height: 40),
                            inputRowName('Дата достижения цели'),
                            inputRow('Выберите дату достижения цели', 2,
                                _controller[2]),
                            SizedBox(height: 40),
                            inputRowName('Иконка цели'),
                            inputRow('Выберите иконку', 3, _controller[3]),
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
        _controller[2].text = formatter.format(picked).toString();
      });
    }
  }

  _nothing() async {
    debugPrint('Hello world');
  }

  _pickIcon() async {
    IconData? icon = await FlutterIconPicker.showIconPicker(context,
        iconPackMode: IconPack.lineAwesomeIcons,
        iconColor: Color(0xFF442BEB),
        backgroundColor: Color(0xFFE9EBF1),
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
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(50)),
              color: Color(0xFF442BEB)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 45),
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
                  onPressed: () => _createGoal(),
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
        decoration: new InputDecoration.collapsed(
            hintText: '$hint...', hintStyle: TextStyle(fontSize: 16)),
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18));
  }

  void _createGoal() {
    DBHelper.instance.createGoal(Goals(
        title: _controller[0].text,
        amount: _controller[1].text,
        date: _controller[2].text,
        icon: _controller[3].text,
        status: 0));
    Navigator.pop(context);
  }
}
