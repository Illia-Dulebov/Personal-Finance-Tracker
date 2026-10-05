import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final String emoji;

  const Category({
    required this.id,
    required this.name,
    required this.emoji,
  });

  @override
  List<Object?> get props => [id, name, emoji];
}
