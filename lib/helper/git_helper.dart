import 'dart:io';

import 'package:app_updater_flutter/helper/cmd_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:process_run/cmd_run.dart';
import 'package:path/path.dart';

class GitHelper {
  final Function(String)? onOutput;
  final Function(String)? onError;
  final CmdHelper cmdHelper;
  GitHelper({this.onOutput, this.onError})
      : cmdHelper = CmdHelper(
          onOutput: onOutput,
          onError: onError,
        );

  getBranch(String path) async {
    String? result = await cmdHelper.executeCommand(
      path,
      command: "git rev-parse --abbrev-ref HEAD",
    );
    return result;
  }

  resetVersion(String file) async {
    var _file = File(file);
    var path = _file.parent.path;
    var fileName = basename(file);
    await cmdHelper.executeCommand(
      path,
      command: "git checkout HEAD -- $fileName",
    );
  }

  commit(String path, String file, {String? message}) async {
    var _file = File(file);
    var filePath = _file.parent.path;
    var fileName = basename(file);
    await cmdHelper.executeCommand(
      filePath,
      command: "git add $fileName",
    );

    await cmdHelper.executeCommand(
      path,
      command: "git commit -m '$message'",
    );
  }

  push(path) async {
    await cmdHelper.executeCommand(
      path,
      command: "git push",
    );
  }

  tag(path, String tag) async {
    await cmdHelper.executeCommand(
      path,
      command: "git tag $tag",
    );
  }

  pushTag(path, String tag) async {
    await cmdHelper.executeCommand(
      path,
      command: "git push origin $tag",
    );
  }

  Future<String?> getRemoteUrl(path) async {
    return await cmdHelper.executeCommand(
      path,
      command: "git config --get remote.origin.url",
    );
  }

  pull(path) async {
    await cmdHelper.executeCommand(
      path,
      command: "git pull",
    );
  }

  reset(String path) async {
    await cmdHelper.executeCommand(
      path,
      command: "git reset --hard @{u}",
    );
  }
}
