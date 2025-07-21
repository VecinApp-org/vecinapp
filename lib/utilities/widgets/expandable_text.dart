import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:developer' as devtools show log; // ignore: unused_import

class ExpandableText extends HookWidget {
  const ExpandableText({
    super.key,
    required this.text,
    this.initialMaxLines = 20,
    this.incrementMaxLines = 50,
  });

  final String text;
  final int initialMaxLines;
  final int incrementMaxLines;

  @override
  Widget build(BuildContext context) {
    final maxLines = useState(initialMaxLines);
    final textStyle2 = DefaultTextStyle.of(context).style;
    final textStyle = textStyle2.copyWith(
      inherit: false,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final textSpan = TextSpan(text: text, style: textStyle);
            final textPainter = TextPainter(
              text: textSpan,
              maxLines: maxLines.value,
              textDirection: TextDirection.ltr,
            );
            textPainter.layout(maxWidth: constraints.maxWidth);
            final isTruncated = textPainter.didExceedMaxLines;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  textAlign: TextAlign.left,
                  style: textStyle,
                  maxLines: (isTruncated) ? maxLines.value - 1 : maxLines.value,
                  overflow: TextOverflow.fade,
                  textDirection: TextDirection.ltr,
                ),
                if (isTruncated)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: GestureDetector(
                      onTap: () {
                        maxLines.value += incrementMaxLines;
                      },
                      child: Text(
                        'Leer Más',
                        style: textStyle.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
              ],
            );
          },
        ),
      ],
    );
  }
}
