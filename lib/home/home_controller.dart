import 'dart:io';

import 'package:app_updater_flutter/component/model/text_part_style_definition.dart';
import 'package:app_updater_flutter/component/model/text_part_style_definitions.dart';
import 'package:app_updater_flutter/component/styleable_text_field_controller.dart';
import 'package:app_updater_flutter/helper/cmd_helper.dart';
import 'package:app_updater_flutter/helper/dot_net_helper.dart';
import 'package:app_updater_flutter/helper/flutter_helper.dart';
import 'package:app_updater_flutter/helper/git_helper.dart';
import 'package:app_updater_flutter/helper/melos_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:collection/collection.dart';

class HomeController extends GetxController {
  var website = [
    {
      "name": "Website MTMH (www.rsmurniteguh.com)",
      "path":
          "C:\\Users\\USER\\Documents\\Projects\\Websites\\MurniTeguhNetCore",
      "csproj": "MurniTeguhNetCoreMVC\\MurniTeguhNetCoreMVC.csproj",
      "projectName": "MurniTeguhNetCoreMVC",
    },
    {
      "name": "Eclaim (eclaim.rsmurniteguh.app)",
      "path": "C:\\Users\\USER\\Documents\\Projects\\Websites\\MTMHEclaim",
      "csproj": "E-Claim.csproj",
      "projectName": "Eclaim",
    },
    {
      "name": "MTMHAdmin",
      "path":
          "C:\\Users\\USER\\Documents\\Projects\\Websites\\MTMHAdmin\\MTMHAdmin",
      "csproj": "MTMHAdmin.csproj",
      "projectName": "MTMHAdmin",
    },
    {
      "name": "MTWebEmoney",
      "path":
          "C:\\Users\\USER\\Documents\\Projects\\Websites\\MTEmoney\\MTWebEmoney",
      "csproj": "MTWebEmoney.csproj",
      "projectName": "MTWebEmoney",
    }
  ];
  var mobile = [
    {
      "name": "Mobile Patient",
      "path": "D:\\projects\\mtmobile\\mtmobile-patient",
      "path_macos":
          "/Users/mtmhaccount/Documents/mtmobile-flutter/mtmobile-patient",
      "lang": "flutter"
    },
    {
      "name": "Mobile Staff",
      "path": "D:\\projects\\mtmobile\\mtmobile-staff",
      "path_macos":
          "/Users/mtmhaccount/Documents/mtmobile-flutter/mtmobile-staff",
      "lang": "flutter"
    },
    {
      "name": "Mobile Patient 10",
      "path": "D:\\projects\\mtmobile10\\mtmobile-patient",
      "path_macos":
          "/Users/mtmhaccount/Documents/mtmobile-flutter/mtmobile-patient",
      "lang": "flutter"
    },
    {
      "name": "Mobile Staff 10",
      "path": "D:\\projects\\mtmobile10\\mtmobile-staff",
      "path_macos":
          "/Users/mtmhaccount/Documents/mtmobile-flutter/mtmobile-staff",
      "lang": "flutter"
    },
    {
      "name": "Mobile Patient 11",
      "path": "D:\\projects\\mtmobile11\\mtmobile-patient",
      "path_macos":
          "/Users/mtmhaccount/Documents/mtmobile-flutter/mtmobile-patient",
      "lang": "flutter"
    },
    {
      "name": "Mobile Staff 11",
      "path": "D:\\projects\\mtmobile11\\mtmobile-staff",
      "path_macos":
          "/Users/mtmhaccount/Documents/mtmobile-flutter/mtmobile-staff",
      "lang": "flutter"
    },
    {
      "name": "Dashboard OT",
      "path": "D:\\projects\\dashboard_ot",
      "path_macos": "",
      "lang": "flutter"
    }
  ];
  var project = Rxn();
  var branch = RxnString();
  var versionNumber = RxnString();

