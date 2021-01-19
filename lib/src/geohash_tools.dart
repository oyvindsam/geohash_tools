import 'package:geohash_tools/geohash_tools.dart';
import 'package:meta/meta.dart';

class GeoHashTools {
  GeoHashTools();

  GeoHashPoint point({@required double latitude, @required double longitude}) {
    return GeoHashPoint(latitude, longitude);
  }
}
