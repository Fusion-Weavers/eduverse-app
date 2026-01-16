import 'package:flutter/material.dart';
import '../services/ui_translation_service.dart';

class AutoTranslatedText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  const AutoTranslatedText(
    this.text, {
    super.key,
    this.style,
    this.maxLines = 1, // Default to 1 line to prevent overflow
    this.overflow = TextOverflow.ellipsis, // Cut off text if too long
  });

  @override
  State<AutoTranslatedText> createState() => _AutoTranslatedTextState();
}

class _AutoTranslatedTextState extends State<AutoTranslatedText> {
  late String _displayText;

  @override
  void initState() {
    super.initState();
    _displayText = widget.text;
    _triggerTranslation();
  }

  @override
  void didUpdateWidget(covariant AutoTranslatedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _displayText = widget.text;
      _triggerTranslation();
    }
  }

  Future<void> _triggerTranslation() async {
    final service = UiTranslationService();
    // 1. Check Cache immediately
    String cached = service.getCachedOrOriginal(widget.text);
    
    if (cached != widget.text) {
      if (mounted) setState(() => _displayText = cached);
    } else {
      // 2. Fetch from API
      service.translateOnFly(widget.text).then((translated) {
        if (mounted && translated != _displayText) {
          setState(() => _displayText = translated);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: UiTranslationService(),
      builder: (context, child) {
        // Retry translation if language changed
        _triggerTranslation();
        
        return Text(
          _displayText,
          style: widget.style,
          maxLines: widget.maxLines,
          overflow: widget.overflow,
          softWrap: true,
        );
      },
    );
  }
}