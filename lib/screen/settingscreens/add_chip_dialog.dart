import 'package:flutter/material.dart';
//추가 버튼을 누를시 설정 변경 화면으로 이동
Future<String?> showAddChipDialog(BuildContext context, String title) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: TextField(controller: controller, autofocus: true),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text.trim()),
          child: const Text('추가'),
        ),
      ],
    ),
  );
}