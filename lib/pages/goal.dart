import 'package:flutter/material.dart';
import 'package:moneygoals/models/contributions.dart';
import 'package:moneygoals/models/goals.dart';
import 'package:moneygoals/pages/addcontribution.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:moneygoals/providers/database.dart';
import 'package:shimmer/shimmer.dart';

class Goalpage extends StatefulWidget {
  late Goals _goal;
  Goalpage({Key? key, required Goals goal}) {
    _goal = goal;
  }

  @override
  _GoalpageState createState() => _GoalpageState(_goal);
}

class _GoalpageState extends State<Goalpage> {
  late Goals goal;
  late List<Contributions> contributions;
  late String _chosenValue;
  bool loading = false;
  _GoalpageState(Goals goals) {
    this.goal = goals;
  }
  @override
  void initState() {
    super.initState();
    loadContributions();
  }

  Future<void> loadContributions() async {
    setState(() {
      loading = true;
    });
    var tableData = await DBHelper.instance.readAllContributions(goal.id!);
    setState(() {
      contributions = tableData;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE9EBF1),
      appBar: AppBar(
        actions: [
          IconButton(
              icon: const Icon(Icons.more_vert_outlined), onPressed: () {})
        ],
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Color(0xFFFC9C9F),
        elevation: 0.0,
        title: const Text('Ваша цель', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SafeArea(
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
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                Container(
                    height: 135,
                    width: MediaQuery.of(context).size.width - 45,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color(0xFF272231)),
                    child: Container(
                        child: Column(children: [
                      containerRow(),
                      indicatorRow(),
                      underIndicatorRow('13.800', goal.amount.toString()),
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
            contributions.isEmpty ? imageContainer() : listView(),
            buttonContainer()
          ],
        ),
      ),
    );
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

  Container buttonContainer() {
    return Container(
        child: ElevatedButton(
      style: ElevatedButton.styleFrom(
          primary: Color(0xFF6261FE),
          fixedSize: Size(MediaQuery.of(context).size.width - 55, 45),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0))),
      child: Text('Добавить операцию'),
      onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => addcontribution(idGoal: goal.id!))),
    ));
  }

  Container listView() {
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
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                      alignment: Alignment.center,
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        color: int.parse(contributions[index].amount) < 0
                            ? Color(0xFFFC9C9F)
                            : Color(0xFFADADF9),
                      ),
                      child: int.parse(contributions[index].amount) < 0
                          ? Icon(Icons.money_off)
                          : Icon(Icons.attach_money_outlined)),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(contributions[index].comment,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      Text(contributions[index].date,
                          style: const TextStyle(fontSize: 15))
                    ],
                  ),
                  Text(contributions[index].amount,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
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
                  color: Color(0xFF362E4F)),
              child: Icon(
                  IconData(int.parse(goal.icon),
                      fontFamily: 'LineAwesomeIcons',
                      fontPackage: 'flutter_iconpicker'),
                  size: 40,
                  color: Color(0xFF442BEB)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 25),
            Text(goal.title,
                style: const TextStyle(
                    color: Color(0xFFF5F5F9),
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
            Text(
                '${((DateTime.parse(goal.date).difference(DateTime.now()).inDays) / 30).round()} месяцев осталось',
                style: const TextStyle(color: Color(0xFFF5F5F9)))
          ],
        ),
      ],
    );
  }

  Row indicatorRow() {
    return Row(
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
              backgroundColor: Color(0xFFE9EBF1),
              animationDuration: 2000,
              percent: 0.9,
              restartAnimation: true,
              linearStrokeCap: LinearStrokeCap.roundAll,
              progressColor: Color(0xFF442BEB),
            )),
      ],
    );
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
            child:
                Text(currentAmount, style: TextStyle(color: Color(0xFFF5F5F9))),
            padding: EdgeInsets.symmetric(horizontal: 25)),
        Padding(
            child: Text(goalAmount, style: TextStyle(color: Color(0xFFF5F5F9))),
            padding: EdgeInsets.symmetric(horizontal: 25)),
      ],
    );
  }
}
