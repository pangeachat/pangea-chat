class ModelKey {
  ///user model keys
  static const String userAccess = 'access';
  static const String userRefresh = 'refresh';
  static const String userProfile = 'profile';
  static const String userFullName = 'full_name';
  static const String userCreatedAt = 'created_at';
  static const String userPangeaUserId = 'pangea_user_id';
  static const String userDateOfBirth = 'date_of_birth';
  static const String userTargetLanguage = 'target_language';
  static const String userSourceLanguage = 'source_language';
  static const String userSpeaks = 'speaks';
  static const String userCountry = 'country';
  static const String userInterests = 'interests';
  static const String l2LanguageKey = 'target_language';
  static const String l1LanguageKey = 'source_language';
  static const String publicProfile = 'public';
  static const String userId = 'user_id';
  static const String toolSettings = 'tool_settings';
  static const String userSettings = 'user_settings';
  static const String instructionsSettings = 'instructions_settings';

  // matrix profile keys
  // making this a random string so that it's harder to guess
  static const String activatedTrialKey = '7C4EuKIsph';
  static const String autoPlayMessages = 'autoPlayMessages';
  static const String itAutoPlay = 'itAutoPlay';

  static const String clientClassCity = "city";
  static const String clientClassCountry = "country";
  static const String clientClassDominantLanguage = "dominantLanguage";
  static const String clientClassTargetLanguage = "targetLanguage";
  static const String clientClassDescription = "description";
  static const String clientLanguageLevel = "languageLevel";
  static const String clientSchool = "schoolName";

  static const String clientIsPublic = "isPublic";
  static const String clientIsOpenEnrollment = 'isOpenEnrollment';
  static const String clientIsOneToOneChatClass = 'oneToOneChatClass';
  static const String clientIsCreateRooms = 'isCreateRooms';
  static const String clientIsShareVideo = 'isShareVideo';
  static const String clientIsSharePhoto = 'isSharePhoto';
  static const String clientIsShareFiles = 'isShareFiles';
  static const String clientIsShareLocation = 'isShareLocation';
  static const String clientIsCreateStories = 'isCreateStories';
  static const String clientIsVoiceNotes = 'isVoiceNotes';
  static const String clientIsInviteOnlyStudents = 'isInviteOnlyStudents';

  static const String userL1 = "user_l1";
  static const String userL2 = "user_l2";
  static const String fullText = "full_text";
  static const String fullTextLang = "full_text_lang";
  static const String tokens = "tokens";
  static const String srcLang = "src_lang";
  static const String tgtLang = "tgt_lang";
  static const String word = "word";
  static const String lang = "lang";
  static const String deepL = "deepl";
  static const String offset = "offset";
  static const String length = "length";
  static const String langCode = 'lang_code';
  static const String confidence = 'confidence';
  // some old analytics rooms have langCode instead of lang_code in the room creation content
  static const String oldLangCode = 'langCode';
  static const String wordLang = "word_lang";
  static const String lemma = "lemma";
  static const String saveVocab = "save_vocab";
  static const String text = "text";
  static const String permissions = "permissions";
  static const String enableIGC = "enable_igc";
  static const String enableIT = "enable_it";
  static const String prevMessages = "prev_messages";
  static const String prevContent = "prev_content";
  static const String prevSender = "prev_sender";
  static const String prevTimestamp = "prev_timestamp";

  static const String originalSent = "original_sent";
  static const String originalWritten = "original_written";
  static const String tokensSent = "tokens_sent";
  static const String tokensWritten = "tokens_written";
  static const String choreoRecord = "choreo_record";

  static const String baseDefinition = "base_definition";
  static const String targetDefinition = "target_definition";
  static const String basePartOfSpeech = "base_part_of_speech";
  static const String targetPartOfSpeech = "target_part_of_speech";
  static const String partOfSpeech = "part_of_speech";
  static const String baseWord = "base_word";
  static const String targetWord = "target_word";
  static const String baseExampleSentence = "base_example_sentence";
  static const String targetExampleSentence = "target_example_sentence";

  //add goldTranslation, goldContinuance, chosenContinuance
  static const String goldTranslation = "gold_translation";
  static const String goldContinuance = "gold_continuance";
  static const String chosenContinuance = "chosen_continuance";

  // sourceText, currentText, bestContinuance, feedback_lang
  static const String sourceText = "src";
  static const String currentText = "current";
  static const String bestContinuance = "best_continuance";
  static const String feedbackLang = "feedback_lang";

  static const String transcription = "transcription";

  // bot options
  static const String languageLevel = "difficulty";
  static const String safetyModeration = "safety_moderation";
  static const String mode = "mode";
  static const String discussionTopic = "discussion_topic";
  static const String discussionKeywords = "discussion_keywords";
  static const String discussionTriggerReactionEnabled =
      "discussion_trigger_reaction_enabled";
  static const String discussionTriggerReactionKey =
      "discussion_trigger_reaction_key";
  static const String customSystemPrompt = "custom_system_prompt";
  static const String customTriggerReactionEnabled =
      "custom_trigger_reaction_enabled";
  static const String customTriggerReactionKey = "custom_trigger_reaction_key";

  static const String textAdventureGameMasterInstructions =
      "text_adventure_game_master_instructions";

  static const String prevEventId = "prev_event_id";
  static const String prevLastUpdated = "prev_last_updated";

  static const String gameState = "game_state";

  // // Round States
  // static const String currentCharacter = "current_character";
  // static const String currentCharacterText = "current_character_text";
  static const String startTime = "start_time";
  // static const String endPreviousRoundTime = "end_previous_round_time";
  // static const String phase = "phase";
  // static const String isGameEnd = "is_game_end";
  static const String playerScores = "player_scores";
  static const String winner = "winner";
  static const String narrator = "narrator";
  static const String character = "character";
  // static const String votes = "voters";
  static const String isInstructions = "is_instructions";
  static const String characterSuggestionIntention =
      "character_suggestion_intention";
  static const String sceneOptionMessageIds = "scene_option_message_ids";
  static const String sceneOptionMessageVisibleFrom =
      "scene_option_message_visible_from";
  static const String sceneOptionMessageVisibleTo =
      "scene_option_message_visible_to";
  static const String characterOptionMessageIds =
      "character_option_message_ids";
  static const String characterOptionMessageVisibleFrom =
      "character_option_message_visible_from";
  static const String characterOptionMessageVisibleTo =
      "character_option_message_visible_to";
  static const String instructionMessageVisibleFrom =
      "instruction_message_visible_from";
  static const String instructionMessageVisibleTo =
      "instruction_message_visible_to";
  // // static const String judge = "judge";

  // // Settings States
  // static const String delayBeforeNextRoundSeconds =
  //     "delay_before_next_round_seconds";
  // static const String roundSeconds = "round_seconds";
  // static const String delayRangeBeforeSendingMimicPlayerMessageSeconds =
  //     "delay_range_before_sending_mimic_player_message_seconds";
  // static const String maxRounds = "max_rounds";

  // // Story States
  // static const String storyDescription = "story_description";
  // static const String goalState = "goal_state";
  // static const String failState = "fail_state";
  // static const String goalStateCharacterText = "goal_state_character_text";
  // static const String failStateCharacterText = "fail_state_character_text";

  static const String characterMessages = "character_messages";
  static const String timerStarts = "timer_starts";
  static const String timerEnds = "timer_ends";
  static const String timerText = "timer_text";
  static const String playerCharacter = "player_character";
  static const String timerPositionAfterEventID =
      "timer_position_after_event_id";
  static const String playerMessageVisibleFrom = "player_message_visible_from";
  static const String playerMessageVisibleTo = "player_message_visible_to";
}
