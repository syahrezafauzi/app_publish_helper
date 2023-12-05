import 'package:app_updater_flutter/component/sectioned_view.dart';
import 'package:app_updater_flutter/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class HomePage extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('App Updater')),
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(child: _content()),
              _footer(),
            ],
          ),
        )));
  }

  Row _content() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _projectList(),
        ),
        Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _updateForm()),
              ],
            )),
      ],
    );
  }

  Column _projectList() {
    return Column(
      children: [
        SectionView(
          title: "Website .Net",
          children: [
            ListView.builder(
              shrinkWrap: true,
              itemCount: controller.website.length,
              itemBuilder: (context, index) {
                var item = controller.website[index];
                return InkWell(
                  onTap: () => controller.selectWebsite(item),
                  child: ListTile(
                    title: Text(item["name"] ?? "project.name"),
                  ),
                );
              },
            ),
          ],
        )
      ],
    );
  }

  Widget _updateForm() {
    return Obx(() {
      if (controller.project.value == null)
        return SizedBox.expand(
          child: Center(
            child: Text("No Project selected"),
          ),
        );
      else {
        return Column(
          children: [
            ..._projectInfo(),
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row1(),
                  VerticalDivider(),
                  _row2(),
                ],
              ),
            ),
          ],
        );
      }
    });
  }

  Widget _row2() {
    return Expanded(
      child: Column(
        children: [
          SectionView(
            title: "Publish",
            children: [
              Row(
                children: [
                  _button(
                    "Build",
                    loading: ["build"],
                    onTap: () {
                      controller.build();
                    },
                  ),
                  VerticalDivider(),
                  _button(
                    "Copy to Clipboard",
                    loading: ["build"],
                    onTap: () {
                      controller.netCopy();
                    },
                  ),
                ],
              ),
            ],
          ),
          SectionView(
            title: "Bitbucket",
            children: [
              Row(
                children: [
                  _button(
                    "Open PRD",
                    loading: ["bitbucket"],
                    onTap: () {
                      controller.openBitbucket("PRD");
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row1() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SectionView(
            title: "Version",
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _button("Minor +1", onTap: () {
                    controller.increaseMinor();
                  }),
                  VerticalDivider(),
                  _button("Patch +1", onTap: () {
                    controller.increasePatch();
                  }),
                  Spacer(),
                  VerticalDivider(),
                  _button(
                    "Reset",
                    loading: ["git"],
                    onTap: () {
                      controller.resetVersion();
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  _button(
                    "Commit",
                    loading: ["git"],
                    onTap: () {
                      controller.commit();
                    },
                  ),
                ],
              ),
            ],
          ),
          SectionView(
            title: "Git",
            children: [
              Row(
                children: [
                  _button(
                    "Pull",
                    loading: ["git"],
                    onTap: () {
                      controller.pull();
                    },
                  ),
                  VerticalDivider(),
                  _button(
                    "Push",
                    loading: ["git"],
                    onTap: () {
                      controller.push();
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  _button(
                    "Tag PRD",
                    loading: ["git"],
                    onTap: () {
                      controller.tag("PRD");
                    },
                  ),
                  VerticalDivider(),
                  _button(
                    "Tag PRD Push",
                    loading: ["git"],
                    onTap: () {
                      controller.pushTag("PRD");
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  _button(
                    "Reset",
                    loading: ["git"],
                    onTap: () {
                      controller.reset();
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _button(
    String text, {
    Function()? onTap,
    List<String>? loading,
  }) {
    return Obx(() {
      var _loading = controller.isLoading(loading);
      return FilledButton.tonal(
        onPressed: _loading ? null : onTap,
        child: Text(text),
      );
    });
  }

  _footer() {
    return SectionView(
      title: "Output",
      children: [
        SizedBox(
          height: 100,
          // child: Text.rich(TextSpan(text: controller.output)),
          child: TextField(
            maxLines: null,
            readOnly: true,
            scrollController: controller.outputScroll,
            controller: controller.output,
            style: TextStyle(fontSize: 13.sp),
          ),
        ),
      ],
    );
  }

  List<Widget> _projectInfo() {
    return [
      Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(controller.project.value["name"].toString()),
              Obx(() => Text(controller.branch.value ?? "[branch]")),
            ],
          ),
          Spacer(),
          Obx(
            () => Text(controller.versionNumber.value ?? "[version]"),
          )
        ],
      ),
      Divider(),
    ];
  }
}
