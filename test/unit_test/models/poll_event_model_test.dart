import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/models/location.dart';
import 'package:dima_app/models/poll_event_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  final List<Map<String, dynamic>> someLocations = [
    {
      "name": "Curma",
      "lat": 45.7874248,
      "lon": 6.9730618,
      "site": "Courmayeur, Valle d'Aosta / Vallée d'Aoste, 11013, Italia",
      "icon": "location_on_outlined",
    },
    {
      "lat": 46.258603,
      "lon": 10.508662,
      "name": "ponte di legno",
      "site":
          "Ponte di Legno, Comunità montana della valle Camonica, Brescia, Lombardia, 25056, Italia",
      "icon": "location_on_outlined",
    },
    {
      "lat": 45.4926642,
      "lon": 9.1928945,
      "name": "casa",
      "site": "Viale Zara",
      "icon": "home_outlined",
    },
    {
      "lat": 45.4789256,
      "lon": 9.2257514,
      "name": "polimi",
      "site": "Piazza Leonardo Da Vinci - Politecnico",
      "icon": "school_outlined",
    }
  ];

  Map<String, dynamic> utcDates = {
    "2023-05-18": [
      {"start": "06:00", "end": "08:00"},
      {"start": "06:30", "end": "08:00"},
      {"start": "16:00", "end": "17:00"},
    ],
    "2023-05-20": [
      {"start": "06:00", "end": "08:00"},
      {"start": "16:00", "end": "17:00"},
    ],
    "2023-05-22": [
      {"start": "06:00", "end": "08:00"},
    ],
  };

  final Map<String, dynamic> localDates = {
    "2023-05-18": [
      {"start": "08:00", "end": "10:00"},
      {"start": "08:30", "end": "10:00"},
      {"start": "18:00", "end": "19:00"},
    ],
    "2023-05-20": [
      {"start": "08:00", "end": "10:00"},
      {"start": "18:00", "end": "19:00"},
    ],
    "2023-05-22": [
      {"start": "08:00", "end": "10:00"},
    ],
  };

  final Map<String, dynamic> pollEventModelDates = {
    "2023-05-18": {
      "08:00-10:00": 1,
      "08:30-10:00": 1,
      "18:00-19:00": 1,
    },
    "2023-05-20": {
      "08:00-10:00": 1,
      "18:00-19:00": 1,
    },
    "2023-05-22": {
      "08:00-10:00": 1,
    },
  };

  utcDates = PollEventModel.datesToUtc(pollEventModelDates);

  final pollEventModel = PollEventModel(
    pollEventName: "test poll event model",
    organizerUid: "test organizer uid",
    pollEventDesc: "test poll event description",
    deadline: "2023-05-15 19:30:00",
    public: false,
    canInvite: false,
    dates: localDates,
    locations: someLocations.map((e) => Location.fromMap(e)).toList(),
    isClosed: false,
  );

  final pollEventFirebase = {
    "pollEventName": "test poll event model",
    "organizerUid": "test organizer uid",
    "pollEventDesc": "test poll event description",
    "deadline": Timestamp.fromDate(
        DateFormat("yyyy-MM-dd HH:mm:ss").parse("2023-05-15 17:30:00")),
    "public": false,
    "canInvite": false,
    "dates": utcDates,
    "locations": someLocations,
    "isClosed": false,
  };

  group('PollEventModel', () {
    test('datesToUtc and datesToLocal method should work correctly', () {
      Map<String, dynamic> testDatesUtc =
          PollEventModel.datesToUtc(pollEventModelDates);
      Map<String, dynamic> testDatesLocal =
          PollEventModel.datesToLocal(testDatesUtc);
      expect(testDatesLocal, localDates);
    });

    test('firebaseDocToObj method should work correctly', () {
      PollEventModel obj = PollEventModel.firebaseDocToObj(pollEventFirebase);
      expect(obj, pollEventModel);
    });

    test('copyWith method should work correctly', () {
      final copy =
          pollEventModel.copyWith(pollEventName: 'another pollEventName');
      expect(copy.pollEventName, 'another pollEventName');
      expect(copy.pollEventDesc, 'test poll event description');
    });

    test('toMap and fromMap should work correctly', () {
      final map = pollEventModel.toMap();
      final fromMap = PollEventModel.fromMap(map);
      expect(fromMap, pollEventModel);
    });

    test('toString should work correctly', () {
      expect(pollEventModel.toString(),
          "PollEventCollection(pollEventName: test poll event model, organizerUid: test organizer uid, pollEventDesc: test poll event description, deadline: 2023-05-15 19:30:00, public: false, canInvite: false, dates: {2023-05-18: [{start: 08:00, end: 10:00}, {start: 08:30, end: 10:00}, {start: 18:00, end: 19:00}], 2023-05-20: [{start: 08:00, end: 10:00}, {start: 18:00, end: 19:00}], 2023-05-22: [{start: 08:00, end: 10:00}]}, locations: [Location(name: Curma, site: Courmayeur, Valle d'Aosta / Vallée d'Aoste, 11013, Italia, lat: 45.7874248, lon: 6.9730618, icon: location_on_outlined), Location(name: ponte di legno, site: Ponte di Legno, Comunità montana della valle Camonica, Brescia, Lombardia, 25056, Italia, lat: 46.258603, lon: 10.508662, icon: location_on_outlined), Location(name: casa, site: Viale Zara, lat: 45.4926642, lon: 9.1928945, icon: home_outlined), Location(name: polimi, site: Piazza Leonardo Da Vinci - Politecnico, lat: 45.4789256, lon: 9.2257514, icon: school_outlined)], isClosed: false)");
    });

    test('Equality and hashCode should work correctly', () {
      final copy = pollEventModel.copyWith();
      expect(copy, pollEventModel);
      expect(copy.hashCode, pollEventModel.hashCode);
    });
  });
}
