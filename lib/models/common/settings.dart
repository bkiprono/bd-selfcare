class SettingsResponse {
  final int statusCode;
  final String message;
  final SettingsData data;
  final String appVersion;

  SettingsResponse({
    required this.statusCode,
    required this.message,
    required this.data,
    required this.appVersion,
  });

  factory SettingsResponse.fromJson(Map<String, dynamic> json) {
    return SettingsResponse(
      statusCode: (json['statusCode'] ?? 200) as int,
      message: (json['message'] ?? '') as String,
      data: SettingsData.fromJson(json['data'] as Map<String, dynamic>),
      appVersion: (json['appVersion'] ?? '') as String,
    );
  }
}

class SettingsData {
  final GeneralSettings general;
  final BrandingSettings branding;

  SettingsData({
    required this.general,
    required this.branding,
  });

  factory SettingsData.fromJson(Map<String, dynamic> json) {
    return SettingsData(
      general: GeneralSettings.fromJson(json['general'] as Map<String, dynamic>),
      branding:
          BrandingSettings.fromJson(json['branding'] as Map<String, dynamic>),
    );
  }
}

class GeneralSettings {
  final AddressSettings address;
  final String app;
  final String company;
  final String email;
  final String phone;
  final String kra;

  GeneralSettings({
    required this.address,
    required this.app,
    required this.company,
    required this.email,
    required this.phone,
    required this.kra,
  });

  factory GeneralSettings.fromJson(Map<String, dynamic> json) {
    return GeneralSettings(
      address:
          AddressSettings.fromJson(json['address'] as Map<String, dynamic>),
      app: (json['app'] ?? '') as String,
      company: (json['company'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      phone: (json['phone'] ?? '') as String,
      kra: (json['KRA'] ?? '') as String,
    );
  }
}

class AddressSettings {
  final String boxAddress;
  final String town;
  final String building;
  final String country;
  final String postalCode;

  AddressSettings({
    required this.boxAddress,
    required this.town,
    required this.building,
    required this.country,
    required this.postalCode,
  });

  factory AddressSettings.fromJson(Map<String, dynamic> json) {
    return AddressSettings(
      boxAddress: (json['boxAddress'] ?? '') as String,
      town: (json['town'] ?? '') as String,
      building: (json['building'] ?? '') as String,
      country: (json['country'] ?? '') as String,
      postalCode: (json['postalCode'] ?? '') as String,
    );
  }
}

class BrandingSettings {
  final String logo;
  final String darkLogo;
  final String favicon;

  BrandingSettings({
    required this.logo,
    required this.darkLogo,
    required this.favicon,
  });

  factory BrandingSettings.fromJson(Map<String, dynamic> json) {
    return BrandingSettings(
      logo: (json['logo'] ?? '') as String,
      darkLogo: (json['darkLogo'] ?? '') as String,
      favicon: (json['favicon'] ?? '') as String,
    );
  }
}


