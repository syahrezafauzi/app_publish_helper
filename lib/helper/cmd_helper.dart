import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:process_run/cmd_run.dart';
import 'package:get/get.dart';
import 'package:process_run/process_run.dart';
import 'dart:convert' show utf8;

class CmdHelper {
  final Function(String)? onOutput;
  final Function(String)? onError;
  final env = ShellEnvironment();

  CmdHelper({this.onOutput, this.onError});

  Future<String?> executeCommand(
    String path, {
    required String command,
    List<String>? arguments,
    bool silent = false,
  }) async {
    // debugPrint("command path: $path");
    // debugPrint("command: $command");
    _outputText(command, silent: silent, arguments: arguments);
    resolvePath(env);

    var process = ProcessCmd(
      command,
      arguments ?? [],
      runInShell: false,
      workingDirectory: path,
      environment: env,
      includeParentEnvironment: true,
      stderrEncoding: utf8,
      stdoutEncoding: utf8,
    );

    final output = stream(silent, (event) => onOutput?.call(event));
    final error = stream(silent, (event) => onError?.call(event));

    // if (!silent) {
    //   env.forEach((key, value) {
    //     onOutput?.call("$key: $value");
    //   });
    // }

    // var res = null;

    var res = await runCmd(
      process,
      stdout: output?.sink,
      stderr: error?.sink,
    );

    output?.close();
    error?.close();
    // _output(res, silent: silent);
    var result = (res.stderr.toString().isBlank ?? true)
        ? res.stdout.toString().trim()
        : null;
    return result;
  }

  void _outputText(String command,
      {bool silent = false, List<String>? arguments}) {
    if (!silent) {
      var combine = [command]..addAll(arguments ?? []);
      var output = combine.join(" ");
      onOutput?.call(output);
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

  ShellLinesController? stream(bool silent, Function(dynamic event) onEvent) {
    var controller;
    if (!silent) {
      controller = ShellLinesController(encoding: utf8);
      controller.stream.listen((event) {
        if (!silent) {
          onEvent.call(event);
        }
      });
    }

    return controller;
  }

  void resolvePath(ShellEnvironment env) {
    if (Platform.isMacOS) {
      var dart = "/Users/mtmhaccount/Downloads/fvm/3.0.5/bin";
      var pubCache = "/Users/mtmhaccount/.pub-cache/bin";
      var flutterRoot = "/Users/mtmhaccount/Downloads/fvm/3.0.5";
      var binCache =
          "/Users/mtmhaccount/Downloads/fvm/3.0.5/bin/cache/dart-sdk/bin";
      var gemCache =
          "/Users/mtmhaccount/.gem/ruby/2.6.0/bin";

      var paths = env.paths;

      var isFlutterRoot = isAny(env, "FLUTTER_ROOT", flutterRoot);
      var isDart = isAny(env, "PATH", dart);
      var isPubCache = isAny(env, "PATH", pubCache);
      var isBinCache = isAny(env, "PATH", binCache);
      var isGemCache = isAny(env, "PATH", gemCache);

      if (!isFlutterRoot) _addKey(env, "FLUTTER_ROOT", flutterRoot);
      if (!isDart) _addPath(env, dart);
      if (!isPubCache) _addPath(env, pubCache);
      if (!isBinCache) _addPath(env, binCache);
      if (!isGemCache) _addPath(env, gemCache);
    }
  }

  bool isAny(ShellEnvironment env, key, value) {
    var isKey = env.entries.any((element) => element.key == key);
    if (!isKey) return false;
    var isValue = env.entries
        .any((element) => element.key == key && element.value == value);
    return isValue;
  }

  void _addPath(ShellEnvironment env, String value) {
    env.paths.add(value);
  }

  void _addKey(ShellEnvironment env, String key, String value) {
    env.addAll({"$key": value});
  }

  PrintEnvironment() {
    env.forEach((key, value) {
      onOutput?.call("$key: $value");
    });
  }
}
