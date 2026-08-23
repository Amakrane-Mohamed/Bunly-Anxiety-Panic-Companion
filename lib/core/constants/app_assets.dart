abstract final class AppAssets {
  static const String bunlyIcon = 'assets/images/iconapp2.jpeg';
  static const String googleG = 'assets/icons/google_g.png';

  static const List<String> allBunly = [
    ...BunlyEmotions.all,
    ...BunlyPoses.all,
    ...BunlyActivities.all,
    ...BunlyCards.all,
    ...BunlyPanic.all,
    ...BunlyJourney.all,
    ...BunlyInsights.all,
    BunlyToday.home,
    BunlyToday.sleeping,
    ...BunlyYou.all,
  ];
}

abstract final class OnboardingArt {
  static const String _base = 'assets/images/onboarding';
  static const String socialProof = '$_base/social_proof.png';
  static const String journeyLandscape = '$_base/journey_landscape.png';
  static const String sky = '$_base/sky.png';
  static const String house = '$_base/house.png';
  static const String doctor = '$_base/doctor.png';
  static const String paywall = '$_base/paywall.png';
  static const String iconBefore = '$_base/icon_before.png';
  static const String iconAfter = '$_base/icon_after.png';
}

abstract final class BunlyEmotions {
  static const String _base = 'assets/images/bunly/emotions';
  static const String laughing = '$_base/laughing.png';
  static const String surprised = '$_base/surprised.png';
  static const String excited = '$_base/excited.png';
  static const String smirking = '$_base/smirking.png';
  static const String wow = '$_base/wow.png';
  static const String content = '$_base/content.png';
  static const String giggling = '$_base/giggling.png';
  static const String sly = '$_base/sly.png';
  static const String happy = '$_base/happy.png';

  static const List<String> all = [
    laughing,
    surprised,
    excited,
    smirking,
    wow,
    content,
    giggling,
    sly,
    happy,
  ];
}

abstract final class BunlyPoses {
  static const String _base = 'assets/images/bunly/poses';
  static const String jumping = '$_base/jumping.png';
  static const String delighted = '$_base/delighted.png';
  static const String sitting = '$_base/sitting.png';
  static const String huggingStar = '$_base/hugging_star.png';
  static const String proud = '$_base/proud.png';
  static const String winking = '$_base/winking.png';
  static const String happyWin = 'assets/images/bunly/happy_win.png';

  static const List<String> all = [
    jumping,
    delighted,
    sitting,
    huggingStar,
    proud,
    winking,
    happyWin,
  ];
}

abstract final class BunlyPanic {
  static const String _base = 'assets/images/bunly/panic';
  static const String helpOffice = '$_base/help_office.jpg';
  static const String readyToHelp = '$_base/ready_to_help.png';
  static const String breathing = '$_base/breathing.png';
  static const String grounding = '$_base/grounding.png';
  static const String countingDown = '$_base/counting_down.png';
  static const String staying = '$_base/staying.png';
  static const String easing = '$_base/easing.png';
  static const String passed = '$_base/passed.png';
  static const String recovery = '$_base/recovery.png';

  static const List<String> all = [
    helpOffice,
    readyToHelp,
    breathing,
    grounding,
    countingDown,
    staying,
    easing,
    passed,
    recovery,
  ];
}

abstract final class BunlyJourney {
  static const String _base = 'assets/images/bunly/journey';
  static const String pathNight = '$_base/path_night.jpg';
  static const String firstStep = '$_base/first_step.png';
  static const String victory = '$_base/victory.png';
  static const String pathAhead = '$_base/path_ahead.png';
  static const String graduation = '$_base/graduation.png';
  static const String streak = '$_base/streak.png';
  static const String milestone = '$_base/milestone.png';
  static const String growth = '$_base/growth.png';
  static const String encouragement = '$_base/encouragement.png';

  static const List<String> all = [
    pathNight,
    firstStep,
    victory,
    pathAhead,
    graduation,
    streak,
    milestone,
    growth,
    encouragement,
  ];
}

abstract final class BunlyInsights {
  static const String _base = 'assets/images/bunly/insights';
  static const String horizon = '$_base/horizon.jpg';
  static const String analyzing = '$_base/analyzing.png';
  static const String thinking = '$_base/thinking.png';
  static const String discovery = '$_base/discovery.png';
  static const String empty = '$_base/empty.png';
  static const String progress = '$_base/progress.png';
  static const String lowMood = '$_base/low_mood.png';
  static const String tracking = '$_base/tracking.png';

  static const List<String> all = [
    horizon,
    analyzing,
    thinking,
    discovery,
    empty,
    progress,
    lowMood,
    tracking,
  ];

  static String forStore({
    required bool hasCheckIns,
    required bool hasEpisodes,
    required bool checkedInToday,
    required int handledMoments,
    required int checkInCount,
    int? latestMood,
  }) {
    if (!hasCheckIns && !hasEpisodes) return empty;
    if (latestMood != null && latestMood <= 2) return lowMood;
    if (handledMoments >= 2) return progress;
    if (checkedInToday) return discovery;
    if (checkInCount >= 2) return tracking;
    if (hasEpisodes) return analyzing;
    return thinking;
  }
}

abstract final class BunlyToday {
  static const String home = 'assets/images/bunly/today/home.png';
  static const String sleeping = 'assets/images/bunly/today/sleeping.png';
}

abstract final class BunlyYou {
  static const String _base = 'assets/images/bunly/you';
  static const String nightSky = '$_base/night_sky.jpg';

  static const List<String> all = [nightSky];
}

abstract final class BunlyActivities {
  static const String _base = 'assets/images/bunly/activities';
  static const String thinking = '$_base/thinking.png';
  static const String worried = '$_base/worried.png';
  static const String working = '$_base/working.png';
  static const String detective = '$_base/detective.png';
  static const String gardening = '$_base/gardening.png';
  static const String gifting = '$_base/gifting.png';

  static const List<String> all = [
    thinking,
    worried,
    working,
    detective,
    gardening,
    gifting,
  ];
}

abstract final class BunlyCards {
  static const String _base = 'assets/images/bunly/cards';
  static const String curiosity = '$_base/curiosity.png';
  static const String anxious = '$_base/anxious.png';
  static const String problemSolver = '$_base/problem_solver.png';
  static const String investigator = '$_base/investigator.png';
  static const String nurturer = '$_base/nurturer.png';
  static const String kindHeart = '$_base/kind_heart.png';

  static const List<String> all = [
    curiosity,
    anxious,
    problemSolver,
    investigator,
    nurturer,
    kindHeart,
  ];
}
