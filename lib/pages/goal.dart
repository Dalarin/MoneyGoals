import 'package:flutter/material.dart';
import 'package:moneygoals/models/contributions.dart';
import 'package:moneygoals/models/goals.dart';
import 'package:moneygoals/pages/addcontribution.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:moneygoals/providers/database.dart';
import 'package:intl/intl.dart';

import 'package:shimmer/shimmer.dart';

class Goalpage extends StatefulWidget {
  late Goals _goal;
  Goalpage({Key? key, required Goals goal}) {
    _goal = goal;
  }

  @override
  _GoalpageState createState() => _GoalpageState();
}

class _GoalpageState extends State<Goalpage> {
  bool loading = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFE9EBF1),
        appBar: AppBar(
          actions: [
            PopupMenuButton(
                icon: Icon(Icons.more_vert_outlined),
                itemBuilder: (_) => <PopupMenuItem<String>>[
                      PopupMenuItem<String>(
                        child: Text('Удалить'),
                        value: 'Delete',
                      ),
                      PopupMenuItem<String>(
                          child: Text('Редактировать'), value: 'Edit'),
                    ],
                onSelected: (String value) {
                  value == 'Delete'
                      ? showAlertDialog(context, widget._goal.id!)
                      : null;
                }),
          ],
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Color(0xFFFC9C9F),
          elevation: 0.0,
          title: const Text('Ваша цель', style: TextStyle(color: Colors.black)),
          centerTitle: true,
        ),
        body: FutureBuilder(
            future: DBHelper.instance.readAllContributions(widget._goal.id!),
            builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
              var contributions =
                  (snapshot.data as List) as List<Contributions>;
              return SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 15),
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
                                      color: Color(0xFF272231)),
                                  child: Container(
                                      child: Column(children: [
                                    containerRow(),
                                    indicatorRow(widget._goal,
                                        int.parse(widget._goal.amount)),
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
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                      buttonContainer()
                    ],
                  ));
            }));
  }

  Container imageContainer() {
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

  ElevatedButton buttonContainer() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: const Color(0xFF6261FE),
            fixedSize: Size(MediaQuery.of(context).size.width * .95, 45),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0))),
        child: const Text('Добавить операцию'),
        onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        addcontribution(idGoal: widget._goal.id!)))
            .then((value) => setState(() {})));
  }

  Container listView(List<Contributions> contributions) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.47,
        child: ListView.builder(
          itemCount: contributions.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.12,
              width: (MediaQuery.of(context).size.width * 0.37) / 3,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                          width: MediaQuery.of(context).size.width * 0.35,
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
                  SizedBox(width: MediaQuery.of(context).size.width * 0.27),
                  Text(contributions[index].amount,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold))
                ],
              ),
            );
          },
        ));
  }

  Row containerRow() {
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
                  color: const Color(0xFF442BEB)),
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
            Text(
                '${((DateTime.parse(widget._goal.date).difference(DateTime.now()).inDays) / 30).round()} месяцев осталось',
                style: const TextStyle(color: Color(0xFFF5F5F9)))
          ],
        ),
      ],
    );
  }

  FutureBuilder indicatorRow(Goals goals, int goalMoney) {
    return FutureBuilder(
        future: DBHelper.instance.readAllAmountContributions(goals.id!),
        builder: (context, snapshot) {
          var contributions = (snapshot.data as List) as List<Contributions>;
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
                      backgroundColor: const Color(0xFFE9EBF1),
                      animationDuration: 2000,
                      center: Text(
                          '${(countContribution(contributions) / goalMoney) * 100} %',
                          style: const TextStyle(fontSize: 13)),
                      percent: countContribution(contributions) / goalMoney,
                      restartAnimation: true,
                      linearStrokeCap: LinearStrokeCap.roundAll,
                      progressColor: const Color(0xFF442BEB),
                    )),
              ],
            ),
            underIndicatorRow(countContribution(contributions).toString(),
                NumberFormat.decimalPattern().format(int.parse(goals.amount)))
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

  // DropdownButton _showDropDownMenu() {
  //   return DropdownButton(icon: Icon(Icons.more_vert_outlined), items: [
  //     DropdownMenuItem(child: Text('Изменить')),
  //     DropdownMenuItem(child: Text('Удалить')),
  //   ]);
  // }

  Row underIndicatorRow(String currentAmount, String goalAmount) {
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

  showAlertDialog(BuildContext context, int goalID) {
    Widget cancelButton = TextButton(
        child: Text("Отменить"),
        onPressed: () {
          Navigator.pop(context);
        });
    Widget continueButton = TextButton(
        child: Text("Ок"),
        onPressed: () {
          DBHelper.instance.deleteGoal(goalID);
          Navigator.pop(context);
          Navigator.pop(context);
        });

    AlertDialog alert = AlertDialog(
      title: Text("Удаление"),
      content: Text("Вы уверены, что хотите удалить цель?"),
      actions: [cancelButton, continueButton],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }
}
