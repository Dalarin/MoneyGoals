import 'package:flutter/material.dart';
import 'package:moneygoals/models/contributions.dart';
import 'package:moneygoals/models/goals.dart';
import 'package:moneygoals/pages/addcontribution.dart';
import 'package:moneygoals/providers/constants.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:moneygoals/providers/database.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Goalpage extends StatefulWidget {
  Goals _goal;
  bool disabled;
  Goalpage(this._goal, this.disabled);

  @override
  _GoalpageState createState() => _GoalpageState();
}

class _GoalpageState extends State<Goalpage> {
  List<int> values = [];
  bool indexSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: constant.backgroundColor,
        appBar: indexSelected ? changedAppBar() : appBar(),
        body: content());
  }

  AppBar changedAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      iconTheme: const IconThemeData(color: Colors.black),
      backgroundColor: const Color(0xFFFC9C9F),
      elevation: 0.0,
      leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => setState(() {
                values.clear();
                indexSelected = false;
              })),
      actions: [
        IconButton(
            onPressed: () => showAlertDialogContributions(),
            icon: const FaIcon(FontAwesomeIcons.trashAlt))
      ],
    );
  }

  _deleteContributions() {
    values.forEach((element) => DBHelper.instance.deleteContribution(element));
    setState(() {
      indexSelected = false;
    });
    Navigator.pop(context);
  }

  AppBar appBar() {
    return AppBar(
      actions: [
        PopupMenuButton(
          icon: const Icon(Icons.more_vert_outlined),
          itemBuilder: (_) => <PopupMenuItem<String>>[
            const PopupMenuItem<String>(
              child: Text('Удалить'),
              value: 'Delete',
            ),
            const PopupMenuItem<String>(
                child: Text('Редактировать'), value: 'Edit')
          ],
          onSelected: (String value) {
            value == 'Delete'
                ? showAlertDialogGoal(context, widget._goal.id!)
                : null;
          },
        ),
      ],
      iconTheme: const IconThemeData(color: Colors.black),
      backgroundColor: const Color(0xFFFC9C9F),
      elevation: 0.0,
      title: const Text('Ваша цель', style: TextStyle(color: Colors.black)),
      centerTitle: true,
    );
  }

  Widget content() {
    return FutureBuilder(
        future: DBHelper.instance.readAllContributions(widget._goal.id!),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          var contributions = (snapshot.data as List) as List<Contributions>;
          return SafeArea(
              top: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * .25,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFC9C9F),
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(35),
                          bottomRight: Radius.circular(35)),
                    ),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                              height: 135,
                              width: MediaQuery.of(context).size.width - 45,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: const Color(0xFF272231)),
                              child: Container(
                                  child: Column(children: [
                                containerRow(),
                                indicatorRow(
                                    widget._goal,
                                    contributions,
                                    int.parse(widget._goal
                                        .amount)), // <----- здесь проблема
                              ])))
                        ]),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [Text('Операции с целью')],
                    ),
                  ),
                  contributions != null
                      ? contributions.length == 0
                          ? imageContainer()
                          : listView(contributions)
                      : imageContainer(),
                  Padding(
                      child: buttonContainer(countContribution(contributions),
                          int.parse(widget._goal.amount), widget.disabled),
                      padding: const EdgeInsets.symmetric(vertical: 10))
                ],
              ));
        });
  }

  Widget imageContainer() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.47,
        child: Column(children: [
          Image.asset('assets/nothing.png'),
          const Text('Ничего нет...',
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 17,
                  fontStyle: FontStyle.italic))
        ]));
  }

  Widget buttonContainer(int amount, int goalAmount, bool disabled) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: const Color(0xFF6261FE),
            fixedSize: Size(MediaQuery.of(context).size.width * .95, 45),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0))),
        child: const Text('Добавить операцию'),
        onPressed: () => disabled
            ? null
            : Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => addcontribution(
                            widget._goal.id!, amount, goalAmount)))
                .then((value) => setState(() {})));
  }

  Widget listView(List<Contributions> contributions) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.47,
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: contributions.length,
            itemBuilder: (BuildContext context, int index) => InkWell(
                onLongPress: () => _onLongPress(contributions[index]),
                child: listViewCard(contributions, index))));
  }

  _onLongPress(Contributions contributions) {
    setState(() {
      !values.contains(contributions.id)
          ? values.add(contributions.id!)
          : values.remove(contributions.id);
      indexSelected = values.isNotEmpty ? true : false;
    });
  }

  Widget listViewCard(List<Contributions> contributions, int index) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.096,
      width: (MediaQuery.of(context).size.width * 0.37) / 3,
      color: values.contains(contributions[index].id)
          ? const Color(0xFFCDCFD5)
          : constant.backgroundColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Row(
              children: [
                Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.04),
                    child: Container(
                        alignment: Alignment.center,
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(50)),
                          color: int.parse(contributions[index].amount) < 0
                              ? const Color(0xFFFC9C9F)
                              : const Color(0xFFADADF9),
                        ),
                        child: int.parse(contributions[index].amount) < 0
                            ? const Icon(Icons.money_off)
                            : const Icon(Icons.attach_money_outlined))),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        width: MediaQuery.of(context).size.width * .45,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(contributions[index].comment,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                              Text(contributions[index].date,
                                  style: const TextStyle(fontSize: 15))
                            ])),
                  ],
                ),
              ],
            ),
          ),
          Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Text(contributions[index].amount,
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)))
              ])
        ],
      ),
    );
  }

  Widget containerRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            child: Container(
              alignment: Alignment.center,
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: const Color(0xFF362E4F)),
              child: Icon(
                  IconData(int.parse(widget._goal.icon),
                      fontFamily: 'LineAwesomeIcons',
                      fontPackage: 'flutter_iconpicker'),
                  size: 40,
                  color: constant.buttonColor),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            Text(widget._goal.title,
                style: const TextStyle(
                    color: Color(0xFFF5F5F9),
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
            widget.disabled
                ? const Text('Цель достигнута',
                    style: TextStyle(color: Colors.white))
                : Text(
                    '${((DateTime.parse(widget._goal.date).difference(DateTime.now()).inDays) / 30).round()} месяцев осталось',
                    style: const TextStyle(color: Colors.white))
          ],
        ),
      ],
    );
  }

  Widget indicatorRow(
      Goals goals, List<Contributions> _contributions, int goalMoney) {
    return FutureBuilder(builder: (context, AsyncSnapshot snapshot) {
      int countContributions = countContribution(_contributions);
      return Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                alignment: Alignment.center,
                height: 15,
                width: 300,
                child: LinearPercentIndicator(
                  width: MediaQuery.of(context).size.width - 94,
                  animation: true,
                  lineHeight: 13.0,
                  backgroundColor: constant.backgroundColor,
                  animationDuration: 1500,
                  center: Text(
                      '${((countContributions / goalMoney) * 100).toStringAsFixed(3)} %',
                      style: const TextStyle(fontSize: 13)),
                  percent: (countContributions / goalMoney).abs() > 1.0
                      ? 1.0
                      : (countContributions / goalMoney).toDouble().abs(),
                  linearStrokeCap: LinearStrokeCap.roundAll,
                  progressColor: constant.buttonColor,
                )),
          ],
        ),
        underIndicatorRow(
            NumberFormat.decimalPattern('ru').format(
                int.parse(countContribution(_contributions).toString())),
            NumberFormat.decimalPattern('ru').format(int.parse(goals.amount)))
      ]);
    });
  }

  int countContribution(List<Contributions> contributions) {
    int sum = 0;
    if (contributions != null) {
      for (int i = 0; i < contributions.length; i++) {
        sum += int.parse(contributions[i].amount);
      }
      return sum;
    } else {
      return 0;
    }
  }

  Widget underIndicatorRow(String currentAmount, String goalAmount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
            child: Text(currentAmount,
                style: const TextStyle(color: Color(0xFFF5F5F9))),
            padding: const EdgeInsets.symmetric(horizontal: 25)),
        Padding(
            child: Text(goalAmount,
                style: const TextStyle(color: Color(0xFFF5F5F9))),
            padding: const EdgeInsets.symmetric(horizontal: 25)),
      ],
    );
  }

  showAlertDialogContributions() {
    Widget cancelButton = TextButton(
        child: const Text("Отменить"), onPressed: () => Navigator.pop(context));
    Widget continueButton = TextButton(
        child: const Text("Ок"), onPressed: () => _deleteContributions());
    AlertDialog alert = AlertDialog(
        title: const Text("Удаление"),
        content:
            Text('Вы уверены, что хотите удалить ${values.length} операций?'),
        actions: [cancelButton, continueButton]);
    showDialog(context: context, builder: (BuildContext context) => alert);
  }

  showAlertDialogGoal(BuildContext context, int goalID) {
    Widget cancelButton = TextButton(
        child: const Text("Отменить"), onPressed: () => Navigator.pop(context));
    Widget continueButton = TextButton(
        child: const Text("Ок"),
        onPressed: () => DBHelper.instance.deleteGoal(goalID).whenComplete(() {
              Navigator.popUntil(context, ModalRoute.withName('/home'));
            }));
    AlertDialog alert = AlertDialog(
        title: const Text("Удаление"),
        content: const Text("Вы уверены, что хотите удалить цель?"),
        actions: [cancelButton, continueButton]);
    showDialog(context: context, builder: (BuildContext context) => alert);
  }
}
