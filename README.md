# GeoFlutterFire :earth_africa:

[![version][version-badge]][package]
[![MIT License][license-badge]][license]
[![PRs Welcome][prs-badge]](http://makeapullrequest.com)

GeoFlutterFire is an open-source library that allows you to store and query a set of keys based on their geographic location. At its heart, GeoFlutterFire simply stores locations with string keys. Its main benefit, however, is the possibility of retrieving only those keys within a given geographic area - all in realtime.

GeoFlutterFire uses the Firebase Firestore Database for data storage, allowing query results to be updated in realtime as they change. GeoFlutterFire selectively loads only the data near certain locations, keeping your applications light and responsive, even with extremely large datasets.

GeoFlutterFire is designed as a lightweight add-on to cloud_firestore plugin. To keep things simple, GeoFlutterFire stores data in its own format within your Firestore database. This allows your existing data format and Security Rules to remain unchanged while still providing you with an easy solution for geo queries.

Heavily influenced by [GeoFireX](https://github.com/codediodeio/geofirex) :fire::fire: from [Jeff Delaney](https://github.com/codediodeio) :sunglasses:

:tv: Checkout this amazing tutorial on [fireship](https://fireship.io/lessons/flutter-realtime-geolocation-firebase/) by Jeff, featuring the plugin!!

## Getting Started

You should ensure that you add GeoFlutterFire as a dependency in your flutter project.

```yaml
dependencies:
  geoflutterfire: <latest-version>
```

You can also reference the git repo directly if you want:

```yaml
dependencies:
  geoflutterfire:
    git: git://github.com/DarshanGowda0/GeoFlutterFire.git
```

You should then run `flutter packages get` or update your packages in IntelliJ.

## Example

There is a detailed example project in the `example` folder. Check that out or keep reading!

