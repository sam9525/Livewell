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

// Helper class to store route data
class _RouteData {
  final String label;
  final String icon;
  final Widget Function(BuildContext) builder;

  const _RouteData(this.label, this.icon, this.builder);
}

class _HomePageState extends State<HomePage> {
  String currentRoute = '/home';
  List<String> navigationHistory = ['/home'];

  static final Map<String, _RouteData> routes = {
    '/home': _RouteData('Home', 'home', (context) => const Home()),
    '/goal': _RouteData('Goal', 'book', (context) => const Goal()),
    '/notice': _RouteData('Notice', 'bell', Notice.noticePage),
    '/profile': _RouteData('Profile', 'user', Profile.profilePage),
    '/chatbot': _RouteData('Chatbot', 'chatbot', Chatbot.chatbotPage),
  };

  Widget buildNavigationDestination(String icon, String label) {
    return NavigationDestination(
      icon: SvgPicture.asset(
        'assets/icons/$icon.svg',
        height: 52,
        width: 52,
        colorFilter: ColorFilter.mode(
          currentRoute == '/${label.toLowerCase()}'
              ? Shared.orange
              : Shared.lightGray,
          BlendMode.srcIn,
        ),
      ),
      label: label,
    );
  }

  Future<bool?> _shouldPop() async {
    // If we're on home page and there's no history, allow app to close
    if (currentRoute == '/home' && navigationHistory.length <= 1) {
      return true;
    }

    navigateBack();
    return false;
  }

  Future<void> navigateToRoute(String route) async {
    setState(() {
      currentRoute = route;
      navigationHistory.add(route);
    });
  }

  Future<void> navigateBack() async {
    setState(() {
      if (navigationHistory.length > 1) {
        navigationHistory.removeLast();
        currentRoute = navigationHistory.last;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        final bool shouldPop = await _shouldPop() ?? false;
        if (context.mounted && shouldPop) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
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
            data: _buildNavigationBarTheme(),
            child: _buildNavigationBar(),
          ),
        ),
        body:
            routes[currentRoute]?.builder(context) ??
            routes['/home']!.builder(context),
      ),
    );
  }

  NavigationBarThemeData _buildNavigationBarTheme() {
    return NavigationBarThemeData(
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
    );
  }

  NavigationBar _buildNavigationBar() {
    return NavigationBar(
      backgroundColor: Colors.white,
      indicatorColor: Colors.transparent,
      selectedIndex: routes.keys.toList().indexOf(currentRoute),
      onDestinationSelected: (index) {
        navigateToRoute(routes.keys.toList()[index]);
      },
      destinations: routes.values
          .map((route) => buildNavigationDestination(route.icon, route.label))
          .toList(),
    );
  }
}
