import 'package:flutter/material.dart';
import 'package:moneygoals/pages/goal.dart';
import 'package:moneygoals/models/contributions.dart';
import 'package:moneygoals/providers/constants.dart';

import 'addgoal.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:moneygoals/models/goals.dart';
import 'package:moneygoals/providers/database.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late TabController _tabController;

  @override
  void dispose() {
    super.dispose();
    DBHelper.instance.close();
    _tabController.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    _loadAvatar();
  }

  @override
  Widget build(BuildContext context) {
    _tabController =
        TabController(initialIndex: _currentIndex, length: 2, vsync: this);
    return Scaffold(
        bottomNavigationBar: bottomAppBar(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(context,
                      MaterialPageRoute(builder: (context) => addgoal()))
                  .then((value) => setState(() {}));
            },
            child: const Icon(Icons.add),
            backgroundColor: constant.buttonColor),
        backgroundColor: constant.backgroundColor,
        body: FutureBuilder(
            future: Future.wait([
              DBHelper.instance.readAllGoals(),
              DBHelper.instance.readAllAmountContributionsID()
            ]),
            builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (snapshot.hasData) {
                var goals = (snapshot.data as List)[0] as List<Goals>;
                var contributions =
                    (snapshot.data as List)[1] as List<Contributions>;
                return SafeArea(
                    child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            header(contributions),
                            goalsRow(),
                            Container(
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width - 45,
                                child: goals != null
                                    ? TabBarView(
                                        controller: _tabController,
                                        children: [
                                            _listView(
                                                generateListActiveGoals(goals),
                                                contributions,
                                                false),
                                            _listView(
                                                generateListDeactiveGoals(
                                                    goals),
                                                contributions,
                                                true)
                                          ])
                                    : imageContainer()),
                          ],
                        )));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }));
  }

  ListView _listView(
      List<Goals> goals, List<Contributions> contributions, bool disabled) {
    return ListView.separated(
        physics: const BouncingScrollPhysics(),
        itemCount: goals.length,
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(height: 15);
        },
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Goalpage(goals[index], disabled))),
              child: Container(
                  height: 135,
                  width: MediaQuery.of(context).size.width - 45,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white),
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        containerRow(goals[index]),
                        indicatorRow(goals[index],
                            int.parse(goals[index].amount), contributions),
                      ],
                    ),
                  )));
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

  ClipRRect bottomAppBar() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(25),
        topRight: Radius.circular(25),
      ),
      child: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: Theme.of(context).primaryColor.withAlpha(255),
        elevation: 5,
        child: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex: 0,
          selectedItemColor: constant.buttonColor,
          elevation: 15.0,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.schedule_outlined, size: 35), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline, size: 35), label: 'Edit')
          ],
        ),
      ),
    );
  }

  void _setAvatar(String avatar) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('avatar', avatar);
    setState(() {
      constant.chosenImage = avatar;
    });
    Navigator.pop(context);
  }

  void _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    constant.chosenImage = prefs.getString('avatar') ?? 'assets/avatar.png';
  }

  List<Contributions> generateList(
      List<Contributions> _contributions, Goals goal) {
    return _contributions
        .where((element) => element.id_goal == goal.id)
        .toList();
  }

  List<Goals> generateListActiveGoals(List<Goals> goal) {
    return goal.where((element) => element.status == 0).toList();
  }

  List<Goals> generateListDeactiveGoals(List<Goals> goal) {
    return goal.where((element) => element.status == 1).toList();
  }

  Column indicatorRow(
      Goals goals, int goalMoney, List<Contributions> _contributions) {
    List<Contributions> _subContributions = generateList(_contributions, goals);
    int countContributions = countContribution(_subContributions);
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
                restartAnimation: false,
                linearStrokeCap: LinearStrokeCap.roundAll,
                progressColor: constant.buttonColor,
              )),
        ],
      ),
      underIndicatorRow(
          NumberFormat.decimalPattern('ru').format(
              int.parse(countContribution(_subContributions).toString())),
          NumberFormat.decimalPattern('ru').format(int.parse(goals.amount)))
    ]);
  }

  Row underIndicatorRow(String currentAmount, String goalAmount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
            child: Text(currentAmount),
            padding: const EdgeInsets.symmetric(horizontal: 25)),
        Padding(
            child: Text(goalAmount),
            padding: const EdgeInsets.symmetric(horizontal: 25)),
      ],
    );
  }

  Row containerRow(Goals goals) {
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
                  color: const Color(0xFFEAEDF5)),
              child: Icon(
                  IconData(int.parse(goals.icon),
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
            Text(goals.title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            goals.status == 1
                ? Text('Цель достигнута',
                    style: TextStyle(color: Colors.grey[550]))
                : Text(
                    '${((DateTime.parse(goals.date).difference(DateTime.now()).inDays) / 30).round()} месяцев осталось',
                    style: TextStyle(color: Colors.grey[550]))
          ],
        ),
      ],
    );
  }

  Container goalsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 35),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Ваши цели',
              style: TextStyle(
                  color: Colors.grey[600], fontWeight: FontWeight.bold)),
          Padding(
              padding: const EdgeInsets.only(left: 85),
              child: TabBar(
                  controller: _tabController,
                  onTap: (value) => _currentIndex = value,
                  indicatorColor: constant.buttonColor,
                  indicatorWeight: 3.5,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  isScrollable: true,
                  padding: EdgeInsets.zero,
                  tabs: const [Tab(text: 'Все'), Tab(text: 'Выполнено')])),
        ],
      ),
    );
  }

  CircleAvatar circleAvatar(String image) {
    return CircleAvatar(
      backgroundImage: AssetImage(image),
      backgroundColor: constant.backgroundColor,
      radius: 45,
    );
  }

  Container header(List<Contributions> contributions) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 55, horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(children: [
            Text("Вы уже накопили:",
                style: TextStyle(
                    color: Colors.grey[600], fontWeight: FontWeight.bold)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(Icons.euro, color: constant.buttonColor),
                const SizedBox(width: 5),
                Text(countContribution(contributions).toString(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 45))
              ],
            )
          ]),
          Column(children: [
            InkWell(
              onTap: _showAlertDialog,
              child: circleAvatar(constant.chosenImage),
            ),
          ]),
        ],
      ),
    );
  }

  _showAlertDialog() {
    return showDialog(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (context) {
          return AlertDialog(
            backgroundColor: constant.backgroundColor,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 0, vertical: 50),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(3))),
            contentPadding: const EdgeInsets.all(10.0),
            title: const Text(
              'Выберите необходимый аватар',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            content: _gridView(),
            actions: <Widget>[
              IconButton(
                  splashColor: Colors.green,
                  icon: const Icon(
                    Icons.cancel,
                    color: Colors.blue,
                  ),
                  onPressed: () => Navigator.of(context).pop())
            ],
          );
        });
  }

  Container _gridView() {
    return Container(
      width: MediaQuery.of(context).size.width * .7,
      height: MediaQuery.of(context).size.height * .7,
      child: GridView.builder(
          itemCount: constant.avatars.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 4.0,
            childAspectRatio: MediaQuery.of(context).size.width /
                (MediaQuery.of(context).size.height / 2),
            crossAxisSpacing: 4.0,
          ),
          itemBuilder: (context, index) => InkResponse(
              onTap: () => _setAvatar(constant.avatars[index]),
              child: circleAvatar(constant.avatars[index]))),
    );
  }
}
