// Taken from google/quiver-dart/lib/src/core/hash.dart
// found in this discussion https://github.com/dart-lang/sdk/issues/11617

/// Generates a hash code for multiple [objects].
int hashObjects(Iterable<dynamic> objects) =>
    _finish(objects.fold(0, (dynamic h, dynamic i) => _combine(h, i.hashCode)));

/// Generates a hash code for two objects.
int hash2(dynamic a, dynamic b) =>
    _finish(_combine(_combine(0, a.hashCode), b.hashCode));

/// Generates a hash code for three objects.
int hash3(dynamic a, dynamic b, dynamic c) => _finish(
    _combine(_combine(_combine(0, a.hashCode), b.hashCode), c.hashCode));

/// Generates a hash code for four objects.
int hash4(dynamic a, dynamic b, dynamic c, dynamic d) => _finish(_combine(
    _combine(_combine(_combine(0, a.hashCode), b.hashCode), c.hashCode),
    d.hashCode));

/// Generates a hash code for five objects.
int hash5(dynamic a, dynamic b, dynamic c, dynamic d, dynamic e) =>
    _finish(_combine(
        _combine(
            _combine(_combine(_combine(0, a.hashCode), b.hashCode), c.hashCode),
            d.hashCode),
        e.hashCode));

/// Generates a hash code for 6 objects.
int hash6(dynamic a, dynamic b, dynamic c, dynamic d, dynamic e, dynamic f) =>
    _finish(_combine(
        _combine(
            _combine(
                _combine(
                    _combine(_combine(0, a.hashCode), b.hashCode), c.hashCode),
                d.hashCode),
            e.hashCode),
        f.hashCode));

/// Generates a hash code for 7 objects.
int hash7(dynamic a, dynamic b, dynamic c, dynamic d, dynamic e, dynamic f, dynamic g) =>
    _finish(_combine(
        _combine(
            _combine(
                _combine(
                    _combine(_combine
                      (_combine(0, a.hashCode), b.hashCode), c.hashCode),
                d.hashCode),
            e.hashCode),
        f.hashCode),
        g.hashCode));

// Jenkins hash functions

int _combine(int hash, int value) {
  hash = 0x1fffffff & (hash + value);
  hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
  return hash ^ (hash >> 6);
}

int _finish(int hash) {
  hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
  hash = hash ^ (hash >> 11);
  return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
}
