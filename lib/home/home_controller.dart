import 'package:app_updater_flutter/helper/dot_net_helper.dart';
import 'package:app_updater_flutter/helper/git_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

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
    }
  ];

  var project = Rxn();
  var branch = RxnString();
  var versionNumber = RxnString();

  var output = TextEditingController();
  late GitHelper gitHelper;
  late DotNetHelper dotNetHelper;

  var outputScroll = ScrollController();

  var loading = RxList<String>([]);

  bool isLoading(List<String>? category) {
    return loading.any((element) => category?.contains(element) ?? false);
  }

  HomeController() {
    gitHelper = GitHelper(
      onOutput: (p0) {
        _printOutput(p0);
      },
      onError: (p0) {
        _printOutput(p0, color: Colors.red);
      },
    );
    dotNetHelper = DotNetHelper(
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
    output.text += "\n$date: $p0";
    Future.delayed(Duration(milliseconds: 500), () {
      output.selection =
          TextSelection.fromPosition(TextPosition(offset: output.text.length));
      outputScroll.position.didEndScroll();
      outputScroll.jumpTo(outputScroll.position.maxScrollExtent);
    });
  }

  void _action(Function() action) {}

  Future<String?> getVersionNumber() async {
    this.versionNumber.value = "[version]";
    var path = project.value["path"];
    var csproj = project.value["csproj"];
    var combine = [path, csproj].join("\\");
    var version = await dotNetHelper.getVersion(combine);
    versionNumber.value = version;
    return version;
  }

  Future<String?> getBranch() async {
    return await action(
        loading: ["git"],
        task: () async {
          this.branch.value = "[branch]";
          var path = project.value["path"];
          var branch = await gitHelper.getBranch(path);
          this.branch.value = branch;
          return branch;
        });
  }

  selectWebsite(item) {
    project.value = item;
    getVersionNumber();
    getBranch();
  }

  void increasePatch() async {
    var path = project.value["path"];
    var csproj = project.value["csproj"];
    var combine = [path, csproj].join("\\");
    await dotNetHelper.increaseVersion(combine, patch: 1);
    await getVersionNumber();
  }

  void increaseMinor() async {
    var path = project.value["path"];
    var csproj = project.value["csproj"];
    var combine = [path, csproj].join("\\");
    await dotNetHelper.increaseVersion(combine, minor: 1, patch: 0);
    await getVersionNumber();
  }

  void resetVersion() async {
    await action(
        loading: ["git"],
        task: () async {
          var path = project.value["path"];
          var csproj = project.value["csproj"];
          var file = [path, csproj].join("\\");
          await gitHelper.resetVersion(file);
          await getVersionNumber();
        });
  }

  void commit() async {
    await action(
        loading: ["git"],
        task: () async {
          var path = project.value["path"];
          var csproj = project.value["csproj"];
          var file = [path, csproj].join("\\");
          await gitHelper.commit(
            path,
            file,
            message: "up-v$versionNumber",
          );
        });
  }

  void push() async {
    await action(
        loading: ["git"],
        task: () async {
          var path = project.value["path"];
          await gitHelper.push(
            path,
          );
        });
  }

  void tag(String prefix) async {
    await action(
        loading: ["git"],
        task: () async {
          var path = project.value["path"];
          await gitHelper.tag(path, "$prefix-$versionNumber");
        });
  }

  void pushTag(String prefix) async {
    await action(
        loading: ["git"],
        task: () async {
          var path = project.value["path"];
          await gitHelper.pushTag(path, "$prefix-$versionNumber");
        });
  }

  void openBitbucket(String prefix) async {
    await action(
        loading: ["bitbucket"],
        task: () async {
          var path = project.value["path"];
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
        var path = project.value["path"];
        await gitHelper.pull(path);
      },
    );
  }

  action({required Future Function() task, List<String>? loading}) async {
    setLoading(true, loading ?? []);
    await task().onError((error, stackTrace) {});
    setLoading(false, loading ?? []);
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
            var path = project.value["path"];
            await gitHelper.reset(path);
            await getVersionNumber();
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

  void build() {
    action(
      loading: ["build"],
      task: () async {
        var path = project.value["path"];
        var csproj = project.value["csproj"];
        var combine = [path, csproj].join("\\");
        await dotNetHelper.build(path);
        await dotNetHelper.openDir(combine);
      },
    );
  }

  void netCopy() async {
    await action(
      loading: ["build"],
      task: () async {
        var path = project.value["path"];
        var projectName = project.value["projectName"];
        var csproj = project.value["csproj"];
        var combine = [path, csproj].join("\\");
        await dotNetHelper.copy(combine, projectName);
      },
    );
  }
}
