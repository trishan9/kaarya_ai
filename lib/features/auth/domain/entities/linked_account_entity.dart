import 'package:equatable/equatable.dart';

class LinkedAccountEntity extends Equatable {
  final String provider;
  final String? email;
  final String? name;
  final String? linkedAt;

  const LinkedAccountEntity({
    required this.provider,
    this.email,
    this.name,
    this.linkedAt,
  });

  @override
  List<Object?> get props => [provider, email];
}
