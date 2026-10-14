import 'dart:math';

/// Small deterministic PRNG (mulberry32). Dart's `Random(seed)` sequence is not guaranteed to stay the same across
/// SDK versions, but the 20 fixed test sets (FR-A20b) must never change between app updates.
class SeededRandom implements Random {
  SeededRandom(int seed) : _state = seed & 0xFFFFFFFF;

  int _state;

  int _next32() {
    _state = (_state + 0x6D2B79F5) & 0xFFFFFFFF;
    var t = _state;
    t = _imul(t ^ (t >> 15), t | 1);
    t ^= t + _imul(t ^ (t >> 7), t | 61);
    t &= 0xFFFFFFFF;
    return (t ^ (t >> 14)) & 0xFFFFFFFF;
  }

  static int _imul(int a, int b) => mul32(a, b);

  @override
  int nextInt(int max) {
    if (max <= 0 || max > 0x100000000) {
      throw RangeError.range(max, 1, 0x100000000, 'max');
    }
    // rejection sampling: no modulo bias
    final limit = 0x100000000 - (0x100000000 % max);
    while (true) {
      final v = _next32();
      if (v < limit) return v % max;
    }
  }

  @override
  double nextDouble() => _next32() / 0x100000000;

  @override
  bool nextBool() => _next32() & 1 == 1;
}

/// FNV-1a 32-bit hash: stable across platforms and SDK versions (unlike `String.hashCode`).
int stableHash(String text) {
  var h = 0x811C9DC5;
  for (final unit in text.codeUnits) {
    h ^= unit;
    h = mul32(h, 0x01000193);
  }
  return h;
}

/// 32-bit multiply (like JavaScript `Math.imul`, unsigned result). Splits into 16-bit halves so no intermediate
/// exceeds 2^53 — identical results on the Dart VM (Android) and on the web, where ints are doubles.
int mul32(int a, int b) {
  final aHi = (a >> 16) & 0xFFFF;
  final aLo = a & 0xFFFF;
  final bHi = (b >> 16) & 0xFFFF;
  final bLo = b & 0xFFFF;
  return ((aLo * bLo) + (((aHi * bLo + aLo * bHi) & 0xFFFF) << 16)) &
      0xFFFFFFFF;
}
