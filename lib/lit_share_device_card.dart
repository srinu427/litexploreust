import 'package:flutter/material.dart';
import 'blur_wrapper.dart';

class LitShareDeviceCard extends StatelessWidget{
  final String ip;

  const LitShareDeviceCard({super.key, required this.ip});

  @override
  Widget build(BuildContext context) {
    return BlurWrapper(
      sigma: 8,
      clipBorderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: Theme.of(context).colorScheme.outline,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(16)),
        ),
        color: Colors.transparent,
        child: InkWell(
          hoverColor: Colors.purple.withOpacity(0.4),
          focusColor: Colors.purple.withOpacity(0.6),
          highlightColor: Colors.purple.withOpacity(0.75),
          borderRadius: BorderRadius.circular(12),
          onTap: (){},
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                const Icon(Icons.desktop_windows_outlined,size: 48,),
                const SizedBox(width: 8,),
                Flexible(
                  child:Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          ip,
                          style: const TextStyle(fontSize: 16,),
                          overflow: TextOverflow.fade,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}