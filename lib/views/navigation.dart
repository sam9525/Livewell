import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../shared/shared.dart';
import 'home_page.dart';
import 'goal_page.dart';
import 'notice_page.dart';
import 'profile_page.dart';
import 'chatbot_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;

  Widget buildNavigationDestination(String icon, String label, int index) {
    return NavigationDestination(
      icon: SvgPicture.asset(
        'assets/icons/$icon.svg',
        height: 52,
        width: 52,
        colorFilter: currentPageIndex == index
            ? ColorFilter.mode(Shared.orange, BlendMode.srcIn)
            : ColorFilter.mode(Shared.lightGray, BlendMode.srcIn),
      ),
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            height: 100,
            labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
              (Set<WidgetState> states) => states.contains(WidgetState.selected)
                  ? Shared.fontStyle(
                      20,
                      FontWeight.w500,
                      Shared.orange,
                    ) // selected label color
                  : Shared.fontStyle(
                      20,
                      FontWeight.w500,
                      Shared.lightGray,
                    ), // unselected label color
            ),
            iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
              (Set<WidgetState> states) => states.contains(WidgetState.selected)
                  ? IconThemeData(color: Shared.orange)
                  : IconThemeData(color: Shared.lightGray),
            ),
          ),
          child: NavigationBar(
            backgroundColor: Colors.white,
            indicatorColor: Colors.transparent,
            selectedIndex: currentPageIndex,
            onDestinationSelected: (index) {
              setState(() {
                currentPageIndex = index;
              });
            },
            destinations: [
              buildNavigationDestination('home', 'Home', 0),
              buildNavigationDestination('book', 'Goal', 1),
              buildNavigationDestination('bell', 'Notice', 2),
              buildNavigationDestination('user', 'Profile', 3),
              buildNavigationDestination('chatbot', 'Chatbot', 4),
            ],
          ),
        ),
      ),
      body: <Widget>[
        Home.homePageText(context),
        Goal.goalPage(context),
        Notice.noticePage(context),
        Profile.profilePage(context),
        Chatbot.chatbotPage(context),
      ][currentPageIndex],
    );
  }
}
