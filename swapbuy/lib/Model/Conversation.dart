class Conversation {
  int? id;
  int? user1;
  String? user1Name;
  int? user2;
  String? user2Name;
  String? createdAt;

  Conversation({
    this.id,
    this.user1,
    this.user1Name,
    this.user2,
    this.user2Name,
    this.createdAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      user1: json['user1'],
      user1Name: json['user1_name'],
      user2: json['user2'],
      user2Name: json['user2_name'],
      createdAt: json['created_at'],
    );
  }
}
