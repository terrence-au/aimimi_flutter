import 'package:aimimi/constants/styles.dart';
import 'package:aimimi/models/rank.dart';
import 'package:aimimi/models/user.dart';
import 'package:aimimi/services/goal_service.dart';
import 'package:aimimi/widgets/rank/rank.dart';
import 'package:aimimi/widgets/rank/rank_top.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LeaderboardView extends StatefulWidget {
  @override
  _LeaderboardViewState createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<LeaderboardView> {
  String _selectedGoalID;
  List<Rank> ranks = [];
  bool _first = false;

  @override
  void initState() {
    super.initState();
    _first = true;
  }

  @override
  Widget build(BuildContext context) {
    if (_first) {
      _selectedGoalID = getFirstGoal();
      _first = false;
    }
    print(_selectedGoalID);

    return StreamBuilder<List<JoinedUser>>(
      stream: GoalService(goalID: _selectedGoalID).joinedUsers,
      builder: (context, snapshot) {
        List<JoinedUser> userlist = snapshot.data ?? [];
        userlist.sort((a, b) => a.accuracy.compareTo(b.accuracy));
        ranks.clear();
        for (var data in userlist.reversed) {
          ranks.add(Rank(
              uid: data.uid, username: data.username, accuracy: data.accuracy));
        }
        print(userlist);
        //3 or less users in a goal.
        if (userlist.length < 4 && userlist.length != 0) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
              child: Column(children: [
                _buildSelectDropdown(),
                SizedBox(height: 10),
                _buildTopRankContainer(userlist.length),
              ]),
            ),
          );
        }
        //0 user in a goal.
        else if (userlist.length == 0) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            child: Column(children: [
              _buildSelectDropdown(),
            ]),
          );
        }
        //>4 users in a goal.
        else {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
              child: Column(children: [
                _buildSelectDropdown(),
                SizedBox(height: 10),
                _buildTopRankContainer(userlist.length),
                SizedBox(height: 15),
                _buildRankContainer(),
              ]),
            ),
          );
        }
      },
    );
  }

  Container _buildRankContainer() {
    List<RankItem> rankItems = _buildRanks();
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(18))),
      padding: EdgeInsets.only(left: 14, right: 14, top: 20, bottom: 20),
      child: ListView.builder(
          itemCount: rankItems.length,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return rankItems[index];
          }),
    );
  }

  Container _buildTopRankContainer(int length) {
    return Container(
      width: double.infinity,
      height: 167,
      decoration: BoxDecoration(
          color: themeColor,
          borderRadius: BorderRadius.all(Radius.circular(18))),
      padding: EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: length > 2
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: _buildTopRanks(length),
      ),
    );
  }

  List<Widget> _buildTopRanks(int length) {
    if (length == 1) {
      List<Widget> rearrange(list) {
        return list;
      }

      return rearrange(ranks.sublist(0, 1).asMap().entries.map((entry) {
        int index = entry.key;
        Rank rank = entry.value;
        return TopRank(
          uid: rank.uid,
          username: rank.username,
          accuracy: rank.accuracy,
          index: index,
          length: length,
        );
      }).toList());
    } else if (length == 2) {
      List<Widget> rearrange(list) {
        list.insert(0, list.removeAt(1));
        return list;
      }

      return rearrange(ranks.sublist(0, 2).asMap().entries.map((entry) {
        int index = entry.key;
        Rank rank = entry.value;
        return TopRank(
          uid: rank.uid,
          username: rank.username,
          accuracy: rank.accuracy,
          index: index,
          length: length,
        );
      }).toList());
    } else {
      List<Widget> rearrange(list) {
        list.insert(0, list.removeAt(1));
        return list;
      }

      return rearrange(ranks.sublist(0, 3).asMap().entries.map((entry) {
        int index = entry.key;
        Rank rank = entry.value;
        return TopRank(
          uid: rank.uid,
          username: rank.username,
          accuracy: rank.accuracy,
          index: index,
          length: length,
        );
      }).toList());
    }
  }

  List<Widget> _buildRanks() {
    return ranks.sublist(3).asMap().entries.map((entry) {
      int index = entry.key;
      Rank rank = entry.value;
      return RankItem(
        uid: rank.uid,
        username: rank.username,
        accuracy: rank.accuracy,
        index: index + 4,
      );
    }).toList();
  }

  Align _buildSelectDropdown() {
    List<UserGoal> goalList = getGoals();
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: DropdownButton<String>(
          value: _selectedGoalID,
          dropdownColor: Colors.white,
          isDense: true,
          underline: SizedBox(),
          hint: Text("Select"),
          style: TextStyle(
            fontFamily: "Roboto",
            color: monoPrimaryColor,
            fontWeight: FontWeight.w600,
          ),
          icon: Icon(
            Icons.arrow_drop_down_outlined,
            color: monoSecondaryColor,
          ),
          iconSize: 28,
          items: goalList.map((item) {
            return DropdownMenuItem(
              child: Text(item.goal.title),
              value: item.goalID,
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedGoalID = value;
            });
          },
        ),
      ),
    );
  }

  List<UserGoal> getGoals() {
    List<UserGoal> goals = Provider.of<List<UserGoal>>(context);
    return goals;
  }

  String getFirstGoal() {
    List<UserGoal> goals = Provider.of<List<UserGoal>>(context);
    if (goals.isNotEmpty) {
      return goals[0].goalID;
    } else {
      return null;
    }
  }

  Stream<List<JoinedUser>> getUserList() {
    Stream<List<JoinedUser>> userlist = GoalService(
      goalID: _selectedGoalID,
    ).joinedUsers;

    return userlist;
  }
}
