import 'package:flutter/material.dart';
import 'package:flutter_tex/flutter_tex.dart';

class LaTeXText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextDirection? textDirection;

  const LaTeXText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    // Sprawdź czy tekst zawiera LaTeX
    if (!_containsLaTeX(text)) {
      // Zwykły tekst
      return Text(
        text,
        style: style,
        textAlign: textAlign,
        textDirection: textDirection,
      );
    }

    // Tekst z LaTeX - użyj TeXView
    try {
      return TeXView(
        child: TeXViewDocument(
          _preprocessLaTeX(text),
          style: TeXViewStyle(
            padding: TeXViewPadding.all(0),
            fontStyle: TeXViewFontStyle(
              fontSize: style?.fontSize?.toInt() ?? 16,
            ),
          ),
        ),
        style: TeXViewStyle(
          elevation: 0,
          backgroundColor: Colors.transparent,
          padding: TeXViewPadding.all(8),
        ),
      );
    } catch (e) {
      // W przypadku błędu renderowania LaTeX, pokaż zwykły tekst
      print('LaTeX rendering error: $e');
      return Text(
        text,
        style: style,
        textAlign: textAlign,
        textDirection: textDirection,
      );
    }
  }

  bool _containsLaTeX(String text) {
    // Sprawdź popularne znaczniki LaTeX
    final latexPatterns = [
      r'\begin{',
      r'\end{',
      r'\frac{',
      r'\sqrt{',
      r'\sum',
      r'\int',
      r'\alpha',
      r'\beta',
      r'\gamma',
      r'\pi',
      r'\theta',
      r'$$',
      r'\$',
      r'\\',
    ];
    
    for (final pattern in latexPatterns) {
      if (text.contains(pattern)) {
        return true;
      }
    }
    return false;
  }

  String _preprocessLaTeX(String latex) {
    // Podstawowe przetwarzanie LaTeX dla flutter_tex
    String processed = latex;
    
    // Upewnij się, że LaTeX jest w poprawnym formacie dla TeXView
    if (!processed.startsWith(r'$$') && !processed.startsWith(r'$')) {
      // Jeśli zawiera \begin{}, otoczyj dwoisnymi dolarami
      if (processed.contains(r'\begin{')) {
        processed = r'$$' + processed + r'$$';
      } else {
        // Dla prostszych wyrażeń użyj pojedynczych dolarów
        processed = r'$' + processed + r'$';
      }
    }
    
    // Podstawowe poprawki
    processed = processed.replaceAll(r'\ ', r'\\');
    processed = processed.replaceAll(r'\newline', r'\\');
    
    return processed;
  }
}
