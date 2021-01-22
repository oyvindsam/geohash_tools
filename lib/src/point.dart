import 'package:meta/meta.dart';

import 'util.dart';

// TODO: make abstract, with no implementation of get coords?
class GeoHashPoint {
  static Util _util = Util();
  Coordinates _coordinates;
  String _hash;
  Map<String, double> decoded;

  GeoHashPoint(this._hash) {
    assert(_hash == null);
    decoded = _util.decode(_hash);
    _coordinates = Coordinates(decoded['latitude'], decoded['longitude']);
  }

  GeoHashPoint.fromLatLong(double latitude, double longitude) {
    assert(latitude != null);
    assert(longitude != null);
    this._coordinates = Coordinates(latitude, longitude);
    _hash = _util.encode(latitude, longitude, 9);
    decoded = _util.decode(_hash);
  }

  /// return geographical distance between two coordinates
  static double distanceBetween(
      {@required Coordinates to, @required Coordinates from}) {
    return Util.distance(to, from);
  }

  /// return neighboring geo-hashes of [hash]
  static List<String> neighborsOf({@required String hash}) {
    return _util.neighbors(hash);
  }

  /// return hash of [GeoHashPoint]
  String get hash => _hash;

  /// return coordinates of [GeoHashPoint]
  Coordinates get coordinates => _coordinates;

  /// return latitude of [GeoHashPoint]
  double get latitude => _coordinates.latitude;

  /// return longitude of [GeoHashPoint]
  double get longitude => _coordinates.longitude;

  /// return all neighbors of [GeoHashPoint]
  List<String> get neighbors {
    return _util.neighbors(this._hash, decoded: this.decoded);
  }

  /// return distance between [GeoHashPoint] and ([lat], [lng])
  double distance({@required double lat, @required double lng}) {
    return distanceBetween(from: _coordinates, to: Coordinates(lat, lng));
  }

  /// haversine distance between [GeoHashPoint] and ([lat], [lng])
  haversineDistance({@required double lat, @required double lng}) {
    return GeoHashPoint.distanceBetween(
        from: coordinates, to: Coordinates(lat, lng));
  }

  @override
  String toString() => 'GeoHashPoint(${this._hash} - ($latitude, $longitude)';
}

class Coordinates {
  double latitude;
  double longitude;

  Coordinates(this.latitude, this.longitude);
}
