class Post {
  final String userId;
  final String content;

  Post({required this.userId, required this.content});

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'content': content,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      userId: map['userId'],
      content: map['content'],
    );
  }
}
