class ToDo {
  String title;
  DateTime? deadline;
  String status; // "Chưa hoàn thành", "Đang làm", "Hoàn thành"

  ToDo({
    required this.title,
    this.deadline,
    this.status = 'Chưa hoàn thành',
  });

  // Chuyển từ JSON
  factory ToDo.fromJson(Map<String, dynamic> json) {
    return ToDo(
      title: json['title'],
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'])
          : null,
      status: json['status'] ?? 'Chưa hoàn thành',
    );
  }

  // Chuyển thành JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'deadline': deadline?.toIso8601String(),
      'status': status,
    };
  }
}
