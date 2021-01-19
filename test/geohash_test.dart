import 'package:test/test.dart';
import 'package:geohash_tools/geohash_tools.dart';

void main() {
  group('GeoHashTools tests..', () {
    final point1 = GeoHashPoint(60.0, 10.0);
    final point2 = GeoHashPoint(61.0, 11.0);
    final point3 = GeoHashPoint(65.0, 15.0);
    final center = GeoHashPoint(60.5, 10.0);
    final gfcAll = GeoHashArea([point1, point2, point3], radius: 9999);

    final dist12 = point1.distance(lat: point2.latitude, lng: point2.longitude);
    final dist21 = point2.distance(lat: point1.latitude, lng: point1.longitude);
    final dist13 = point1.distance(lat: point3.latitude, lng: point3.longitude);
    final dist23 = point2.distance(lat: point3.latitude, lng: point3.longitude);

    test('Check dist', () {

      expect(dist12, equals(dist21));
      expect(dist12, lessThan(dist13));
      expect(dist23, lessThan(dist13));
    });

    test('GeoHashCollectioon within calculation', () {


      final within0 = GeoHashArea([point1, point2, point3], radius: 0).within(center);
      expect(0, equals(within0.length), reason: 'Radius 0 should have 0 within.');

      final centerTo1 = center.distance(lat: point1.latitude, lng: point1.longitude);
      final within1 = GeoHashArea([point1, point2, point3], radius: centerTo1).within(center).map((e) => e.point);
      expect(within1, contains(point1), reason: 'Distance to point should be within');

      final gfcReverse = GeoHashArea([point3, point1, point2, point1], radius: 9999);
      final withingSorted = gfcReverse.within(center);

      print('sorted: $withingSorted');
      expect(withingSorted.map((e) => e.point), containsAllInOrder([point1, point1, point2, point3]), reason: 'Returns sorted');
    });
  });

}