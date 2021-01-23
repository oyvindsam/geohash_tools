import 'dart:math';

import 'point.dart';

class GeoHashToolsUtil {
  GeoHashToolsUtil._();

  static const _BASE32_CODES = '0123456789bcdefghjkmnpqrstuvwxyz';
  static const _base32CodesDic = {
    '0': 0,
    '1': 1,
    '2': 2,
    '3': 3,
    '4': 4,
    '5': 5,
    '6': 6,
    '7': 7,
    '8': 8,
    '9': 9,
    'b': 10,
    'c': 11,
    'd': 12,
    'e': 13,
    'f': 14,
    'g': 15,
    'h': 16,
    'j': 17,
    'k': 18,
    'm': 19,
    'n': 20,
    'p': 21,
    'q': 22,
    'r': 23,
    's': 24,
    't': 25,
    'u': 26,
    'v': 27,
    'w': 28,
    'x': 29,
    'y': 30,
    'z': 31
  };

  ///
  /// Significant Figure Hash Length
  ///
  /// This is a quick and dirty lookup to figure out how long our hash
  /// should be in order to guarantee a certain amount of trailing
  /// significant figures. This was calculated by determining the error:
  /// 45/2^(n-1) where n is the number of bits for a latitude or
  /// longitude. Key is # of desired sig figs, value is minimum length of
  /// the geohash.
  /// @type Array
  // Desired sig figs:    0  1  2  3   4   5   6   7   8   9  10
  static const _sigfigHashLength = [0, 5, 7, 8, 11, 12, 13, 15, 16, 17, 18];

  ///
  /// Encode
  /// Create a geohash from latitude and longitude
  /// that is 'number of chars' long
  static String encode(double latitude, double longitude, {int numberOfChars = 9}) {

    final chars = [];
    int bits = 0, bitsTotal = 0, hashValue = 0;
    double maxLat = 90, minLat = -90, maxLon = 180, minLon = -180, mid;

    while (chars.length < numberOfChars) {
      if (bitsTotal % 2 == 0) {
        mid = (maxLon + minLon) / 2;
        if (longitude > mid) {
          hashValue = (hashValue << 1) + 1;
          minLon = mid;
        } else {
          hashValue = (hashValue << 1) + 0;
          maxLon = mid;
        }
      } else {
        mid = (maxLat + minLat) / 2;
        if (latitude > mid) {
          hashValue = (hashValue << 1) + 1;
          minLat = mid;
        } else {
          hashValue = (hashValue << 1) + 0;
          maxLat = mid;
        }
      }

      bits++;
      bitsTotal++;
      if (bits == 5) {
        final code = _BASE32_CODES[hashValue];
        chars.add(code);
        bits = 0;
        hashValue = 0;
      }
    }

    return chars.join('');
  }

  ///
  /// Decode Bounding box
  ///
  /// Decode a hashString into a bound box that matches it.
  /// Data returned in a List [minLat, minLon, maxLat, maxLon]
  static List<double> _decodeBbox(String hashString) {
    bool isLon = true;
    double maxLat = 90, minLat = -90, maxLon = 180, minLon = -180, mid;

    int hashValue = 0;
    for (int i = 0, l = hashString.length; i < l; i++) {
      final code = hashString[i].toLowerCase();
      hashValue = _base32CodesDic[code];

      for (int bits = 4; bits >= 0; bits--) {
        final bit = (hashValue >> bits) & 1;
        if (isLon) {
          mid = (maxLon + minLon) / 2;
          if (bit == 1) {
            minLon = mid;
          } else {
            maxLon = mid;
          }
        } else {
          mid = (maxLat + minLat) / 2;
          if (bit == 1) {
            minLat = mid;
          } else {
            maxLat = mid;
          }
        }
        isLon = !isLon;
      }
    }
    return [minLat, minLon, maxLat, maxLon];
  }

  ///
  /// Decode a [hashString] into a pair of latitude and longitude.
  static Coordinates decode(String hashString) {
    List<double> bbox = _decodeBbox(hashString);
    final lat = (bbox[0] + bbox[2]) / 2;
    final lng = (bbox[1] + bbox[3]) / 2;
    return Coordinates(lat, lng);
  }

  ///
  /// Decode a [hashString] into a pair of latitude and longitude.
  /// A map is returned with keys 'latitude', 'longitude','latitudeError','longitudeError'
  static Map<String, double> decodeWithError(String hashString) {
    List<double> bbox = _decodeBbox(hashString);
    final lat = (bbox[0] + bbox[2]) / 2;
    final lon = (bbox[1] + bbox[3]) / 2;
    final latErr = bbox[2] - lat;
    final lonErr = bbox[3] - lon;
    return {
      'latitude': lat,
      'longitude': lon,
      'latitudeError': latErr,
      'longitudeError': lonErr,
    };
  }

