import 'package:app_updater_flutter/component/model/text_part_style_definition.dart';
import 'package:app_updater_flutter/component/model/text_part_style_definitions.dart';
import 'package:flutter/widgets.dart';

class StyleableTextFieldController extends TextEditingController {
  StyleableTextFieldController({
    required this.styles,
  }) : combinedPattern = styles.createCombinedPatternBasedOnStyleMap();

  final TextPartStyleDefinitions styles;
  final Pattern combinedPattern;

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<InlineSpan> textSpanChildren = <InlineSpan>[];

    text.splitMapJoin(
      combinedPattern,
      onMatch: (Match match) {
        final String? textPart = match.group(0);

        if (textPart == null) return '';

        final TextPartStyleDefinition? styleDefinition =
            styles.getStyleOfTextPart(
          textPart,
          text,
        );

        if (styleDefinition == null) return '';

        TextStyle textStyle = styleDefinition.style;

        _addTextSpan(
          textSpanChildren,
          textPart,
          style?.merge(textStyle),
        );

        return '';
      },
      onNonMatch: (String text) {
        _addTextSpan(textSpanChildren, text, style);

        return '';
      },
    );

    return TextSpan(style: style, children: textSpanChildren);
  }

  void _addTextSpan(
    List<InlineSpan> textSpanChildren,
    String? textToBeStyled,
    TextStyle? style,
  ) {
    textSpanChildren.add(
      TextSpan(
        text: textToBeStyled,
        style: style,
      ),
    );
  }
}
