import 'package:flutter/material.dart';
import 'package:dart_ipify/dart_ipify.dart';
import 'blur_wrapper.dart';
import 'lit_share_device_card.dart';
import 'package:http/http.dart' as http;

Future<String> manualPubIP() async{
  var url = Uri.https("api64.ipify.org");
  var response = await http.get(url);
  return response.body;
}

class LitShareView extends StatefulWidget{
  const LitShareView({super.key});

  @override
  State<StatefulWidget> createState() => LitShareViewState();
}

class LitShareViewState extends State<LitShareView>
    with AutomaticKeepAliveClientMixin<LitShareView>{
  String myIP = "";
  Set<String> shareList = {};
  final _pageController = PageController(initialPage: 0);
  var _currentPage = 0;

  Future<void> updateMyIP() async {
    Ipify.ipv64().then((value) {
      setState(() { myIP = value; });
    }).catchError(
      (e){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    );
  }

  @override
  void initState() {
    super.initState();
    updateMyIP().ignore();
  }

  Widget makeStartLitShareServerUI(){
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: (){},
            child: const Text("Start LitShare Server",),
          )
        ],
      ),
    );
  }

  Widget makeBrowseLitShareServersUI() {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      child: (shareList.isEmpty)?
        const Text(
          "No Lit Shares detected yet",
          textAlign: TextAlign.center,
        ):
        CustomScrollView(
          slivers:[
            SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 600,
                mainAxisExtent: 72,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: shareList.length,
              itemBuilder: (BuildContext context, int index) {
                return LitShareDeviceCard(ip: shareList.toList()[index]);
              },
            )
          ]
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          BlurWrapper(
            sigma: 8,
            clipBorderRadius: BorderRadius.circular(12),
            child: NavigationRail(
              backgroundColor: Colors.white10,
              labelType: NavigationRailLabelType.none,
              destinations: const [
                NavigationRailDestination(
                  label: Text("Start Share"),
                  icon: Icon(Icons.file_download_rounded),
                  selectedIcon: Icon(Icons.file_download_rounded),
                ),
                NavigationRailDestination(
                  label: Text("Browse Shares"),
                  icon: Icon(Icons.sync_alt_outlined),
                  selectedIcon: Icon(Icons.sync_alt),
                ),
              ],
              onDestinationSelected: (idx){
                setState(() {
                  _pageController.jumpToPage(idx);
                  _currentPage = idx;
                });
              },
              selectedIndex: _currentPage,
            )
          ),
          Expanded(
            //width: 200,
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              children: [
                makeStartLitShareServerUI(),
                makeBrowseLitShareServersUI(),
              ],
              onPageChanged: (idx){
                setState(() { _currentPage = idx; });
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}