import 'package:flutter/material.dart';

/// A "fake" QR that only holds the layout — NOT actually scannable. When wiring the
/// real check-in API, replace it with the `qr_flutter` package (encoding the real
/// appointment code) — see docs/architecture/04-viec-con-lai.md.
class PlaceholderQr extends StatelessWidget {
  const PlaceholderQr({super.key, this.size = 220, this.cells = 21});

  final double size;
  final int cells;

  bool _isFinder(int r, int c) {
    bool inBox(int r0, int c0) =>
        r >= r0 && r < r0 + 7 && c >= c0 && c < c0 + 7;
    bool pattern(int r0, int c0) {
      final rr = r - r0, cc = c - c0;
      if (rr == 0 || rr == 6 || cc == 0 || cc == 6) return true;
      return rr >= 2 && rr <= 4 && cc >= 2 && cc <= 4;
    }

    if (inBox(0, 0)) return pattern(0, 0);
    if (inBox(0, cells - 7)) return pattern(0, cells - 7);
    if (inBox(cells - 7, 0)) return pattern(cells - 7, 0);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // Fixed LCG (independent of the system Random) so the pattern is stable each build.
    int seed = 42;
    double next() {
      seed = (seed * 1103515245 + 12345) % 2147483648;
      return seed / 2147483648;
    }

    return SizedBox(
      width: size,
      height: size,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cells),
        itemCount: cells * cells,
        itemBuilder: (context, index) {
          final r = index ~/ cells;
          final c = index % cells;
          final isFinder = _isFinder(r, c);
          final on = isFinder || next() > 0.52;
          return Container(color: on ? const Color(0xFF14301F) : Colors.white);
        },
      ),
    );
  }
}
