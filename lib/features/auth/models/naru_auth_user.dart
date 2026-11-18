import '../../../shared/models/model_json.dart';

class NaruAuthUser {
  const NaruAuthUser({
    required this.id,
    required this.displayName,
    this.email,
    this.phone,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
  });

  final String id;
  final String displayName;
  final String? email;
  final String? phone;
  final bool isEmailVerified;
  final bool isPhoneVerified;

  factory NaruAuthUser.fromJson(ModelJsonMap json) => NaruAuthUser(
    id: ModelJson.requiredString(json, 'id'),
    displayName: ModelJson.requiredString(json, 'displayName'),
    email: ModelJson.optionalString(json, 'email'),
    phone: ModelJson.optionalString(json, 'phone'),
    isEmailVerified:
        ModelJson.optionalBool(json, 'isEmailVerified') ?? false,
    isPhoneVerified:
        ModelJson.optionalBool(json, 'isPhoneVerified') ?? false,
  );

  ModelJsonMap toJson() => {
    'id': id,
    'displayName': displayName,
    'email': email,
    'phone': phone,
    'isEmailVerified': isEmailVerified,
    'isPhoneVerified': isPhoneVerified,
  };
}
