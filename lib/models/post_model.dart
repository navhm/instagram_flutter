import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:instagram_flutter/config/paths.dart';
import 'package:instagram_flutter/models/user_model.dart';

class Post extends Equatable {
  final String? id;
  final User author;
  final String imageUrl;
  final String caption;
  final int likes;
  final DateTime dateTime;
  const Post({
    this.id,
    required this.author,
    required this.imageUrl,
    required this.caption,
    required this.likes,
    required this.dateTime,
  });

  @override
  List<Object?> get props => [id, author, imageUrl, caption, likes, dateTime];

  Post copyWith({
    String? id,
    User? author,
    String? imageUrl,
    String? caption,
    int? likes,
    DateTime? dateTime,
  }) {
    return Post(
      id: id ?? this.id,
      author: author ?? this.author,
      imageUrl: imageUrl ?? this.imageUrl,
      caption: caption ?? this.caption,
      likes: likes ?? this.likes,
      dateTime: dateTime ?? this.dateTime,
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'author':
          FirebaseFirestore.instance.collection(Paths.users).doc(author.id),
      'imageUrl': imageUrl,
      'caption': caption,
      'likes': likes,
      'dateTime': Timestamp.fromDate(dateTime)
    };
  }

  static Future<Post?> fromDocument(DocumentSnapshot? doc) async {
    if (doc == null) {
      return null;
    }
    final data = doc.data() as Map<String, dynamic>;
    final authorRef = data['author'] as DocumentReference;

    //TODO: check null condition on authorDoc
    final authorDoc = await authorRef.get();
    if (authorDoc.exists) {
      return Post(
          id: doc.id,
          author: User.fromDocument(authorDoc),
          imageUrl: data['imageUrl'] ?? '',
          caption: data['caption'] ?? '',
          likes: (data['likes'] ?? 0).toInt(),
          dateTime: (data['dateTime'] as Timestamp).toDate());
    }
      return null;
  }
}
