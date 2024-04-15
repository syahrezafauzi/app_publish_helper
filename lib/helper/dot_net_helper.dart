import 'dart:io';

import 'package:app_updater_flutter/helper/cmd_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:process_run/cmd_run.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:xml/xml.dart';
import 'package:path/path.dart' as path;

class DotNetHelper {
  final Function(String)? onOutput;
  final Function(String)? onError;
  final CmdHelper cmdHelper;
  DotNetHelper({CmdHelper? cmdHelper, this.onOutput, this.onError})
      : cmdHelper = cmdHelper ?? CmdHelper(
          onOutput: onOutput,
          onError: onError,
        );
  Future<String?> getVersion(String csproj) async {
    var result = null;
    try {
      var xml = await File(csproj).readAsString();
      var doc = XmlDocument.parse(xml);
      var version = doc.descendants
          .whereType<XmlElement>()
          .where((element) => element.localName == "AssemblyVersion")
          .first
          .innerText;
      debugPrint(version);
      result = version;
    } catch (e) {
      // TODO
    }
    return result;
  }

  increaseVersion(
    String csproj, {
    int? major,
    int? minor,
    int? patch,
  }) async {
    try {
      var xml = await File(csproj).readAsString();
      var doc = XmlDocument.parse(xml);
      var version = doc.descendants
          .whereType<XmlElement>()
          .where((element) => element.localName == "AssemblyVersion")
          .first;
      var current = version.innerText;
      var split = current.split('.');
      var _major = split.first;
      var _minor = split[1];
      var _patch = split.last;

      if (patch != null) {
        var increase = int.parse(_patch) + patch;
        split[split.length - 1] = increase.toString();
      }

      if (minor != null) {
        var increase = int.parse(_minor) + minor;
        split[1] = increase.toString();
        if (patch != null) {
          split[2] = patch.toString();
        }
      }

      var newVersion = split.join(".");
      debugPrint("current version: $current, new version: $newVersion");
      version.innerText = newVersion;
      var edited = doc.toXmlString();
      var file = File(csproj);
      await file.writeAsString(edited);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  publish(String path, {String profileFileName = "FolderProfile"}) async {
    await cmdHelper.executeCommand(
      path,
      command: "dotnet publish -p:PublishProfile=${profileFileName}",
    );
  }

  Future openDir(String csproj) async {
    var publishDir = await _getPublishDir(csproj);
    await launchUrlString(publishDir!);
    // await cmdHelper.executeCommand(
    //   "",
    //   command: "start '$publishDir'",
    // );
  }

  Future copy(String csproj, String projectName) async {
    var publishDir = await _getPublishDir(csproj);
    var targets = [
      '"$publishDir/id"',
      '"$publishDir/en"',
      '"$publishDir/$projectName.deps.json"',
      '"$publishDir/$projectName.dll"',
      '"$publishDir/$projectName.exe"',
      '"$publishDir/$projectName.pdb"',
      '"$publishDir/$projectName.runtimeconfig.json"',
      '"$publishDir/$projectName.Views.dll"',
      '"$publishDir/$projectName.Views.pdb"',
    ];

    var filter = [];

    for (var file in targets) {
      var exist = await File(file.replaceAll('"', '')).exists();
      if (exist) {
        filter.add(file);
      }
    }

    cmdHelper.executeCommand(
      publishDir!,
      command: 'powershell Set-Clipboard -Path ${filter.join(",")}',
    );
  }

  Future<String?> _getPublishDir(String csproj) async {
    var result;
    var file = File(csproj);
    var dir = path.dirname(file.path);
    var profile = "$dir/Properties/PublishProfiles/LocalFolder.pubxml";
    try {
      var xml = await File(profile).readAsString();
      var doc = XmlDocument.parse(xml);
      var publishDir = doc.descendants
          .whereType<XmlElement>()
          .where((element) => element.localName == "PublishDir")
          .first
          .innerText;
      result = publishDir;
      debugPrint("publishDir: $publishDir");
    } catch (e) {
      // TODO
    }
    return result;
  }
}
