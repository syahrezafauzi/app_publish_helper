import 'package:app_updater_flutter/component/divider.dart';
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
                  onTap: () => controller.onSelectProject(item),
                  child: ListTile(
                    title: Text(item["name"] ?? "project.name"),
                  ),
                );
              },
            ),
          ],
        ),
        Divider_(),
        SectionView(
          title: "Mobile Flutter",
          children: [
            ListView.builder(
              shrinkWrap: true,
              itemCount: controller.mobile.length,
              itemBuilder: (context, index) {
                var item = controller.mobile[index];
                return InkWell(
                  onTap: () => controller.onSelectProject(item),
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
            title: ".Net",
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      _button(
                        "Publish to Local",
                        loading: ["build"],
                        onTap: () {
                          controller.netPublishLocal();
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
                  Divider_(),
                  Row(
                    children: [
                      _button(
                        "Publish to Dev",
                        loading: ["build"],
                        onTap: () {
                          controller.netPublishDev();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SectionView(
            title: "Melos",
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      _button(
                        "patient:appbundle",
                        loading: ["melos"],
                        onTap: () {
                          controller.melosRun("patient:appbundle");
                        },
                      ),
                      VerticalDivider(),
                      _button(
                        "patient:ipa",
                        loading: ["melos"],
                        onTap: () {
                          controller.melosRun("patient:ipa");
                        },
                      ),
                    ],
                  ),
                  Divider_(),
                  Row(
                    children: [
                      _button(
                        "staff:appbundle",
                        loading: ["melos"],
                        onTap: () {
                          controller.melosRun("staff:appbundle");
                        },
                      ),
                      VerticalDivider(),
                      _button(
                        "staff:ipa",
                        loading: ["melos"],
                        onTap: () {
                          controller.melosRun("staff:ipa");
                        },
                      ),
                    ],
                  ),
                  Divider_(),
                  Row(
                    children: [
                      _button(
                        "pull",
                        loading: ["melos"],
                        onTap: () {
                          controller.melosRun("pull");
                        },
                      ),
                      VerticalDivider(),
                      _button(
                        "pUSh",
                        loading: ["melos"],
                        onTap: () {
                          controller.melosRun("pUSh");
                        },
                      ),
                    ],
                  ),
                  Divider_(),
                  Row(
                    children: [
                      _button(
                        "rEMoVe:pubspec.lock",
                        loading: ["melos"],
                        onTap: () {
                          controller.melosRun("rEMoVe:pubspec.lock");
                        },
                      ),
                      VerticalDivider(),
                      _button(
                        "rEMoVe:pubspec.lock:ios",
                        loading: ["melos"],
                        onTap: () {
                          controller.melosRun("rEMoVe:pubspec.lock:ios");
                        },
                      ),
                    ],
                  ),
                  Divider_(),
                  Row(
                    children: [
                      _button(
                        "get",
                        loading: ["melos"],
                        onTap: () {
                          controller.melosRun("get");
                        },
                      ),
                      VerticalDivider(),
                      _button(
                        "clean",
                        loading: ["melos"],
                        onTap: () {
                          controller.melosRun("clean");
                        },
                      ),
                    ],
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
                    "Open ${tagName()}",
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
                  VerticalDivider(),
                  _button(
                    "Fetch",
                    loading: ["git"],
                    onTap: () {
                      controller.fetch();
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  _button(
                    "Tag ${tagName()}",
                    loading: ["git"],
                    onTap: () {
                      controller.tag("PRD");
                    },
                  ),
                  VerticalDivider(),
                  _button(
                    "Tag Push ${tagName()}",
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
              Divider(),
              Row(
                children: [
                  _button(
                    "PRD",
                    loading: ["git"],
                    onTap: () {
                      controller.checkoutBranch("PRD");
                    },
                  ),
                  VerticalDivider(),
                  _button(
                    "production",
                    loading: ["git"],
                    onTap: () {
                      controller.checkoutBranch("production");
                    },
                  ),
                  VerticalDivider(),
                  _button(
                    "master",
                    loading: ["git"],
                    onTap: () {
                      controller.checkoutBranch("master");
                    },
                  ),
                  VerticalDivider(),
                  _button(
                    "...Branch",
                    loading: ["git"],
                    onTap: () async {
                      var value = await controller.branchList();
                      var list = RxList([]);
                      list.value = value ?? [];
                      var textController = TextEditingController();
                      textController.addListener(() {
                        var filter = value?.where((p0) => p0
                            .toLowerCase()
                            .contains(textController.text.toLowerCase()));
                        list.value = filter?.toList() ?? [];
                      });
                      var focus = FocusNode();
                      await showModalBottomSheet(
                        context: Get.context!,
                        builder: (context) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              SectionView(
                                title: "Branch List",
                                children: [
                                  TextField(
                                    focusNode: focus,
                                    autofocus: true,
                                    controller: textController,
                                    decoration:
                                        InputDecoration(hintText: "Search"),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Obx(() => ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: list.length,
                                        itemBuilder: (context, index) =>
                                            Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(children: [
                                            _button(
                                              "Checkout",
                                              onTap: () async {
                                                await controller.checkoutBranch(
                                                    list[index]);
                                                focus.requestFocus();
                                              },
                                              loading: ["git", "git-checkout"],
                                            ),
                                            VerticalDivider(),
                                            Text(list[index] ?? ""),
                                          ]),
                                        ),
                                      )),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                      textController.dispose();
                    },
                  ),
                ],
              )
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
      actions: [
        IconButton(
          onPressed: () {
            controller.clearConsole();
          },
          icon: Icon(
            Icons.delete,
            color: Colors.grey,
          ),
        ),
      ],
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
              Row(
                children: [
                  Obx(() => Text(controller.branch.value ?? "[branch]")),
                  VerticalDivider(),
                  Obx(() => controller.outgoing.value != null
                      ? _outgoing()
                      : SizedBox.shrink()),
                  VerticalDivider(),
                  Obx(() => controller.incoming.value != null
                      ? _incoming()
                      : SizedBox.shrink()),
                ],
              ),
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

  Widget _incoming() {
    var count = controller.incoming.value ?? 0;
    var good = count > 0 ? Colors.green : null;
    return Text(
      "$count incoming",
      style: TextStyle(color: good),
    );
  }

  _outgoing() {
    var count = controller.outgoing.value ?? 0;
    var good = count > 0 ? Colors.green : null;
    return Text(
      "$count outgoing",
      style: TextStyle(color: good),
    );
  }

  tagName() {
    return "PRD-${controller.versionNumber}";
  }
}
