

import 'package:geohash_tools/geohash_tools.dart';

class SomeMapMarkerClass extends GeoHashPoint {
  final double latitude;
  final double longitude;

  SomeMapMarkerClass(
      this.latitude,
      this.longitude,
      ) : super(latitude, longitude);
}

class SomeOtherMapMarkerClass extends GeoHashPoint {
  final String geohash;
  SomeOtherMapMarkerClass(this.geohash) : super.fromHash(geohash);
}


void main() {
  final markerList = [
    SomeMapMarkerClass(12.5, 10.1),
    SomeMapMarkerClass(13.5, 10.3),
    SomeMapMarkerClass(14.5, 10.4),
    SomeOtherMapMarkerClass('s4ppjgd9g0c'),
    SomeOtherMapMarkerClass('s4pub49ps7m'),
    SomeOtherMapMarkerClass('s1zc2n9hu2m'),
  ];

  final center = GeoHashPoint(12.5, 10.2);
  final collection = GeoHashCollection(markerList);
  final area = GeoHashArea(markerList, radius: 100);

  print('collection within ${collection.withinDistance(center: center, radius: 100)}');
  print('area within: ${area.withinDistance(center)}');
  print('area within: ${area.within(center)}');

}