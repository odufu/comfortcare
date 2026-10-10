import 'package:flutter/material.dart';

/// Formats and renders AI responses with clinical-grade typography and Markdown styling:
/// - Strips raw Markdown syntax (`*`, `**`, `_`, `\`\``) and renders bold, italic, and tags.
/// - Transforms root bullets (`* item`, `- item`) into aligned bullet points with styled indicator dots.
/// - Transforms indented sub-bullets (`  * sub-item`) with nested indentations.
/// - Formats headers (`#`, `##`, `###`) into clear section titles.
/// - Uses [Text.rich] so that all Flutter text semantics, copy-paste, and tests work out-of-the-box.
class AiMarkdownText extends StatelessWidget {
  final String text;
  final TextStyle? baseStyle;
  final ColorScheme? colorScheme;

  const AiMarkdownText({
    super.key,
    required this.text,
    this.baseStyle,
    this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = colorScheme ?? theme.colorScheme;
    final style = baseStyle ??
        theme.textTheme.bodyMedium?.copyWith(
          fontSize: 13.5,
          height: 1.48,
          color: colors.onSurface,
        ) ??
        TextStyle(
          fontSize: 13.5,
          height: 1.48,
          color: colors.onSurface,
        );

    final blocks = _parseBlocks(text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: blocks.map((block) => _buildBlock(block, style, colors)).toList(),
    );
  }

  Widget _buildBlock(_MarkdownBlock block, TextStyle baseStyle, ColorScheme colors) {
    switch (block.type) {
      case _BlockType.header1:
        return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Text.rich(
            TextSpan(
              style: baseStyle.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: colors.primary,
              ),
              children: _parseInlineSpans(
                block.content,
                baseStyle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: colors.primary,
                ),
                colors,
              ),
            ),
          ),
        );
      case _BlockType.header2:
        return Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 3),
          child: Text.rich(
            TextSpan(
              style: baseStyle.copyWith(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: colors.primary,
              ),
              children: _parseInlineSpans(
                block.content,
                baseStyle.copyWith(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                ),
                colors,
              ),
            ),
          ),
        );
      case _BlockType.bullet:
        final indent = block.indentLevel * 14.0;
        final isSubBullet = block.indentLevel > 0;
        return Padding(
          padding: EdgeInsets.only(top: 3, bottom: 3, left: indent),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(
                  top: (baseStyle.fontSize ?? 13.5) * 0.45,
                  right: 8,
                ),
                width: isSubBullet ? 4.5 : 5.5,
                height: isSubBullet ? 4.5 : 5.5,
                decoration: BoxDecoration(
                  color: isSubBullet
                      ? colors.onSurfaceVariant.withValues(alpha: 0.7)
                      : colors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: baseStyle,
                    children: _parseInlineSpans(block.content, baseStyle, colors),
                  ),
                ),
              ),
            ],
          ),
        );
      case _BlockType.numbered:
        return Padding(
          padding: const EdgeInsets.only(top: 3, bottom: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 20,
                child: Text(
                  '${block.number}.',
                  style: baseStyle.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.primary,
                  ),
                ),
              ),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: baseStyle,
                    children: _parseInlineSpans(block.content, baseStyle, colors),
                  ),
                ),
              ),
            ],
          ),
        );
      case _BlockType.emptyLine:
        return const SizedBox(height: 6);
      case _BlockType.paragraph:
        return Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Text.rich(
            TextSpan(
              style: baseStyle,
              children: _parseInlineSpans(block.content, baseStyle, colors),
            ),
          ),
        );
    }
  }

  static List<_MarkdownBlock> _parseBlocks(String input) {
    final lines = input.split('\n');
    final blocks = <_MarkdownBlock>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trim();

      if (trimmed.isEmpty) {
        if (blocks.isNotEmpty && blocks.last.type != _BlockType.emptyLine) {
          blocks.add(_MarkdownBlock(type: _BlockType.emptyLine, content: ''));
        }
        continue;
      }

      // Check header
      if (trimmed.startsWith('### ')) {
        blocks.add(_MarkdownBlock(type: _BlockType.header2, content: trimmed.substring(4)));
        continue;
      } else if (trimmed.startsWith('## ')) {
        blocks.add(_MarkdownBlock(type: _BlockType.header2, content: trimmed.substring(3)));
        continue;
      } else if (trimmed.startsWith('# ')) {
        blocks.add(_MarkdownBlock(type: _BlockType.header1, content: trimmed.substring(2)));
        continue;
      }

      // Check bullet point: "* item", "- item", "• item", or indented "  * subitem"
      final bulletMatch = RegExp(r'^(\s*)([\*\-•])\s+(.*)$').firstMatch(line);
      if (bulletMatch != null) {
        final leadingSpaces = bulletMatch.group(1)?.length ?? 0;
        final indentLevel = leadingSpaces >= 4 ? 2 : (leadingSpaces >= 2 ? 1 : 0);
        final content = bulletMatch.group(3) ?? '';
        blocks.add(_MarkdownBlock(
          type: _BlockType.bullet,
          content: content,
          indentLevel: indentLevel,
        ));
        continue;
      }

      // Check numbered list: e.g. "1. item", "2. item"
      final numberedMatch = RegExp(r'^(\s*)(\d+)\.\s+(.*)$').firstMatch(line);
      if (numberedMatch != null) {
        final numStr = numberedMatch.group(2) ?? '1';
        final content = numberedMatch.group(3) ?? '';
        blocks.add(_MarkdownBlock(
          type: _BlockType.numbered,
          content: content,
          number: int.tryParse(numStr) ?? 1,
        ));
        continue;
      }

      // Normal paragraph line
      blocks.add(_MarkdownBlock(
        type: _BlockType.paragraph,
        content: trimmed,
      ));
    }

    return blocks;
  }

  /// Parses inline formatting:
  /// - ***bold italic***
  /// - **bold** or __bold__
  /// - *italic* or _italic_
  /// - `code`
  static List<InlineSpan> _parseInlineSpans(
    String text,
    TextStyle baseStyle,
    ColorScheme colors,
  ) {
    final spans = <InlineSpan>[];
    final regex = RegExp(
      r'(\*\*\*(.+?)\*\*\*)|(_{3}(.+?)_{3})|(\*\*(.+?)\*\*)|(_{2}(.+?)_{2})|(\*([^\*\n]+)\*)|(_([^_\n]+)_)|(`([^`\n]+)`)',
    );

    var currentIndex = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, match.start),
          style: baseStyle,
        ));
      }

      final boldItalic1 = match.group(2);
      final boldItalic2 = match.group(4);
      final bold1 = match.group(6);
      final bold2 = match.group(8);
      final italic1 = match.group(10);
      final italic2 = match.group(12);
      final code = match.group(14);

      if (boldItalic1 != null || boldItalic2 != null) {
        final content = boldItalic1 ?? boldItalic2!;
        spans.add(TextSpan(
          text: content,
          style: baseStyle.copyWith(
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
            color: colors.onSurface,
          ),
        ));
      } else if (bold1 != null || bold2 != null) {
        final content = bold1 ?? bold2!;
        spans.add(TextSpan(
          text: content,
          style: baseStyle.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ));
      } else if (italic1 != null || italic2 != null) {
        final content = italic1 ?? italic2!;
        spans.add(TextSpan(
          text: content,
          style: baseStyle.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ));
      } else if (code != null) {
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              code,
              style: baseStyle.copyWith(
                fontFamily: 'monospace',
                fontSize: (baseStyle.fontSize ?? 13) * 0.9,
                fontWeight: FontWeight.w600,
                color: colors.primary,
              ),
            ),
          ),
        ));
      }

      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentIndex),
        style: baseStyle,
      ));
    }

    return spans;
  }
}

enum _BlockType {
  header1,
  header2,
  bullet,
  numbered,
  paragraph,
  emptyLine,
}

class _MarkdownBlock {
  final _BlockType type;
  final String content;
  final int indentLevel;
  final int number;

  const _MarkdownBlock({
    required this.type,
    required this.content,
    this.indentLevel = 0,
    this.number = 1,
  });
}
