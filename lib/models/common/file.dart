class File {
  final String assetId;
  final String publicId;
  final int version;
  final String versionId;
  final String signature;
  final int width;
  final int height;
  final String format;
  final String resourceType;
  final DateTime createdAt;
  final List<String> tags;
  final int bytes;
  final String type;
  final String etag;
  final bool placeholder;
  final String url;
  final String secureUrl;
  final String assetFolder;
  final String displayName;
  final String accessMode;
  final String originalFilename;
  final String apiKey;
  final String publicUrl;

  File({
    required this.assetId,
    required this.publicId,
    required this.version,
    required this.versionId,
    required this.signature,
    required this.width,
    required this.height,
    required this.format,
    required this.resourceType,
    required this.createdAt,
    required this.tags,
    required this.bytes,
    required this.type,
    required this.etag,
    required this.placeholder,
    required this.url,
    required this.secureUrl,
    required this.assetFolder,
    required this.displayName,
    required this.accessMode,
    required this.originalFilename,
    required this.apiKey,
    required this.publicUrl,
  });

  factory File.fromJson(Map<String, dynamic> json) {
    return File(
      assetId: json['asset_id'] ?? '',
      publicId: json['public_id'] ?? '',
      version: json['version'] ?? 0,
      versionId: json['version_id'] ?? '',
      signature: json['signature'] ?? '',
      width: json['width'] ?? 0,
      height: json['height'] ?? 0,
      format: json['format'] ?? '',
      resourceType: json['resource_type'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.fromMillisecondsSinceEpoch(0),
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      bytes: json['bytes'] ?? 0,
      type: json['type'] ?? '',
      etag: json['etag'] ?? '',
      placeholder: json['placeholder'] ?? false,
      url: json['url'] ?? '',
      secureUrl: json['secure_url'] ?? '',
      assetFolder: json['asset_folder'] ?? '',
      displayName: json['display_name'] ?? '',
      accessMode: json['access_mode'] ?? '',
      originalFilename: json['original_filename'] ?? '',
      apiKey: json['api_key'] ?? '',
      publicUrl: json['publicUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'asset_id': assetId,
      'public_id': publicId,
      'version': version,
      'version_id': versionId,
      'signature': signature,
      'width': width,
      'height': height,
      'format': format,
      'resource_type': resourceType,
      'created_at': createdAt.toIso8601String(),
      'tags': tags,
      'bytes': bytes,
      'type': type,
      'etag': etag,
      'placeholder': placeholder,
      'url': url,
      'secure_url': secureUrl,
      'asset_folder': assetFolder,
      'display_name': displayName,
      'access_mode': accessMode,
      'original_filename': originalFilename,
      'api_key': apiKey,
      'publicUrl': publicUrl,
    };
  }
}



