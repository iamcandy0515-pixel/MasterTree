class DriveFile {
  final String id;
  final String name;
  final String mimeType;
  final String? webContentLink;
  final String? createdTime;
  final String? size;
  final String? iconLink;

  DriveFile({
    required this.id,
    required this.name,
    required this.mimeType,
    this.webContentLink,
    this.createdTime,
    this.size,
    this.iconLink,
  });

  factory DriveFile.fromJson(Map<String, dynamic> json) {
    return DriveFile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      mimeType: json['mimeType'] as String? ?? '',
      webContentLink: json['webContentLink'] as String?,
      createdTime: json['createdTime'] as String?,
      size: json['size'] as String?,
      iconLink: json['iconLink'] as String?,
    );
  }
}
