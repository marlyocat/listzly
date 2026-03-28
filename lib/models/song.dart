import 'package:json_annotation/json_annotation.dart';

part 'song.g.dart';

@JsonSerializable()
class Song {
  final String id;
  final String title;
  final String artist;
  @JsonKey(name: 'file_path')
  final String filePath;
  @JsonKey(name: 'duration_seconds')
  final int durationSeconds;
  @JsonKey(name: 'cover_url')
  final String? coverUrl;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'is_local', defaultValue: false)
  final bool isLocal;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.filePath,
    required this.durationSeconds,
    this.coverUrl,
    required this.createdAt,
    this.isLocal = false,
  });

  factory Song.fromJson(Map<String, dynamic> json) => _$SongFromJson(json);
  Map<String, dynamic> toJson() => _$SongToJson(this);
}
