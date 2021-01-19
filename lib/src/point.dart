
import 'package:meta/meta.dart';

import 'util.dart';

// TODO: make abstract, with no implementation of get coords?
class GeoHashPoint {
  static Util _util = Util();
  double latitude, longitude;

  GeoHashPoint(this.latitude, this.longitude);

  /// return geographical distance between two Co-ordinates
  static double distanceBetween(
      {@required Coordinates to, @required Coordinates from}) {
    return Util.distance(to, from);
  }

  /// return neighboring geo-hashes of [hash]
  static List<String> neighborsOf({@required String hash}) {
    return _util.neighbors(hash);
  }

  /// return hash of [GeoHashPoint]
  String get hash {
    return _util.encode(this.latitude, this.longitude, 9);
  }

  /// return all neighbors of [GeoHashPoint]
  List<String> get neighbors {
    return _util.neighbors(this.hash);
  }

  Coordinates get coords {
    return Coordinates(this.latitude, this.longitude);
  }

  /// return distance between [GeoHashPoint] and ([lat], [lng])
  double distance({@required double lat, @required double lng}) {
    return distanceBetween(from: coords, to: Coordinates(lat, lng));
  }

  /// haversine distance between [GeoHashPoint] and ([lat], [lng])
  haversineDistance({@required double lat, @required double lng}) {
    return GeoHashPoint.distanceBetween(
        from: coords, to: Coordinates(lat, lng));
  }

  @override
  String toString() => 'GeoHashPoint(${this.hash})';
}

class Coordinates {
  double latitude;
  double longitude;

  Coordinates(this.latitude, this.longitude);
}
