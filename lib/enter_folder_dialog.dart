import 'package:flutter/material.dart';
import 'blur_wrapper.dart';

class EnterFolderDialog extends StatelessWidget{
  final TextEditingController textEditController;
  final void Function() refreshCallback;

  const EnterFolderDialog(
    {
      super.key,
      required this.textEditController,
      required this.refreshCallback
    }
  );

  @override
  Widget build(BuildContext context) {
    return BlurWrapper(
      sigma: 2,
      child: Dialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            width: 2,
            color: Theme.of(context).colorScheme.outline,
            strokeAlign: BorderSide.strokeAlignOutside
          )
        ),
        child: BlurWrapper(
          sigma: 8,
          clipBorderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.only(top: 28, left: 16, right: 16,bottom: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: textEditController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Directory Path",
                  ),
                ),
                TextButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                    refreshCallback();
                  },
                  child: const Text("Go")
                )
              ],
            ),
          )
        )
      ),
    );
  }
}