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

  GeoHashArea(this.points, {this.radius = 9999}) {
    precision = Util.setPrecision(radius);

    /// create geohash map with given precision (radius)
    points.forEach((point) {
      final hashkey = point.hash.substring(0, precision);
      if (!hashToPoints.containsKey(hashkey)) {
        hashToPoints[hashkey] = [point];
      } else {
        hashToPoints[hashkey].add(point);
      }
    });
  }

  /// Get all points within [radius] of [center], sorted by distance.
  List<DistancePoint> within(GeoHashPoint center) {
    final centerHash = center.hash.substring(0, precision);
    final areaHashes = GeoHashPoint.neighborsOf(hash: centerHash)
      ..add(centerHash);

    return areaHashes
        .where((areaHash) => hashToPoints.keys.contains(areaHash))
        .map((e) => hashToPoints[e])
        .expand((points) => points) // flatten list of geoHashPoints
        .map((point) => DistancePoint(
            point, center.distance(lat: point.latitude, lng: point.longitude)))
        .where((areaPoint) => areaPoint.distance <= radius * 1.02)
        .toList()
          ..sort();
  }
}

/// Non optimized storage of points in a list.
class GeoHashCollection {
  List<GeoHashPoint> points;

  GeoHashCollection(this.points);

  /// Will iterate though all points, filter out those that do not have a geohash
  /// prefix among the geohashes [radius] distance from [center], and return
  /// points sorted.
  List<DistancePoint> within({
    @required GeoHashPoint center,
    @required double radius,
  }) {
    final precision = Util.setPrecision(radius);
    final centerHash = center.hash.substring(0, precision);
    final areaHashes = GeoHashPoint.neighborsOf(hash: centerHash)
      ..add(centerHash);

    return points
        .where((point) =>
            areaHashes.any((hashString) => point.hash.startsWith(hashString)))
        .map((point) => DistancePoint(
            point, center.distance(lat: point.latitude, lng: point.longitude)))
        .where((collectionPoint) => collectionPoint.distance <= radius * 1.02)
        .toList()
          ..sort();
  }
}
