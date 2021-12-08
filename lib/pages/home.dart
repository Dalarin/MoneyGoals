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
  late List<Contributions> contributions;
  late List<Goals> goals;
  var loading = false;
  @override
  void initState() {
    super.initState();
    loadGoals();
    loadContributions();
  }

  @override
  void dispose() {
    super.dispose();
    DBHelper.instance.close();
  }

  Future<void> loadContributions() async {
    var tableData = await DBHelper.instance.readAllAmountContributionsID();
    setState(() {
      contributions = tableData;
    });
  }

  Future<void> loadGoals() async {
    setState(() {
      loading = true;
    });
    var tableData = await DBHelper.instance.readAllGoals();
    setState(() {
      goals = tableData;
      loading = false;
    });
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
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF442BEB),
      ),
      backgroundColor: Color(0xFFE9EBF1),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              header(),
              goalsRow(),
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width - 45,
                child: ListView.separated(
                  itemCount: goals.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(height: 15);
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
                                  indicatorRow(
                                      int.parse(goals[index].amount), index),
                                  underIndicatorRow(
                                      _amountGoal.toString(),
                                      NumberFormat.decimalPattern().format(
                                          int.parse(goals[index].amount)))
                                ],
                              ),
                            )));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> countContribution(int index) async {
    List<Contributions> contributions =
        await DBHelper.instance.readAllAmountContributions(goals[index].id!);
    int sum = 0;
    for (int i = 0; i < contributions.length; i++)
      sum += int.parse(contributions[i].amount);
    setState(() {
      _amountGoal = sum;
    });
  }

  int sumContributions() {
    int sum = 0;
    for (int i = 0; i < contributions.length; i++) {
      sum += int.parse(contributions[i].amount);
    }
    return sum;
  }

  BottomAppBar bottomAppBar() {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      color: Theme.of(context).primaryColor.withAlpha(255),
      elevation: 0,
      child: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: 0,
        selectedItemColor: Color(0xFF442BEB),
        elevation: 15.0,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule_outlined, size: 35),
            label: 'Home',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 35), label: 'Edit')
        ],
      ),
    );
  }

  Row indicatorRow(int goalMoney, int index) {
    countContribution(index);
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
              center: Text('${(_amountGoal / goalMoney) * 100} %',
                  style: TextStyle(fontSize: 13)),
              percent: _amountGoal / goalMoney,
              restartAnimation: true,
              linearStrokeCap: LinearStrokeCap.roundAll,
              progressColor: Color(0xFF442BEB),
            )),
      ],
    );
  }

  Row underIndicatorRow(String currentAmount, String goalAmount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
            child: Text(currentAmount),
            padding: EdgeInsets.symmetric(horizontal: 25)),
        Padding(
            child: Text(goalAmount),
            padding: EdgeInsets.symmetric(horizontal: 25)),
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
                  color: Color(0xFF442BEB)),
            ),
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 25)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 25),
            Text('${goals.title}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
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
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 35),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Ваши цели',
              style: TextStyle(
                  color: Colors.grey[600], fontWeight: FontWeight.bold)),
          Padding(
              padding: EdgeInsets.only(left: 85),
              child: TabBar(
                  indicatorColor: Color(0xFF442BEB),
                  indicatorWeight: 3.5,
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
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

  Container header() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 55, horizontal: 15),
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
                Icon(Icons.euro, color: Color(0xFF442BEB)),
                SizedBox(width: 5),
                Text(sumContributions().toString(),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 45))
              ],
            )
          ]),
          Column(children: [
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
