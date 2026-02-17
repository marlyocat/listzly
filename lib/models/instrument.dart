import 'package:json_annotation/json_annotation.dart';

part 'instrument.g.dart';

@JsonSerializable()
class Instrument {
  final String? id;
  @JsonKey(name: 'user_id')
  final String userId;
  final String name;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  const Instrument({
    this.id,
    required this.userId,
    required this.name,
    this.createdAt,
  });

  factory Instrument.fromJson(Map<String, dynamic> json) =>
      _$InstrumentFromJson(json);
  Map<String, dynamic> toJson() => _$InstrumentToJson(this);
}
