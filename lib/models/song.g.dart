// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Song _$SongFromJson(Map<String, dynamic> json) => Song(
  id: json['id'] as String,
  title: json['title'] as String,
  artist: json['artist'] as String,
  filePath: json['file_path'] as String,
  durationSeconds: (json['duration_seconds'] as num).toInt(),
  coverUrl: json['cover_url'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$SongToJson(Song instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'artist': instance.artist,
  'file_path': instance.filePath,
  'duration_seconds': instance.durationSeconds,
  'cover_url': instance.coverUrl,
  'created_at': instance.createdAt.toIso8601String(),
};
