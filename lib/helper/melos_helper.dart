import 'package:app_updater_flutter/helper/cmd_helper.dart';

class MelosHelper {
  final Function(String)? onOutput;
  final Function(String)? onError;
  final CmdHelper cmdHelper;
  MelosHelper({CmdHelper? cmdHelper, this.onOutput, this.onError})
      : cmdHelper = cmdHelper ?? CmdHelper(
          onOutput: onOutput,
          onError: onError,
        );

  run(String path, String script) async {
    String? result = await cmdHelper.executeCommand(
      path,
      command: "melos",
      arguments: [script],
    );
    return result;
  }
}
