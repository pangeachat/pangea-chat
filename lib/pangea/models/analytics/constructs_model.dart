import 'dart:developer';

import 'package:fluffychat/pangea/enum/construct_use_type_enum.dart';
import 'package:fluffychat/pangea/utils/error_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:matrix/matrix.dart';

import '../../enum/construct_type_enum.dart';

class ConstructAnalyticsModel {
  List<OneConstructUse> uses;

  ConstructAnalyticsModel({
    this.uses = const [],
  });

  static const _usesKey = "uses";

  factory ConstructAnalyticsModel.fromJson(Map<String, dynamic> json) {
    final List<OneConstructUse> uses = [];

    if (json[_usesKey] is List) {
      // This is the new format
      for (final useJson in json[_usesKey]) {
        // grammar construct uses are deprecated so but some are saved
        // here we're filtering from data
        if (["grammar", "g"].contains(useJson['constructType'])) {
          continue;
        } else {
          uses.add(OneConstructUse.fromJson(useJson));
        }
      }
    } else {
      debugger(when: kDebugMode);
      ErrorHandler.logError(m: "Analytics room with non-list uses");
    }

    return ConstructAnalyticsModel(
      uses: uses,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _usesKey: uses.map((use) => use.toJson()).toList(),
    };
  }
}

class OneConstructUse {
  String? lemma;
  String? form;
  List<String> categories;
  ConstructTypeEnum constructType;
  ConstructUseTypeEnum useType;

  /// Used to unqiuely identify the construct use. Useful in the case
  /// that a users makes the same type of mistake multiple times in a
  /// message, and those uses need to be disinguished.
  String? id;
  ConstructUseMetaData metadata;

  OneConstructUse({
    required this.useType,
    required this.lemma,
    required this.constructType,
    required this.metadata,
    this.categories = const [],
    this.form,
    this.id,
  });

  String get chatId => metadata.roomId;
  String get msgId => metadata.eventId!;
  DateTime get timeStamp => metadata.timeStamp;

  factory OneConstructUse.fromJson(Map<String, dynamic> json) {
    final constructType = json['constructType'] != null
        ? ConstructTypeUtil.fromString(json['constructType'])
        : null;
    debugger(when: kDebugMode && constructType == null);

    List<String> categories = [];
    final categoriesEntry = json['cat'] ?? json['categories'];
    if (categoriesEntry != null) {
      if (categoriesEntry is List) {
        categories = List<String>.from(categoriesEntry);
      } else if (categoriesEntry is String) {
        categories = [categoriesEntry];
      }
    }

    return OneConstructUse(
      useType: ConstructUseTypeUtil.fromString(json['useType']),
      lemma: json['lemma'],
      form: json['form'],
      categories: categories,
      constructType: constructType ?? ConstructTypeEnum.vocab,
      id: json['id'],
      metadata: ConstructUseMetaData(
        eventId: json['msgId'],
        roomId: json['chatId'],
        timeStamp: DateTime.parse(json['timeStamp']),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'useType': useType.string,
      'chatId': metadata.roomId,
      'timeStamp': metadata.timeStamp.toIso8601String(),
      'form': form,
      'msgId': metadata.eventId,
    };

    data['lemma'] = lemma!;
    data['constructType'] = constructType.string;

    if (id != null) data['id'] = id;
    data['categories'] = categories;
    return data;
  }

  Room? getRoom(Client client) {
    return client.getRoomById(metadata.roomId);
  }

  Future<Event?> getEvent(Client client) async {
    final Room? room = getRoom(client);
    if (room == null || metadata.eventId == null) return null;
    return room.getEventById(metadata.eventId!);
  }

  int get pointValue => useType.pointValue;
}

class ConstructUseMetaData {
  String? eventId;
  String roomId;
  DateTime timeStamp;

  ConstructUseMetaData({
    required this.roomId,
    required this.timeStamp,
    this.eventId,
  });
}
