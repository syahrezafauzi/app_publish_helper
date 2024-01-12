import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:process_run/cmd_run.dart';
import 'package:get/get.dart';

class CmdHelper {
  final Function(String)? onOutput;
  final Function(String)? onError;

  CmdHelper({this.onOutput, this.onError});

  Future<String?> executeCommand(
    String path, {
    required String command,
    List<String>? arguments,
    bool silent = false,
  }) async {
    // debugPrint("command path: $path");
    // debugPrint("command: $command");
    _outputText(command, silent: silent);
    var process = ProcessCmd(
      command,
      arguments ?? [],
      runInShell: Platform.isWindows,
      workingDirectory: path,
    );
    var res = await runCmd(process);
    _output(res, silent: silent);
    var result = (res.stderr.toString().isBlank ?? true)
        ? res.stdout.toString().trim()
        : null;
    return result;
  }

  void _outputText(String command, {bool silent = false}) {
    if (!silent) {
      onOutput?.call(command);
    }
  }

  void _output(ProcessResult res, {bool silent = false}) {
    if (!silent) {
      var error = res.stderr;
      var out = res.stdout;
      if (error is String && !error.isEmpty) {
        onError?.call(error.trim());
      }
      if (out is String && !out.isEmpty) {
        onOutput?.call(out.trim());
      }
    }
  }
}
