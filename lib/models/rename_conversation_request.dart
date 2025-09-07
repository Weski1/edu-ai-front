class RenameConversationRequest {
  final String title;

  RenameConversationRequest({
    required this.title,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
    };
  }
}
