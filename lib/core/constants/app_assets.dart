abstract final class AppAssets {
  static const String bunlyIcon = 'assets/images/iconapp2.jpeg';
  static const String googleG = 'assets/icons/google_g.png';

  static const List<String> allBunly = [
    ...BunlyEmotions.all,
    ...BunlyPoses.all,
    ...BunlyActivities.all,
  ];
}

abstract final class OnboardingArt {
  static const String _base = 'assets/images/onboarding';
  static const String socialProof = '$_base/social_proof.png';
  static const String journeyLandscape = '$_base/journey_landscape.png';
  static const String sky = '$_base/sky.png';
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

  static const List<String> all = [
    jumping,
    delighted,
    sitting,
    huggingStar,
    proud,
    winking,
  ];
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