  ///
  /// Neighbor
  ///
  /// Find neighbor of a geohash string in certain direction.
  /// Direction is a two-element array, i.e. [1,0] means north, [-1,-1] means southwest.
  ///
  /// direction [lat, lon], i.e.
  /// [1,0] - north
  /// [1,1] - northeast
  static String neighbor(String hashString, List<int> direction) {
    final lonLat = decodeWithError(hashString);
    final neighborLat =
        lonLat['latitude'] + direction[0] * lonLat['latitudeError'] * 2;
    final neighborLon =
        lonLat['longitude'] + direction[1] * lonLat['longitudeError'] * 2;
    return encode(neighborLat, neighborLon, numberOfChars: hashString.length);
  }

  ///
  /// Neighbors
  /// Returns all neighbors' hashstrings clockwise from north around to northwest
  /// Optionally pass already computed decoded hash.
  /// 7 0 1
  /// 6 X 2
  /// 5 4 3
  static List<String> neighbors(String hashString) {
    int hashStringLength = hashString.length;
    final lonlat = decodeWithError(hashString);
    double lat = lonlat['latitude'];
    double lon = lonlat['longitude'];
    double latErr = lonlat['latitudeError'] * 2;
    double lonErr = lonlat['longitudeError'] * 2;

    double neighborLat, neighborLon;

    String encodeNeighbor(neighborLatDir, neighborLonDir) {
      neighborLat = lat + neighborLatDir * latErr;
      neighborLon = lon + neighborLonDir * lonErr;
      return encode(neighborLat, neighborLon, numberOfChars: hashStringLength);
    }

    final neighborHashList = [
      encodeNeighbor(1, 0),
      encodeNeighbor(1, 1),
      encodeNeighbor(0, 1),
      encodeNeighbor(-1, 1),
      encodeNeighbor(-1, 0),
      encodeNeighbor(-1, -1),
      encodeNeighbor(0, -1),
      encodeNeighbor(1, -1)
    ];

    return neighborHashList;
  }

  static int setPrecision(double km) {
    /*
      * 1	≤ 5,000km	×	5,000km
      * 2	≤ 1,250km	×	625km
      * 3	≤ 156km	×	156km
      * 4	≤ 39.1km	×	19.5km
      * 5	≤ 4.89km	×	4.89km
      * 6	≤ 1.22km	×	0.61km
      * 7	≤ 153m	×	153m
      * 8	≤ 38.2m	×	19.1m
      * 9	≤ 4.77m	×	4.77m
      *
     */

    if (km <= 0.00477)
      return 9;
    else if (km <= 0.0382)
      return 8;
    else if (km <= 0.153)
      return 7;
    else if (km <= 1.22)
      return 6;
    else if (km <= 4.89)
      return 5;
    else if (km <= 39.1)
      return 4;
    else if (km <= 156)
      return 3;
    else if (km <= 1250)
      return 2;
    else
      return 1;
  }

  static const double _MAX_SUPPORTED_RADIUS = 8587;

  // Length of a degree latitude at the equator
  static const double _METERS_PER_DEGREE_LATITUDE = 110574;

  // The equatorial circumference of the earth in meters
  static const double _EARTH_MERIDIONAL_CIRCUMFERENCE = 40007860;

  // The equatorial radius of the earth in meters
  static const double _EARTH_EQ_RADIUS = 6378137;

  // The meridional radius of the earth in meters
  static const double _EARTH_POLAR_RADIUS = 6357852.3;

  /* The following value assumes a polar radius of
     * r_p = 6356752.3
     * and an equatorial radius of
     * r_e = 6378137
     * The value is calculated as e2 == (r_e^2 - r_p^2)/(r_e^2)
     * Use exact value to avoid rounding errors
     */
  static const double _EARTH_E2 = 0.00669447819799;

  // Cutoff for floating point calculations
  static const double _EPSILON = 1e-12;

  static const double _radius = (_EARTH_EQ_RADIUS + _EARTH_POLAR_RADIUS) / 2;

  static double distance(Coordinates location1, Coordinates location2) {
    return calcDistance(location1.latitude, location1.longitude,
        location2.latitude, location2.longitude);
  }

  static double calcDistance(
      double lat1, double long1, double lat2, double long2) {
    // Earth's mean radius in meters
    final latDelta = _toRadians(lat1 - lat2);
    final lonDelta = _toRadians(long1 - long2);

    final a = (sin(latDelta / 2) * sin(latDelta / 2)) +
        (cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(lonDelta / 2) *
            sin(lonDelta / 2));
    final distance = _radius * 2 * atan2(sqrt(a), sqrt(1 - a)) / 1000;
    return double.parse(distance.toStringAsFixed(3));
  }

  static double _toRadians(double num) {
    return num * (pi / 180.0);
  }
}
