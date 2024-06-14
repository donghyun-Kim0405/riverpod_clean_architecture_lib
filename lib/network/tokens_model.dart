class TokensModel{
  String? accessToken;
  String? refreshToken;

  TokensModel({
    required this.accessToken,
    required this.refreshToken
  });

  factory TokensModel.fromJson(Map<String, dynamic> json) {
    return TokensModel(
        accessToken: json['accessToken'] as String?,
        refreshToken: json['refreshToken'] as String?
    );
  }

}