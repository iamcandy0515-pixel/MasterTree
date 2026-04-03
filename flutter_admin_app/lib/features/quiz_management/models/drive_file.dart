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

  factory DriveFile.fromJson(dynamic json) {
    // 🔥 [FTF] Force cast incoming dynamic (JS Map) to Map<String, dynamic>
    final Map<String, dynamic> data = Map<String, dynamic>.from(json as Map);
    
    return DriveFile(
      id: data['id']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      mimeType: data['mimeType']?.toString() ?? '',
      webContentLink: data['webContentLink']?.toString(),
      createdTime: data['createdTime']?.toString(),
      size: data['size']?.toString(),
      iconLink: data['iconLink']?.toString(),
    );
  }
}
