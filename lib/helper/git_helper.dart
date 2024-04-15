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
      command: "git",
      arguments: ["rev-parse", "--abbrev-ref", "HEAD"],
      silent: true,
    );
    return result;
  }

  resetVersion(String file) async {
    var _file = File(file);
    var path = _file.parent.path;
    var fileName = basename(file);
    await cmdHelper.executeCommand(
      path,
      command: "git",
      arguments: ["checkout", "HEAD", "--", fileName],
    );
  }

  commit(String path, String file, {String? message}) async {
    var _file = File(file);
    var filePath = _file.parent.path;
    var fileName = basename(file);
    await cmdHelper.executeCommand(
      filePath,
      command: "git",
      arguments: ["add", fileName],
    );

    await cmdHelper.executeCommand(
      path,
      command: "git",
      arguments: ["commit", "-m", '$message'],
      silent: true,
    );
  }

  push(path) async {
    await cmdHelper.executeCommand(
      path,
      command: "git",
      arguments: ["push"],
    );
  }

  tag(path, String tag) async {
    await cmdHelper.executeCommand(
      path,
      command: "git",
      arguments: ["tag", tag],
    );
  }

  tagPush(path, String tag) async {
    await cmdHelper.executeCommand(
      path,
      command: "git",
      arguments: ["push", "origin", tag],
    );
  }

  Future<String?> getRemoteUrl(path) async {
    return await cmdHelper.executeCommand(
      path,
      command: "git",
      arguments: ["config", "--get", "remote.origin.url"],
      silent: true,
    );
  }

  pull(path) async {
    await cmdHelper.executeCommand(
      path,
      command: "git",
      arguments: ["pull"],
    );
  }

  reset(String path) async {
    await cmdHelper.executeCommand(
      path,
      command: "git",
      arguments: ["reset", "--hard", "@{u}"],
    );
  }

  incoming(String branch, String path) async {
    return await cmdHelper.executeCommand(
      path,
      command: "git",
      arguments: [
        "rev-list",
        "--right-only",
        "--count",
        "$branch...origin/$branch"
      ],
      silent: true,
    );
  }

  outgoing(String branch, String path) async {
    return await cmdHelper.executeCommand(
      path,
      command: "git",
      arguments: [
        "rev-list",
        "--left-only",
        "--count",
        "$branch...origin/$branch"
      ],
      silent: true,
    );
  }

  checkout(path, String branch) async {
    return await cmdHelper.executeCommand(
      path,
      command: "git",
      arguments: ["checkout", branch],
    );
  }

  Future<String?> branchList(String path) async {
    return await cmdHelper.executeCommand(
      path,
      command: "git",
      arguments: [
        "branch",
        "--all",
        "--sort=committerdate",
        "--format=%(refname:short)"
      ],
      silent: true,
    );
  }

  Future<String?> tagList(String path) async {
    return await cmdHelper.executeCommand(
      path,
      command: "git",
      arguments: [
        "tag",
        "--sort=-creatordate",
      ],
      silent: true,
    );
  }

  fetch(path) async {
    return await cmdHelper.executeCommand(
      path,
      command: "git",
      arguments: ["fetch"],
    );
  }
}
