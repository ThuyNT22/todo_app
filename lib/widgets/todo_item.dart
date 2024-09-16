import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../utils/date_formatter.dart';

class ToDoItem extends StatelessWidget {
  final ToDo todo;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ToDoItem({
    Key? key,
    required this.todo,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        todo.title,
        style: TextStyle(
          decoration: todo.status == 'Hoàn thành'
              ? TextDecoration.lineThrough
              : null,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (todo.deadline != null)
            Text('Deadline: ${formatDate(todo.deadline!)}'),
          Text('Trạng thái: ${todo.status}'),
        ],
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: onDelete,
      ),
      onTap: onEdit,
    );
  }
}
