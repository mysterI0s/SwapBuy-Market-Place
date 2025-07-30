class Message {
  int? id;
  String? content;
  String? timestamp;
  int? conversation;
  int? sender;
  String? senderName;

  Message({
    this.id,
    this.content,
    this.timestamp,
    this.conversation,
    this.sender,
    this.senderName,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      timestamp: json['timestamp'],
      conversation: json['conversation'],
      sender: json['sender'],
      senderName: json['sender_name'],
    );
  }
}
