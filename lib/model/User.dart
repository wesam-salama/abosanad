import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class User with ChangeNotifier {
  String email = '';
  String firstName = '';
  String lastName = '';
  Settings settings = Settings(allowPushNotifications: true);
  String phoneNumber = '';
  bool active = false;
  Timestamp lastOnlineTimestamp = Timestamp.now();
  String userID;
  String profilePictureURL = '';
  bool selected = false;
  String fcmToken = '';
  String appIdentifier = 'Flutter Instachatty ${Platform.operatingSystem}';

  User(
      {this.email,
      this.firstName,
      this.phoneNumber,
      this.lastName,
      this.active,
      this.lastOnlineTimestamp,
      this.settings,
      this.fcmToken,
      this.userID,
      this.profilePictureURL});

  String fullName() {
    return '$firstName $lastName';
  }

  factory User.fromJson(Map<String, dynamic> parsedJson) {
    return new User(
        email: parsedJson['email'] ?? "",
        firstName: parsedJson['firstName'] ?? '',
        lastName: parsedJson['lastName'] ?? '',
        active: parsedJson['active'] ?? false,
        lastOnlineTimestamp:
            parsedJson['lastOnlineTimestamp'] ?? Timestamp.now(),
        settings: Settings.fromJson(
            parsedJson['settings'] ?? {'allowPushNotifications': true}),
        phoneNumber: parsedJson['phoneNumber'] ?? "",
        fcmToken: parsedJson['fcmToken'] ?? '',
        userID: parsedJson['id'] ?? parsedJson['userID'] ?? '',
        profilePictureURL: parsedJson['profilePictureURL'] ?? "");
  }

  Map<String, dynamic> toJson() {
    return {
      'email': this.email,
      'firstName': this.firstName,
      'lastName': this.lastName,
      'settings': this.settings.toJson(),
      'phoneNumber': this.phoneNumber,
      'id': this.userID,
      'userID': this.userID,
      'active': this.active,
      'lastOnlineTimestamp': this.lastOnlineTimestamp,
      'fcmToken': this.fcmToken,
      'profilePictureURL': this.profilePictureURL,
      'appIdentifier': this.appIdentifier
    };
  }
}

class Settings {
  bool allowPushNotifications = true;

  Settings({this.allowPushNotifications});

  factory Settings.fromJson(Map<dynamic, dynamic> parsedJson) {
    return new Settings(
        allowPushNotifications: parsedJson['allowPushNotifications'] ?? true);
  }

  Map<String, dynamic> toJson() {
    return {'allowPushNotifications': this.allowPushNotifications};
  }
}
