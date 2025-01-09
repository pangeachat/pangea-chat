part of "pangea_room_extension.dart";

extension AnalyticsRoomExtension on Room {
  /// Join analytics rooms in space.
  /// Allows teachers to join analytics rooms without being invited.
  Future<void> _joinAnalyticsRoomsInSpace() async {
    try {
      if (!isSpace) {
        debugger(when: kDebugMode);
        return;
      }

      if (client.userID == null || !isRoomAdmin) return;
      final spaceHierarchy = await client.getSpaceHierarchy(
        id,
        maxDepth: 1,
      );

      final analyticsRooms = spaceHierarchy.rooms
          .where(
            (r) =>
                r.roomType == PangeaRoomTypes.analytics &&
                !client.rooms.any((room) => room.id == r.roomId),
          )
          .map((r) => r.roomId)
          .toList();

      await Future.wait(analyticsRooms.map(_joinAnalyticsRoom));
    } catch (err, s) {
      ErrorHandler.logError(
        e: err,
        s: s,
        data: {
          "spaceID": id,
        },
      );
      return;
    }
  }

  Future<void> _joinAnalyticsRoom(String roomID) async {
    final syncFuture = client.waitForRoomInSync(roomID);
    await joinSpaceChild(roomID).catchError((err, s) {
      debugPrint("Failed to join analytics room $roomID in space $id");
      ErrorHandler.logError(
        e: err,
        m: "Failed to join analytics room $roomID in space $id",
        s: s,
        data: {
          "roomID": roomID,
          "spaceID": id,
        },
      );
    });
    await syncFuture;
  }

