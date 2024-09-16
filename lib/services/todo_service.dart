import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/todo.dart';

class ToDoService {
  Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/todo_list.json';
  }

  Future<List<ToDo>> loadToDoList() async {
    try {
      final filePath = await _getFilePath();
      final file = File(filePath);
      if (await file.exists()) {
        final content = await file.readAsString();
        List<dynamic> jsonList = jsonDecode(content);
        return jsonList.map((json) => ToDo.fromJson(json)).toList();
      }
    } catch (e) {
      print('Lỗi khi tải danh sách công việc: $e');
    }
    return [];
  }

  Future<void> saveToDoList(List<ToDo> todoList) async {
    final filePath = await _getFilePath();
    final file = File(filePath);
    List<Map<String, dynamic>> jsonList =
    todoList.map((todo) => todo.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }
}
