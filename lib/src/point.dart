import 'package:meta/meta.dart';

import 'util.dart';

class GeoHashPoint {
  double _latitude;
  double _longitude;
  String _hash;

  GeoHashPoint(this._latitude, this._longitude) {
    assert(latitude != null);
    assert(longitude != null);
    _hash = GeoHashToolsUtil.encode(latitude, longitude, numberOfChars: 9);
  }

  GeoHashPoint.fromHash(this._hash) {
    assert(_hash != null);
    final decoded = GeoHashToolsUtil.decode(_hash);
    _latitude = decoded['latitude'];
    _longitude = decoded['longitude'];
  }

  /// return geographical distance between two coordinates
  static double distanceBetween(
      {@required Coordinates to, @required Coordinates from}) {
    return GeoHashToolsUtil.distance(to, from);
  }

  /// return neighboring geo-hashes of [hash]
  static List<String> neighborsOf({@required String hash}) {
    return GeoHashToolsUtil.neighbors(hash);
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
    return GeoHashToolsUtil.neighbors(this._hash);
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