  // add 1 analytics room to 1 space
  Future<void> _addAnalyticsRoomToSpace(Room analyticsRoom) async {
    if (!isSpace) {
      debugPrint("addAnalyticsRoomToSpace called on non-space room");
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: "addAnalyticsRoomToSpace called on non-space room",
        ),
      );
      return Future.value();
    }

    // Checks that user has permission to add child to space
    if (!canSendEvent(EventTypes.SpaceChild)) return;
    if (spaceChildren.any((sc) => sc.roomId == analyticsRoom.id)) return;

    try {
      await setSpaceChild(analyticsRoom.id);
    } catch (err) {
      debugPrint(
        "Failed to add analytics room ${analyticsRoom.id} for student to space $id",
      );
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: "Failed to add analytics room to space $id",
        ),
      );
    }
  }

  /// Add analytics room to all spaces the user is a student in (1 analytics room to all spaces).
  /// Enables teachers to join student analytics rooms via space hierarchy.
  /// Will not always work, as there may be spaces where students don't have permission to add chats,
  /// but allows teachers to join analytics rooms without being invited.
  void _addAnalyticsRoomToSpaces() {
    if (!isAnalyticsRoomOfUser(client.userID!)) return;
    Future.wait(
      client.rooms
          .where(
            (room) =>
                room.isSpace &&
                !room.spaceChildren.any((sc) => sc.roomId == id),
          )
          .map((space) => space.addAnalyticsRoomToSpace(this)),
    );
  }

  /// Add all the user's analytics rooms to 1 space.
  void _addAnalyticsRoomsToSpace() {
    Future.wait(
      client.allMyAnalyticsRooms.map((room) => addAnalyticsRoomToSpace(room)),
    );
  }

  /// Invite teachers of 1 space to 1 analytics room
  Future<void> _inviteSpaceAdminsToAnalyticsRoom(Room analyticsRoom) async {
    if (!isSpace) return;

    List<User> analyticsParticipants = analyticsRoom.getParticipants();
    if (!analyticsRoom.participantListComplete) {
      analyticsParticipants = await analyticsRoom.requestParticipants();
    }

    List<User> spaceParticipants = getParticipants();
    if (!participantListComplete) {
      spaceParticipants = await requestParticipants();
    }

    final spaceAdmins = spaceParticipants
        .where(
          (participant) =>
              participant.powerLevel >= ClassDefaultValues.powerLevelOfAdmin &&
              participant.id != BotName.byEnvironment,
        )
        .toList();

    final List<User> uninvitedTeachers = spaceAdmins
        .where(
          (admin) => !analyticsParticipants.any((user) => user.id == admin.id),
        )
        .toList();

    if (analyticsRoom.canSendEvent(EventTypes.RoomMember)) {
      Future.wait(
        uninvitedTeachers.map(
          (teacher) => analyticsRoom.invite(teacher.id).catchError((err, s) {
            ErrorHandler.logError(
              e: err,
              m: "Failed to invite teacher ${teacher.id} to analytics room ${analyticsRoom.id}",
              s: s,
              data: {
                "teacherID": teacher.id,
                "analyticsRoomID": analyticsRoom.id,
              },
            );
          }),
        ),
      );
    }
  }

  /// Invite all the user's teachers to 1 analytics room.
  /// Handles case when students cannot add analytics room to space
  /// so teacher is still able to get analytics data for this student.
  void _inviteAdminsToAnalyticsRoom() {
    if (client.userID == null || !isAnalyticsRoomOfUser(client.userID!)) return;
    final spaces = client.rooms.where((room) => room.isSpace).toList();
    Future.wait(
      spaces.map(
        (space) => space.inviteSpaceAdminsToAnalyticsRoom(this),
      ),
    );
  }

  /// Invite teachers of 1 space to all users' analytics rooms
  void _inviteSpaceAdminsToAnalyticsRooms() {
    Future.wait(
      client.allMyAnalyticsRooms.map(
        (room) => inviteSpaceAdminsToAnalyticsRoom(room),
      ),
    );
  }

  Future<DateTime?> _analyticsLastUpdated(String userId) async {
    final List<Event> events =
        await getRoomAnalyticsEvents(count: 1, userID: userId);
    if (events.isEmpty) return null;
    return events.first.originServerTs;
  }

  Future<List<ConstructAnalyticsEvent>?> _getAnalyticsEvents({
    required String userId,
    DateTime? since,
  }) async {
    final events = await getRoomAnalyticsEvents(userID: userId);
    final List<ConstructAnalyticsEvent> analyticsEvents = [];
    for (final Event event in events) {
      analyticsEvents.add(ConstructAnalyticsEvent(event: event));
    }

    return analyticsEvents;
  }

  String? get _madeForLang {
    final creationContent = getState(EventTypes.RoomCreate)?.content;
    return creationContent?.tryGet<String>(ModelKey.langCode) ??
        creationContent?.tryGet<String>(ModelKey.oldLangCode);
  }

  bool _isMadeForLang(String langCode) {
    final creationContent = getState(EventTypes.RoomCreate)?.content;
    return creationContent?.tryGet<String>(ModelKey.langCode) == langCode ||
        creationContent?.tryGet<String>(ModelKey.oldLangCode) == langCode;
  }

  /// Sends construct events to the server.
  ///
  /// The [uses] parameter is a list of [OneConstructUse] objects representing the
  /// constructs to be sent. To prevent hitting the maximum event size, the events
  /// are chunked into smaller lists. Each chunk is sent as a separate event.
  Future<void> _sendConstructsEvent(
    List<OneConstructUse> uses,
  ) async {
    // It's possible that the user has no info to send yet, but to prevent trying
    // to load the data over and over again, we'll sometimes send an empty event to
    // indicate that we have checked and there was no data.
    if (uses.isEmpty) {
      final constructsModel = ConstructAnalyticsModel(uses: []);
      await sendEvent(
        constructsModel.toJson(),
        type: PangeaEventTypes.construct,
      );
      return;
    }

    // these events can get big, so we chunk them to prevent hitting the max event size.
    // go through each of the uses being sent and add them to the current chunk until
    // the size (in bytes) of the current chunk is greater than the max event size, then
    // start a new chunk until all uses have been added.
    final List<List<OneConstructUse>> useChunks = [];
    List<OneConstructUse> currentChunk = [];
    int currentChunkSize = 0;

    for (final use in uses) {
      // get the size, in bytes, of the json representation of the use
      final json = use.toJson();
      final jsonString = jsonEncode(json);
      final jsonSizeInBytes = utf8.encode(jsonString).length;

      // If this use would tip this chunk over the size limit,
      // add it to the list of all chunks and start a new chunk.
      //
      // I tested with using the maxPDUSize constant, but the events
      // were still too large. 50000 seems to be a safe number of bytes.
      if (currentChunkSize + jsonSizeInBytes > (maxPDUSize - 10000)) {
        useChunks.add(currentChunk);
        currentChunk = [];
        currentChunkSize = 0;
      }

      // add this use to the current chunk
      currentChunk.add(use);
      currentChunkSize += jsonSizeInBytes;
    }

    if (currentChunk.isNotEmpty) {
      useChunks.add(currentChunk);
    }

    for (final chunk in useChunks) {
      final constructsModel = ConstructAnalyticsModel(uses: chunk);
      await sendEvent(
        constructsModel.toJson(),
        type: PangeaEventTypes.construct,
      );
    }
  }
}
