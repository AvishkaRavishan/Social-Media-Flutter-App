class Message {
  final String text;
  final String senderId;

  Message({required this.text, required this.senderId});

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'senderId': senderId,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      text: map['text'],
      senderId: map['senderId'],
    );
  }
}
