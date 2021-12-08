import 'package:flutter/material.dart';
import 'package:moneygoals/pages/goal.dart';
import 'package:moneygoals/models/contributions.dart';
import 'addgoal.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:moneygoals/models/goals.dart';
import 'package:moneygoals/providers/database.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  int _amountGoal = 0;
  var loading = true;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    DBHelper.instance.close();
  }

  TabController? _tabController;
  @override
  Widget build(BuildContext context) {
    _tabController = TabController(length: 2, vsync: this);
    return Scaffold(
        bottomNavigationBar: bottomAppBar(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                    context, MaterialPageRoute(builder: (context) => addgoal()))
                .then((value) => setState(() {}));
          },
          child: const Icon(Icons.add),
          backgroundColor: Color(0xFF442BEB),
        ),
        backgroundColor: const Color(0xFFE9EBF1),
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
                          child: ListView.separated(
                            physics: BouncingScrollPhysics(),
                            itemCount: goals.length,
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return const SizedBox(height: 15);
                            },
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              Goalpage(goal: goals[index]))),
                                  child: Container(
                                      height: 135,
                                      width: MediaQuery.of(context).size.width -
                                          45,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Colors.white),
                                      child: Container(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            containerRow(goals[index]),
                                            indicatorRow(
                                                goals,
                                                int.parse(goals[index].amount),
                                                index),
                                          ],
                                        ),
                                      )));
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Column(children: [Text('hello world')]);
              }
            }));
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

  int sumContributions(List<Contributions> contributions) {
    int sum = 0;
    for (int i = 0; i < contributions.length; i++) {
      sum += int.parse(contributions[i].amount);
    }
    return sum;
  }

  BottomAppBar bottomAppBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      color: Theme.of(context).primaryColor.withAlpha(255),
      elevation: 0,
      child: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: 0,
        selectedItemColor: Color(0xFF442BEB),
        elevation: 15.0,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.schedule_outlined, size: 35), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 35), label: 'Edit')
        ],
      ),
    );
  }

  FutureBuilder indicatorRow(List<Goals> goals, int goalMoney, int index) {
    return FutureBuilder(
        future: DBHelper.instance.readAllAmountContributions(goals[index].id!),
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
            underIndicatorRow(
                countContribution(contributions).toString(),
                NumberFormat.decimalPattern()
                    .format(int.parse(goals[index].amount)))
          ]);
        });
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
                  color: Color(0xFFEAEDF5)),
              child: Icon(
                  IconData(int.parse(goals.icon),
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
            Text(goals.title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Text(
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
                  indicatorColor: Color(0xFF442BEB),
                  indicatorWeight: 3.5,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  isScrollable: true,
                  padding: EdgeInsets.zero,
                  controller: _tabController,
                  tabs: const [Tab(text: 'Все'), Tab(text: 'Выполнено')])),
        ],
      ),
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
                const Icon(Icons.euro, color: Color(0xFF442BEB)),
                const SizedBox(width: 5),
                Text(sumContributions(contributions).toString(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 45))
              ],
            )
          ]),
          Column(children: const [
            CircleAvatar(
              backgroundImage: AssetImage('assets/avatar.png'),
              backgroundColor: Color(0xFFE9EBF1),
              radius: 45,
            )
          ]),
        ],
      ),
    );
  }
}
