import 'package:geohash_tools/geohash_tools.dart';
import 'package:meta/meta.dart';

import 'point.dart';
import 'util.dart';

class DistancePoint extends Comparable<DistancePoint> {
  final GeoHashPoint point;
  double distance;

  DistancePoint(this.point, this.distance);

  @override
  int compareTo(DistancePoint other) {
    return (distance * 1000).toInt() - (other.distance * 1000).toInt();
  }

  @override
  String toString() => 'DistancePoint(${point.hash} - $distance)';
}

/// Store geohashes in an optimized way. Points are stored in a map,
/// indexed on the geohash-prefix for a _pre-specified_ resolution.
/// Would likely work faster when you have a lot of geohash data,
/// where the 'resolution' or precision of each nearest query are known
/// before creation.
class GeoHashArea {
  List<GeoHashPoint> points;
  final double radius;
  Map<String, List<GeoHashPoint>> hashToPoints = {};
  int precision;

  GeoHashArea(this.points, {this.radius = double.infinity}) {
    precision = Util.setPrecision(radius);

    /// create geohash map with given precision (radius)
    points.forEach((point) {
      final hash = point.hash.substring(0, precision);
      if (!hashToPoints.containsKey(hash)) {
        hashToPoints[hash] = [point];
      } else {
        hashToPoints[hash].add(point);
      }
    });
  }

  /// Get all points within [radius] of [center]. Include distance to center.
  List<DistancePoint> withinDistance(GeoHashPoint center, {sorted = true}) {
    final centerHash = center.hash.substring(0, precision);
    final areaHashes = GeoHashPoint.neighborsOf(hash: centerHash)
      ..add(centerHash);

    final pointsIn = areaHashes
        .map((h) => hashToPoints[h])
        .where((points) => points != null)
        .expand((points) => points) // flatten list of geoHashPoints
        .map((point) => DistancePoint(
            point, center.distance(lat: point.latitude, lng: point.longitude)))
        .where((areaPoint) => areaPoint.distance <= radius * 1.02)
        .toList();
    if (sorted) {
      pointsIn.sort();
      return pointsIn;
    }
    return pointsIn;
  }

  /// Get all points within [radius] of [center].
  Set<GeoHashPoint> within(GeoHashPoint center) {
    final centerHash = center.hash.substring(0, precision);
    final areaHashes = GeoHashPoint.neighborsOf(hash: centerHash)
      ..add(centerHash);

    return areaHashes
        .map((h) => hashToPoints[h])
        .where((points) => points != null)
        .expand((points) => points);
  }
}

/// Less optimized storage of points in a list, but more flexible.
class GeoHashCollection {
  List<GeoHashPoint> points;

  GeoHashCollection(this.points);

  /// Will iterate though all points, filter on distance from [center],
  /// and return points sorted.
  List<DistancePoint> withinDistance({
    @required GeoHashPoint center,
    @required double radius,
    bool sorted = true,
  }) {
    final pointsIn = points
        .map((point) => DistancePoint(
            point, center.distance(lat: point.latitude, lng: point.longitude)))
        .where((collectionPoint) => collectionPoint.distance <= radius * 1.02)
        .toList();
    if (sorted) {
      pointsIn.sort();
      return pointsIn;
    }
    return pointsIn;
  }
}
