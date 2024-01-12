import 'package:app_updater_flutter/component/divider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SectionView extends StatelessWidget {
  final String? title;
  final Function? showAll;
  final List<Widget>? children;
  final List<Widget>? actions;
  SectionView({
    this.title,
    this.showAll,
    this.children,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(
            title ?? "",
            style: Get.textTheme.titleLarge
                ?.copyWith(fontSize: 50.sp, fontWeight: FontWeight.bold),
          ),
          if (actions != null)
            Row(
              children: [...actions!],
            ),
          Spacer(),
          if (showAll != null)
            InkWell(
              child: Text(
                "Show all",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 12.sp,
                ),
              ),
            ),
        ]),
        Divider_(),
        ...addChilderen(),
      ],
    );
  }

  addChilderen() {
    var result = <Widget>[];
    children?.forEach((element) {
      result.add(element);
      result.add(Divider_());
    });
    return result;
  }
}
