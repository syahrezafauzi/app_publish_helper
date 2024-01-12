import 'dart:io';

import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:yaml_edit/yaml_edit.dart';
import 'package:collection/collection.dart';

import 'cmd_helper.dart';

class FlutterHelper {
  final Function(String)? onOutput;
  final Function(String)? onError;
  final CmdHelper cmdHelper;

  FlutterHelper({this.onOutput, this.onError, CmdHelper? cmdHelper})
      : cmdHelper = CmdHelper(
          onOutput: onOutput,
          onError: onError,
        );

  getVersion(String path) async {
    var filePath = [path, 'pubspec.yaml'].join("\\");
    final pubspec = File(filePath).readAsStringSync();
    final parsed = Pubspec.parse(pubspec);
    var version = parsed.version;
    var result = version.toString();
    return result;
  }

  increaseVersion(
    path, {
    int? major,
    int? minor,
    int? patch,
  }) async {
    var filePath = [path, 'pubspec.yaml'].join("\\");
    var file = File(filePath);
    final pubspec = file.readAsStringSync();
    final yamlEditor = YamlEditor(pubspec);
    final parsed = Pubspec.parse(pubspec);
    var version = parsed.version;
    var _major = version?.major ?? 0;
    var _minor = version?.minor ?? 0;
    var _patch = version?.patch ?? 0;
    var build = int.parse(version?.build.firstOrNull?.toString() ?? "0");

    if (major != null) {
      _major += major;
      if (minor == null) _minor = 0;
      if (patch == null) _patch = 0;
    }
    if (minor != null) {
      _minor += minor;
      if(patch == null) _patch = 0;
    }
    if (patch != null) _patch += patch;
    build += 1;

    var newVersion =
        [_major, _minor, _patch].map((e) => e?.toStringAsFixed(0)).join(".");
    newVersion = [newVersion, build].join("+");

    yamlEditor.update(['version'], newVersion);
    var newYaml = yamlEditor.toString();
    await file.writeAsString(newYaml);
  }
}
