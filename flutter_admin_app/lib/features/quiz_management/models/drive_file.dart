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
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      mimeType: json['mimeType'] ?? '',
      webContentLink: json['webContentLink'],
      createdTime: json['createdTime'],
      size: json['size'],
      iconLink: json['iconLink'],
    );
  }
}
