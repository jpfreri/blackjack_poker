import 'package:flutter/material.dart';
import '../models/card_model.dart';

class CardWidget extends StatelessWidget {
  final PlayingCard? card;
  final double width;
  final double height;

  const CardWidget({
    super.key,
    this.card,
    this.width = 56,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    if (card == null) return _placeholder();
    if (!card!.isFaceUp) return _back();
    return _front(card!);
  }

  Widget _placeholder() => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white24, width: 1.5),
          color: Colors.white.withValues(alpha: 0.05),
        ),
      );

  Widget _back() => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFF1a3a8f), const Color(0xFF0d1f5c)],
          ),
          boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(2, 2))],
        ),
        child: CustomPaint(painter: _CardBackPainter(width: width, height: height)),
      );

  Widget _front(PlayingCard c) {
    final color = c.isRed ? const Color(0xFFCC1515) : const Color(0xFF111111);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFEF0),
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(2, 2))],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 3,
            left: 4,
            child: _cornerLabel(c, color, false),
          ),
          Center(
            child: Text(
              c.suitSymbol,
              style: TextStyle(fontSize: width * 0.44, color: color, height: 1),
            ),
          ),
          Positioned(
            bottom: 3,
            right: 4,
            child: Transform.rotate(
              angle: 3.14159,
              child: _cornerLabel(c, color, false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cornerLabel(PlayingCard c, Color color, bool mirrored) {
    return Column(
      children: [
        Text(
          c.displayValue,
          style: TextStyle(
            fontSize: width * 0.21,
            fontWeight: FontWeight.bold,
            color: color,
            height: 1,
          ),
        ),
        Text(
          c.suitSymbol,
          style: TextStyle(fontSize: width * 0.19, color: color, height: 1),
        ),
      ],
    );
  }
}

class _CardBackPainter extends CustomPainter {
  final double width;
  final double height;
  const _CardBackPainter({required this.width, required this.height});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const step = 8.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_CardBackPainter old) => false;
}

/// A compact row of overlapping cards.
class CardRow extends StatelessWidget {
  final List<PlayingCard> cards;
  final double cardWidth;
  final double cardHeight;
  final double overlap;

  const CardRow({
    super.key,
    required this.cards,
    this.cardWidth = 56,
    this.cardHeight = 80,
    this.overlap = 18,
  });

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      width: cardWidth + (cards.length - 1) * (cardWidth - overlap),
      height: cardHeight,
      child: Stack(
        children: [
          for (int i = 0; i < cards.length; i++)
            Positioned(
              left: i * (cardWidth - overlap),
              child: CardWidget(card: cards[i], width: cardWidth, height: cardHeight),
            ),
        ],
      ),
    );
  }
}
