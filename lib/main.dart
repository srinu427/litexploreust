import 'dart:ui';

import 'package:flutter/material.dart';
import 'blur_wrapper.dart';
import 'lit_share_view.dart';
import 'explorer_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LitExplorer',
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const LitExHomePage(),
    );
  }
}

class LitExHomePage extends StatefulWidget {
  const LitExHomePage({super.key});

  @override
  State<StatefulWidget> createState() => _LitExHomePageState();
}

class _LitExHomePageState extends State<LitExHomePage> {
  int _selectedPage = 0;
  PageController _pageController = PageController(initialPage: 0);
  List<Widget> _globalPages = [];
  final _explorerKey = GlobalKey<ExplorerViewState>();
  final _litShareViewKey = GlobalKey<LitShareViewState>();

  void onNavbarTap(int idx) {
    setState(() {
      _selectedPage = idx;
      _pageController.jumpToPage(_selectedPage);
    });
  }

  @override
  void initState() {
    super.initState();
    _globalPages = [
      ExplorerView(key: _explorerKey,),
      LitShareView(key: _litShareViewKey,),
    ];
    _selectedPage = 0;
    _pageController = PageController(initialPage: _selectedPage);
  }

  @override
  Widget build(BuildContext context) {
    return
      Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/background.jpg", fit: BoxFit.cover,),
          Scaffold(
            backgroundColor: Colors.transparent,
            drawer: SafeArea(
              child: Stack(
                children: [
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: const SizedBox.expand(),
                  ),
                  NavigationDrawer(
                    backgroundColor: Colors.white10,
                    surfaceTintColor: Colors.white10,
                    shadowColor: Colors.transparent,
                    children: [
                      const DrawerHeader(child: Text("Quick Links")),
                      ListTile(
                        title: const Text("/sdcard/"),
                        onTap: () {
                          _explorerKey.currentState!
                              .setExplorerDirectory("/sdcard/");
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(40),
              child: BlurWrapper(
                sigma: 2,
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  title: const Text("LitExplorer"),
                ),
              ),
            ),
            body:WillPopScope(
              onWillPop: () async {
                return _explorerKey.currentState?.onWillPop() as Future<bool>;
              },
              child: Center(
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (idx){
                    setState(() {
                      _selectedPage = idx;
                    });
                  },
                  controller: _pageController,
                  children: _globalPages,
                ),
              ),
            ),
            bottomNavigationBar: BlurWrapper(
              sigma: 8,
              child: NavigationBar(
                elevation: 1,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.white12,
                onDestinationSelected: onNavbarTap,
                selectedIndex: _selectedPage,
                destinations: const [
                  NavigationDestination(
                    selectedIcon: Icon(Icons.folder_open,),
                    icon: Icon(Icons.folder_open_outlined),
                    label: "Explorer",
                  ),
                  NavigationDestination(
                    selectedIcon: Icon(Icons.import_export),
                    icon: Icon(Icons.import_export_outlined),
                    label: "Lit Share",
                  ),
                ],
              ),
            ),
          )
        ],
      );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}