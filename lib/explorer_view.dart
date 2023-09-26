import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'blur_wrapper.dart';
import 'file_folder_element.dart';
import 'enter_folder_dialog.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';


class ExplorerView extends StatefulWidget {
  const ExplorerView({Key? key}):super(key: key);

  @override
  State<ExplorerView> createState() => ExplorerViewState();
}

class ExplorerViewState extends State<ExplorerView>
    with AutomaticKeepAliveClientMixin<ExplorerView> {
  String currentDir = "/";
  List<String> previousDirs = [];
  bool haveStoragePermission = false;
  bool showHidden = false;
  bool upButtonEnabled = true;
  List<FsEntryDetails> fsEntityDetails = [];
  final ePathStore = TextEditingController();
  DateTime? lastBackPressTime;
  var navCtrl = ScrollController();

  Future<bool> tryGettingPermissionsBasedOnOpenErr(OpenResult oRes) async {
    if (Platform.isAndroid) {
      if (oRes.message.endsWith("READ_MEDIA_IMAGES")) {
        if (await Permission.photos.isDenied) {
          return Permission.photos.request().then(
            (value) => (value.isGranted)?true:false
          );
        }
      }
      else if(oRes.message.endsWith("READ_MEDIA_VIDEO")){
        if (await Permission.videos.isDenied) {
          return Permission.videos.request().then(
            (value) => (value.isGranted)?true:false
          );
        }
      }
      else if(oRes.message.endsWith("READ_MEDIA_AUDIO")){
        if (await Permission.audio.isDenied) {
          return Permission.audio.request().then(
            (value) => (value.isGranted)?true:false
          );
        }
      }
    }
    return false;
  }

  Future<void> checkAndRequestPermission() async {
    var permStatus = false;
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted) {
        permStatus = true;
      }
      if (await Permission.manageExternalStorage.isDenied) {
        var status = await Permission.manageExternalStorage.request();
        if (status == PermissionStatus.granted) { permStatus = true; }
      }
    }
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      permStatus = true;
    }
    setState(() { haveStoragePermission = permStatus; });
  }

  void goPreviousPath(){
    if (previousDirs.isNotEmpty) {
      final targetDir = previousDirs.removeLast();
      setExplorerDirectory(targetDir, addToHistory: false);
    }
  }

  Future<void> refreshFileList() async{
    checkAndRequestPermission();
    final List<FileSystemEntity> fsList;
    final List<FileStat> fsListStats;
    try {
      fsList = await Directory(currentDir).list().toList();
      fsListStats = await Future.wait(fsList.map((e) => e.stat()));
    } on Exception catch(e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            //margin: const EdgeInsets.all(8),
            padding: EdgeInsets.zero,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16))
            ),
            behavior: SnackBarBehavior.floating,
            content: BlurWrapper(
              sigma: 8,
              child: Container(
                color: Colors.white.withOpacity(0.065),
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Error opening $currentDir: $e",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface
                  ),
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
          ),
        );
      }
      goPreviousPath();
      return;
    }
    List<FsEntryDetails> combList = [];
    for (int i = 0; i < fsList.length; i++){
      combList.add(FsEntryDetails(entity: fsList[i], stats: fsListStats[i]));
    }
    if (!showHidden) {
      combList = [...combList.where((element) =>
      !element.entity.path
          .split("/")
          .last
          .startsWith(RegExp(r"(\.|\$)")))
      ];
    }
    combList.sort((a, b) => a.entity.path.toLowerCase()
        .compareTo(b.entity.path.toLowerCase()));

    final fileList = combList.where(
            (element) => element.stats.type == FileSystemEntityType.file
    );
    final folderList = combList.where(
            (element) => element.stats.type == FileSystemEntityType.directory
    );

    combList = [...folderList, ...fileList];

    setState(() {
      fsEntityDetails = combList;
      if (currentDir.split("/").length == 2) { upButtonEnabled = false; }
      else { upButtonEnabled = true; }
    });
  }

  void toggleHiddenItems(bool? checkState) {
    showHidden = !showHidden;
    refreshFileList().ignore();
  }

  void onElemClick(int i) {
    if (fsEntityDetails[i].stats.type == FileSystemEntityType.directory) {
      setExplorerDirectory(fsEntityDetails[i].entity.path);
    }
    if (fsEntityDetails[i].stats.type == FileSystemEntityType.file) {
      OpenFile.open(fsEntityDetails[i].entity.path).then(
        (value) async {
          if (value.type != ResultType.permissionDenied) return;
          tryGettingPermissionsBasedOnOpenErr(value).then(
            (pBool) {
              if (pBool){
                OpenFile.open(fsEntityDetails[i].entity.path).ignore();
              }
              else{
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Media permission not available to open",),
                  ),
                );
              }
            }
          );
        }
      );
    }
  }

  void goHierarchicalDirectoryAtDepth(int depthFromRoot) {
    var epSplit = currentDir.split("/");
    if (depthFromRoot >= epSplit.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid parent directory selected",),
        ),
      );
    }
    else{
      var pdsPath = epSplit.sublist(0, depthFromRoot);
      pdsPath.add("");
      setExplorerDirectory(pdsPath.join('/'));
    }
  }

  void goUpDir(){
    setExplorerDirectory(Directory(currentDir).parent.path);
  }

  void setExplorerDirectory(String ePath,{bool addToHistory=true}) {
    if (Directory(ePath).existsSync()) {
      if (addToHistory) { previousDirs.add(currentDir); }
      currentDir = ePath;
      if (!currentDir.endsWith("/")){ currentDir = "$currentDir/"; }
      refreshFileList().ignore();
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Directory $ePath doesn't exist",),),
      );
    }
    ePathStore.text = currentDir;
  }

  void setInputDirectory() {
    setExplorerDirectory(ePathStore.text);
  }

  Future<bool> onWillPop() async {
    if (previousDirs.isEmpty) {
      final currTime = DateTime.now();
      if (lastBackPressTime is! DateTime ||
          currTime.difference(lastBackPressTime!)
              > const Duration(seconds: 2)) {
        lastBackPressTime = currTime;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Press back again to exit.",),
            duration: Duration(seconds: 2),
          )
        );
        return false;
      }
      return true;
    }
    goPreviousPath();
    return false;
  }

  Widget makeEasyNavBar() {
    var epSplit = currentDir.split("/");
    epSplit = epSplit.sublist(0, epSplit.length - 1);

    List<Widget> rowElems = [];
    for (var i = 0; i < epSplit.length; i++){
      if (i != 0){
        rowElems.add(const SizedBox(width: 8,));
      }
      rowElems.add(
        BlurWrapper(
          clipBorderRadius: BorderRadius.circular(8),
          sigma: 4,
          child: TextButton(
            onPressed: (){ goHierarchicalDirectoryAtDepth(i + 1); },
            style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(
                  Theme.of(context).colorScheme.primaryContainer
                      .withOpacity(0.25)
              ),
              overlayColor: MaterialStatePropertyAll(
                  Theme.of(context).colorScheme.primaryContainer
                      .withOpacity(0.8)
              ),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    color: Theme.of(context).colorScheme.outline,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            child: Text(
              (epSplit[i] != "")?epSplit[i]: "/",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface
              ),
            ),
          )
        )
      );
    }

    final outSB = SizedBox(
      //padding: const EdgeInsets.only(top: 4, bottom: 4),
      height: 36,
      child: ListView(
        controller: navCtrl,
        scrollDirection: Axis.horizontal,
        children: rowElems,
      ),
    );
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      navCtrl.jumpTo(navCtrl.position.maxScrollExtent);
    });
    return outSB;
  }

  Widget makeToolBar() {
    var chList = [
      IconButton(
        icon: const Icon(Icons.refresh_rounded,),
        onPressed: refreshFileList,
      ),
      const SizedBox(width: 8,),
      IconButton(
        icon: const Icon(Icons.arrow_upward_rounded,),
        onPressed: (currentDir.split('/').length > 2)?goUpDir:null,
      ),
      const SizedBox(width: 8,),
      IconButton(
        icon: const Icon(Icons.folder_open_rounded,),
        onPressed: (){
          showDialog(
              context: context,
              builder: (context){
                return EnterFolderDialog(
                    textEditController: ePathStore,
                    refreshCallback: setInputDirectory
                );
              }
          );
        },
      ),
      const Spacer(),
      const Text("Show Hidden Items"),
      Switch(
        inactiveTrackColor: Colors.transparent,
        value: showHidden,
        onChanged: toggleHiddenItems,
      ),
      //Checkbox(value: showHidden, onChanged: toggleHiddenItems,),

    ];

    if (!Platform.isAndroid){
      chList.insert(0, const SizedBox(width: 8));
      chList.insert(
        0,
        IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: (previousDirs.isNotEmpty)?goPreviousPath:null,
          disabledColor: Colors.grey,
        ),
      );
    }

    return Row(children: chList);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState(){
    if (Platform.isAndroid){ currentDir = "/storage/emulated/0/"; }
    else{ currentDir = "/"; }
    ePathStore.text = currentDir;
    refreshFileList().ignore();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Column(
        children: [
          makeToolBar(),
          //const SizedBox(height: 8,),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  floating: true,
                  snap: true,
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  title: makeEasyNavBar(),
                ),
                (haveStoragePermission)?
                (fsEntityDetails.isNotEmpty)?
                SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 480,
                    mainAxisExtent: 72,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: fsEntityDetails.length,
                  itemBuilder: (BuildContext context, int index) {
                    final ffElem = FileFolderElement(
                      fseDetails: fsEntityDetails[index],
                      tapCallback: onElemClick,
                      index: index,
                    );
                    return ffElem;
                  },
                ):
                const SliverFillRemaining(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Folder Empty", textAlign: TextAlign.center,),
                    ],
                  ) ,
                ):
                const SliverFillRemaining(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "No Storage Permission",
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ) ,
                ),
              ]
            ),
          )
        ],
      ),
    );
  }
}