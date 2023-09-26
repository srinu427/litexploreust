import 'dart:io';
import 'package:flutter/material.dart';
import 'blur_wrapper.dart';

class FsEntryDetails{
  final FileSystemEntity entity;
  final FileStat stats;

  FsEntryDetails({required this.entity, required this.stats});
}

String getSizeString(int iSize){
  double fSize = iSize.toDouble();
  if (fSize < 1024) {
    return "${fSize.toStringAsFixed(0)} B";
  } else {
    fSize = fSize/1024.0;
  }

  if (fSize < 1024) {
    return "${fSize.toStringAsFixed(3)} KB";
  } else {
    fSize = fSize/1024.0;
  }

  if (fSize < 1024) {
    return "${fSize.toStringAsFixed(3)} MB";
  } else {
    fSize = fSize/1024.0;
  }

  return "${fSize.toStringAsFixed(3)} GB";
}

class FileFolderElement extends StatelessWidget{
  final FsEntryDetails fseDetails;
  final Function(int) tapCallback;
  final int index;

  const FileFolderElement({
    super.key,
    required this.fseDetails,
    required this.tapCallback,
    required this.index
  });

  @override
  Widget build(BuildContext context) {
    return BlurWrapper(
      clipBorderRadius: const BorderRadius.all(Radius.circular(12)),
      sigma: 16,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        color: Theme.of(context).colorScheme.primaryContainer
            .withOpacity(0.12),
        child: InkWell(
          hoverColor: Theme.of(context).colorScheme.primaryContainer
              .withOpacity(0.7),
          focusColor: Theme.of(context).colorScheme.primaryContainer
              .withOpacity(0.85),
          highlightColor: Theme.of(context).colorScheme.primaryContainer
              .withOpacity(1),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          onTap: (){ tapCallback(index);},
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                fseDetails.stats.type == FileSystemEntityType.file?
                Icon(
                  Icons.file_present_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurface,
                ):
                Icon(
                  Icons.folder_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(width: 8,),
                Flexible(
                  child:Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          fseDetails.entity.path.split("/").last,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.fade,
                        ),
                      ),
                      fseDetails.stats.type == FileSystemEntityType.file?
                      Text(
                        "Size: ${getSizeString(fseDetails.stats.size)}",
                        style: const TextStyle(fontSize: 8,),
                      ):
                      const Text(
                        "Directory",
                        style: TextStyle(fontSize: 8,),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}