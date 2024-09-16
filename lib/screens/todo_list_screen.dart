import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/todo_service.dart';
import '../utils/date_formatter.dart';

class ToDoListScreen extends StatefulWidget {
  const ToDoListScreen({Key? key}) : super(key: key);

  @override
  _ToDoListScreenState createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen> {
  List<ToDo> _todoList = [];
  final ToDoService _todoService = ToDoService();

  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _loadToDoList();
  }

  void _loadToDoList() async {
    List<ToDo> list = await _todoService.loadToDoList();
    setState(() {
      _todoList = list;
    });
  }

  void _saveToDoList() {
    _todoService.saveToDoList(_todoList);
  }

  void _onSortColumn(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      switch (columnIndex) {
        case 0: // Công việc
          _todoList.sort((a, b) {
            return ascending
                ? a.title.compareTo(b.title)
                : b.title.compareTo(a.title);
          });
          break;
        case 1: // Deadline
          _todoList.sort((a, b) {
            DateTime aDeadline = a.deadline ?? DateTime(2100);
            DateTime bDeadline = b.deadline ?? DateTime(2100);
            return ascending
                ? aDeadline.compareTo(bDeadline)
                : bDeadline.compareTo(aDeadline);
          });
          break;
        case 2: // Trạng thái
          _todoList.sort((a, b) {
            return ascending
                ? a.status.compareTo(b.status)
                : b.status.compareTo(a.status);
          });
          break;
      }
    });
  }

  void _addToDo() {
    String newTitle = '';
    DateTime? selectedDeadline;
    String selectedStatus = 'Chưa hoàn thành';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Thêm Công Việc Mới'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      onChanged: (value) {
                        newTitle = value;
                      },
                      decoration:
                      InputDecoration(labelText: 'Tiêu đề công việc'),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          selectedDeadline == null
                              ? 'Chưa chọn deadline'
                              : 'Deadline: ${formatDate(selectedDeadline!)}',
                        ),
                        Spacer(),
                        TextButton(
                          onPressed: () async {
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate:
                              selectedDeadline ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                selectedDeadline = pickedDate;
                              });
                            }
                          },
                          child: Text('Chọn Deadline'),
                        ),
                      ],
                    ),
                    DropdownButton<String>(
                      value: selectedStatus,
                      items: <String>[
                        'Chưa hoàn thành',
                        'Đang làm',
                        'Hoàn thành',
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Đóng hộp thoại
                  },
                  child: Text('Hủy'),
                ),
                TextButton(
                  onPressed: () {
                    if (newTitle.isNotEmpty) {
                      setState(() {
                        _todoList.add(ToDo(
                          title: newTitle,
                          deadline: selectedDeadline,
                          status: selectedStatus,
                        ));
                      });
                      _saveToDoList();
                    }
                    Navigator.of(context).pop(); // Đóng hộp thoại
                  },
                  child: Text('Thêm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editToDoStatus(ToDo todo) {
    String updatedStatus = todo.status;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Cập Nhật Trạng Thái'),
          content: DropdownButton<String>(
            value: updatedStatus,
            items: <String>[
              'Chưa hoàn thành',
              'Đang làm',
              'Hoàn thành',
            ].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                updatedStatus = value!;
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  todo.status = updatedStatus;
                });
                _saveToDoList();
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
              child: Text('Cập Nhật'),
            ),
          ],
        );
      },
    );
  }

  void _deleteToDoItem(ToDo todo) {
    setState(() {
      _todoList.remove(todo);
    });
    _saveToDoList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản Lý Công Việc'),
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _addToDo,
            child: Text('Thêm Công Việc Mới'),
          ),
          SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                columnSpacing: 10,
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                columns: [
                  DataColumn(
                    label: Text('Công việc'),
                    onSort: (columnIndex, ascending) {
                      _onSortColumn(columnIndex, ascending);
                    },
                  ),
                  DataColumn(
                    label: Text('Deadline'),
                    onSort: (columnIndex, ascending) {
                      _onSortColumn(columnIndex, ascending);
                    },
                  ),
                  DataColumn(
                    label: Text('Trạng thái'),
                    onSort: (columnIndex, ascending) {
                      _onSortColumn(columnIndex, ascending);
                    },
                  ),
                  DataColumn(label: Text('Hành động')),
                ],
                rows: _todoList.map((todo) {
                  return DataRow(
                    color: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                        if (todo.status == 'Hoàn thành') {
                          return Colors.greenAccent.shade100;
                        } else if (todo.status == 'Đang làm') {
                          return Colors.yellowAccent.shade100;
                        } else {
                          return null;
                        }
                      },
                    ),
                    cells: [
                      DataCell(
                        SizedBox(
                          width: 100,
                          child: Text(
                            todo.title,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: todo.status == 'Chưa hoàn thành'
                                  ? Colors.red
                                  : Colors.black,
                            ),
                          ),
                        ),
                        onTap: () => _editToDoStatus(todo),
                      ),
                      DataCell(
                        SizedBox(
                          width: 80,
                          child: Text(
                            todo.deadline != null
                                ? formatDate(todo.deadline!)
                                : '---',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 80,
                          child: Text(
                            todo.status,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: todo.status == 'Chưa hoàn thành'
                                  ? Colors.red
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteToDoItem(todo),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
