import 'package:meta/meta.dart';

import 'util.dart';

// TODO: make abstract, with no implementation of get coords?
class GeoHashPoint {
  static Util _util = Util();
  double _latitude;
  double _longitude;
  String _hash;

  GeoHashPoint(this._hash) {
    assert(_hash == null);
    final decoded = _util.decode(_hash);
    _latitude = decoded['latitude'];
    _longitude = decoded['longitude'];
  }

  GeoHashPoint.fromLatLong(this._latitude, this._longitude) {
    assert(latitude != null);
    assert(longitude != null);
    _hash = _util.encode(latitude, longitude, 9);
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
  Coordinates get coordinates => Coordinates(latitude, longitude);

  /// return latitude of [GeoHashPoint]
  double get latitude => _latitude;

  /// return longitude of [GeoHashPoint]
  double get longitude => _longitude;

  /// return all neighbors of [GeoHashPoint]
  List<String> get neighbors {
    return _util.neighbors(this._hash);
  }

  /// return distance between [GeoHashPoint] and ([lat], [lng])
  double distance({@required double lat, @required double lng}) {
    return distanceBetween(from: coordinates, to: Coordinates(lat, lng));
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