  var outputController = StyleableTextFieldController(
    styles: TextPartStyleDefinitions(
      definitionList: <TextPartStyleDefinition>[
        // TextPartStyleDefinition(
        //   style: const TextStyle(
        //     color: Colors.green,
        //     fontWeight: FontWeight.bold,
        //   ),
        //   pattern: '[\.,\?\!]',
        // ),
        // TextPartStyleDefinition(
        //   style: const TextStyle(
        //     color: Colors.red,
        //     fontWeight: FontWeight.bold,
        //   ),
        //   pattern: '(?:(the|a|an) +)',
        // ),
        // TextPartStyleDefinition(
        //   style: const TextStyle(
        //     color: Colors.red,
        //     fontWeight: FontWeight.bold,
        //   ),
        //   pattern: '<error>(.*?)</error>',
        // ),
        TextPartStyleDefinition(
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.normal,
          ),
          pattern: '\\+',
        ),
        TextPartStyleDefinition(
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.normal,
          ),
          pattern: '\\-',
        ),
        TextPartStyleDefinition(
          style: TextStyle(
            color: Colors.orange.shade200,
            fontWeight: FontWeight.normal,
          ),
          pattern: 'melos run.*',
        ),
        TextPartStyleDefinition(
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
          pattern: '└> SUCCESS',
        ),
        TextPartStyleDefinition(
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
          pattern: '└> FAILED',
        ),
        TextPartStyleDefinition(
          style: TextStyle(
            color: Colors.orange.shade200,
            fontWeight: FontWeight.bold,
          ),
          pattern: '└> RUNNING',
        ),
        TextPartStyleDefinition(
          style: TextStyle(
            color: Colors.lightBlue.shade200,
            fontWeight: FontWeight.normal,
          ),
          pattern: '└>.*',
        ),
      ],
    ),
  );
  late GitHelper gitHelper;
  late DotNetHelper dotNetHelper;
  late FlutterHelper flutterHelper;
  late MelosHelper melosHelper;

  var outputScroll = ScrollController();

  var loading = RxList<String>([]);

  var incoming = Rx<int?>(null);
  var outgoing = Rx<int?>(null);

  var output = Rx<String>("");

  get path =>
      Platform.isMacOS ? project.value["path_macos"] : project.value["path"];
  get separator => Platform.isMacOS ? "/" : "\\";

  bool isLoading(List<String>? category) {
    return loading.any((element) => category?.contains(element) ?? false);
  }

  late CmdHelper cmdHelper;

  HomeController() {
    cmdHelper = CmdHelper(
      onOutput: (p0) {
        _printOutput(p0);
      },
      onError: (p0) {
        _printOutput(p0, color: Colors.red);
      },
    );

    gitHelper = GitHelper(
      cmdHelper: cmdHelper,
      onOutput: (p0) {
        _printOutput(p0);
      },
      onError: (p0) {
        _printOutput(p0, color: Colors.red);
      },
    );
    dotNetHelper = DotNetHelper(
      cmdHelper: cmdHelper,
      onOutput: (p0) {
        _printOutput(p0);
      },
      onError: (p0) {
        _printOutput(p0, color: Colors.red);
      },
    );
    flutterHelper = FlutterHelper(
      cmdHelper: cmdHelper,
      onOutput: (p0) {
        _printOutput(p0);
      },
      onError: (p0) {
        _printOutput(p0, color: Colors.red);
      },
    );
    melosHelper = MelosHelper(
      cmdHelper: cmdHelper,
      onOutput: (p0) {
        _printOutput(p0);
      },
      onError: (p0) {
        _printOutput(p0, color: Colors.red);
      },
    );
  }

  void _printOutput(String p0, {MaterialColor? color}) {
    DateFormat format = DateFormat("HH:mm:ss");
    var date = format.format(DateTime.now());
    outputController.text += "\n$date: $p0";
    Future.delayed(Duration(milliseconds: 500), () {
      outputController.selection = TextSelection.fromPosition(
          TextPosition(offset: outputController.text.length));
      outputScroll.position.didEndScroll();
      outputScroll.jumpTo(outputScroll.position.maxScrollExtent);
    });
  }

  @override
  void onInit() {
    super.onInit();
    outputController.addListener(() {
      output.value = outputController.text;
    });
  }

  void _action(Function() action) {}

  Future<String?> refreshProjectInfo() async {
    await getVersion();
    await getBranch();
    getOutgoing();
    getIncoming();
  }

  Future<String?> getVersion() async {
    String? version;

    var lang = project.value["lang"];
    if (lang == "flutter") {
      version = await flutterHelper.getVersion(path);
      version = version?.split("+").firstOrNull;
    } else {
      var csproj = project.value["csproj"];
      var combine = [path, csproj].join(separator);
      version = await dotNetHelper.getVersion(combine);
    }

    versionNumber.value = version ?? "[version]";
    return version;
  }

  Future<String?> getBranch() async {
    return await action(
        loading: ["git"],
        task: () async {
          this.branch.value = "[branch]";
          var branch = await gitHelper.getBranch(path);
          this.branch.value = branch;
          return branch;
        });
  }

  Future<String?> getOutgoing() async {
    return await action(
        loading: ["git"],
        task: () async {
          var branch = this.branch.value ?? "";
          var count = await gitHelper.outgoing(branch, path);
          this.outgoing.value = int.parse(count);
          return count;
        });
  }

  Future<String?> getIncoming() async {
    return await action(
        loading: ["git"],
        task: () async {
          var branch = this.branch.value ?? "";
          var count = await gitHelper.incoming(branch, path);
          this.incoming.value = int.parse(count);
          return count;
        });
  }

  onSelectProject(item) async {
    project.value = item;
    refreshProjectInfo();
  }

  void increasePatch() async {
    var lang = project.value["lang"];
    if (lang == "flutter") {
      await flutterHelper.increaseVersion(path, patch: 1);
    } else {
      var csproj = project.value["csproj"];
      var combine = [path, csproj].join(separator);
      await dotNetHelper.increaseVersion(combine, patch: 1);
    }

    await refreshProjectInfo();
  }

  void increaseMinor() async {
    var lang = project.value["lang"];
    if (lang == "flutter") {
      await flutterHelper.increaseVersion(path, minor: 1);
    } else {
      var csproj = project.value["csproj"];
      var combine = [path, csproj].join(separator);
      await dotNetHelper.increaseVersion(combine, minor: 1, patch: 0);
    }

    await refreshProjectInfo();
  }

  void resetVersion() async {
    await action(
        loading: ["git"],
        task: () async {
          var lang = project.value["lang"];
          var file;
          if (lang == "flutter") {
            file = [path, "pubspec.yaml"].join(separator);
          } else {
            var csproj = project.value["csproj"];
            file = [path, csproj].join(separator);
          }
          await gitHelper.resetVersion(file);
          await refreshProjectInfo();
        });
  }

  void commit() async {
    await action(
        loading: ["git"],
        task: () async {
          var lang = project.value["lang"];
          var file;

          if (lang == "flutter") {
            file = [path, "pubspec.yaml"].join(separator);
          } else {
            var csproj = project.value["csproj"];
            file = [path, csproj].join(separator);
          }

          await gitHelper.commit(
            path,
            file,
            message: "up-v$versionNumber",
          );
        });
    refreshProjectInfo();
  }

  void push() async {
    await action(
        loading: ["git"],
        task: () async {
          await gitHelper.push(
            path,
          );
        });
    refreshProjectInfo();
  }

  void tag(String prefix) async {
    await action(
        loading: ["git"],
        task: () async {
          await gitHelper.tag(path, "$prefix-$versionNumber");
        });
  }

  void pushTag(String prefix) async {
    await action(
        loading: ["git"],
        task: () async {
          await gitHelper.tagPush(path, "$prefix-$versionNumber");
        });
  }

  void openBitbucket(String prefix) async {
    await action(
        loading: ["bitbucket"],
        task: () async {
          var url = await gitHelper.getRemoteUrl(path);
          url = url?.replaceAll(".git", "");
          var uri = Uri.parse("$url/commits/tag/$prefix-$versionNumber");
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        });
  }

  void pull() async {
    await action(
      loading: ["git"],
      task: () async {
        await gitHelper.pull(path);
      },
    );
    refreshProjectInfo();
  }

  action({required Future Function() task, List<String>? loading}) async {
    setLoading(true, loading ?? []);
    var result = await task().onError((error, stackTrace) {
      var message = error.toString();
      if(error is ProcessException){
        message = error.message;
      }
      _printOutput(message, color: Colors.red);
    });
    setLoading(false, loading ?? []);
    return result;
  }

  void reset() async {
    await action(
      loading: ["git"],
      task: () async {
        await Get.defaultDialog(
          title: "Warning",
          middleText: "Confirm reset to origin?",
          textConfirm: "Confirm",
          onConfirm: () async {
            await gitHelper.reset(path);
            await refreshProjectInfo();
            Get.back();
          },
        );
      },
    );
  }

  void setLoading(bool bool, List<String> list) {
    if (bool) {
      loading.addAll(list);
    } else {
      loading.removeWhere((element) => list.contains(element));
    }
  }

  void netPublishLocal() {
    action(
      loading: ["build"],
      task: () async {
        var csproj = project.value["csproj"];
        var combine = [path, csproj].join(separator);
        await dotNetHelper.publish(path, profileFileName: "LocalFolder");
        await dotNetHelper.openDir(combine);
      },
    );
  }

  void netPublishDev() async {
    await action(
      loading: ["build"],
      task: () async {
        var projectName = project.value["projectName"];
        var csproj = project.value["csproj"];
        var combine = [path, csproj].join(separator);
        await dotNetHelper.publish(path, profileFileName: "DevServer");
      },
    );
  }

  void netCopy() async {
    await action(
      loading: ["build"],
      task: () async {
        var projectName = project.value["projectName"];
        var csproj = project.value["csproj"];
        var combine = [path, csproj].join(separator);
        await dotNetHelper.copy(combine, projectName);
      },
    );
  }

  Future checkoutBranch(String branch) async {
    await action(
        loading: ["git"],
        task: () async {
          await gitHelper.checkout(path, branch);
        });
    refreshProjectInfo();
  }

  Future<List<String>>? branchList() async {
    return await action(
        loading: ["git"],
        task: () async {
          String? output = await gitHelper.branchList(path);
          var list = output?.split('\n');
          list = list?.map((e) => e.trim()).toList();
          list = list?.reversed.toList();
          return list;
        });
  }

  Future<List<String>>? tagList() async {
    return await action(
        loading: ["git"],
        task: () async {
          String? output = await gitHelper.tagList(path);
          var list = output?.split('\n');
          list = list?.map((e) => e.trim()).toList();
          list = list?.toList();
          return list;
        });
  }

  void fetch() async {
    await action(
        loading: ["git"],
        task: () async {
          await gitHelper.fetch(path);
        });
    refreshProjectInfo();
  }

  void clearConsole() {
    outputController.clear();
  }

  void melosRun(String script) async {
    await action(
        loading: ["melos"],
        task: () async {
          await melosHelper.run(path, script);
        });
  }

  void printEnvironment() async {
    await action(
        loading: ["env"],
        task: () async {
          await cmdHelper.PrintEnvironment();
        });
  }

  isProd() async {
    var branch = await gitHelper.getBranch(path);
    return branch == "PRD";
  }
}
