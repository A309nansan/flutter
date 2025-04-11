class UserInfoModel {
  final int id;
  final String platformId;
  final String socialPlatform;
  final String email;
  final String nickName;
  final String role;
  final bool detailStatus;
  final String hashId;
  final String profileImageUrl;

  UserInfoModel({
    required this.id,
    required this.platformId,
    required this.socialPlatform,
    required this.email,
    required this.nickName,
    required this.role,
    required this.detailStatus,
    required this.hashId,
    required this.profileImageUrl,
  });

  factory UserInfoModel.fromJson(Map<String, dynamic> json) {
    return UserInfoModel(
      id: json['id'],
      platformId: json['platformId'],
      socialPlatform: json['socialPlatform'],
      email: json['email'],
      nickName: json['nickName'],
      role: json['role'],
      detailStatus: json['detailStatus'],
      hashId: json['hashId'],
      profileImageUrl: json['profileImageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'platformId': platformId,
      'socialPlatform': socialPlatform,
      'email': email,
      'nickName': nickName,
      'role': role,
      'detailStatus': detailStatus,
      'hashId': hashId,
      'profileImageUrl': profileImageUrl,
    };
  }
}