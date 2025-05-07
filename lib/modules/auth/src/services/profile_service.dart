import 'dart:math';

class ProfileService {
  final List<String> _imageList = [
    "dance_sunglass_rabbit_bg.png",
    "float_astronaut_rabbit_bg.png",
    "fly_astronaut_rabbit_bg.png",
    "grep_star_person_bg.png",
    "hand_up_cheek_hamster_bg.png",
    "hug_carrot_rabbit_bg.png",
    "hug_teeth_rabbit_bg.png",
    "juggle_unicycle_rabbit_bg.png",
    "jump_skateboard_rabbit_bg.png",
    "lay_carrot_pile_rabbit_bg.png",
    "lay_carrot_rabbit_bg.png",
    "ride_carrot_rabbit_bg.png",
    "ride_sunglass_rabbit_bg.png",
    "run_teeth_rabbit_bg.png",
    "seat_moon_rabbit_bg.png",
    "seat_question_rabbit_bg.png",
    "seat_smartphone_rabbit_bg.png",
  ];

  final List<String> _nonBgImageList = [
    "dance_sunglass_rabbit.png",
    "float_astronaut_rabbit.png",
    "fly_astronaut_rabbit.png",
    "grep_star_person.png",
    "hand_up_cheek_hamster.png",
    "hug_carrot_rabbit.png",
    "hug_teeth_rabbit.png",
    "juggle_unicycle_rabbit.png",
    "jump_skateboard_rabbit.png",
    "lay_carrot_pile_rabbit.png",
    "lay_carrot_rabbit.png",
    "ride_carrot_rabbit.png",
    "ride_sunglass_rabbit.png",
    "run_teeth_rabbit.png",
    "seat_moon_rabbit.png",
    "seat_question_rabbit.png",
    "seat_smartphone_rabbit.png",
  ];

  String getRandomProfileImageUrl() {
    final random = Random();
    final randomImage = _imageList[random.nextInt(_imageList.length)];
    return "https://minio.nansan.site/nansan/character/$randomImage";
  }

  String getRandomProfileImageUrlNonBg() {
    final random = Random();
    final randomImage = _nonBgImageList[random.nextInt(_nonBgImageList.length)];
    return "https://minio.nansan.site/nansan/character/$randomImage";
  }
}
