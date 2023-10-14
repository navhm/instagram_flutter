// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:instagram_flutter/config/paths.dart';

import 'package:instagram_flutter/models/models.dart';

class Comment extends Equatable {
  final String? id;
  final User author;
  final String content;
  final String postId;
  final DateTime dateTime;
  const Comment({
    this.id,
    required this.author,
    required this.content,
    required this.postId,
    required this.dateTime,
  });

  @override
  List<Object?> get props => [id, author, content, postId, dateTime];

  Comment copyWith({
    String? id,
    User? author,
    String? content,
    String? postId,
    DateTime? dateTime,
  }) {
    return Comment(
      id: id ?? this.id,
      author: author ?? this.author,
      content: content ?? this.content,
      postId: postId ?? this.postId,
      dateTime: dateTime ?? this.dateTime,
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'author':
          FirebaseFirestore.instance.collection(Paths.users).doc(author.id),
      'content': content,
      'postId': postId,
      'dateTime': Timestamp.fromDate(dateTime),
    };
  }

  static Future<Comment?> fromDocument(DocumentSnapshot? doc) async {
    if (doc == null) return null;
    final data = doc.data() as Map<String, dynamic>;
    final authorRef = data['author'] as DocumentReference;
    final authorDoc = await authorRef.get();
    if (authorDoc.exists) {
      return Comment(
          id: doc.id,
          postId: data['postId'] ?? '',
          dateTime: (data['dateTime'] as Timestamp).toDate(),
          author: User.fromDocument(authorDoc),
          content: data['content'] ?? '');
    }
    return null;
  }
}
