import 'package:flutter/material.dart';
import 'add_chip_dialog.dart';

class ChipEditor extends StatelessWidget {
  final List<String> items;
  final String dialogTitle;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;
  final Color color;

  const ChipEditor({
    super.key,
    required this.items,
    required this.dialogTitle,
    required this.onAdd,
    required this.onRemove,
    this.color = const Color(0xFF1F5ADD),
  });

  Future<void> _handleAdd(BuildContext context) async {
    final v = await showAddChipDialog(context, dialogTitle);
    if (v == null || v.isEmpty || items.contains(v)) return;
    onAdd(v);
  }

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final item in items)
            InputChip(
              avatar: Icon(Icons.check, size: 16, color: color),
              label: Text(item),
              labelStyle: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600),
              backgroundColor: Colors.white,
              side: BorderSide(color: color),
              shape: const StadiumBorder(),
              deleteIcon: const Icon(Icons.close, size: 14),
              deleteIconColor: color,
              onDeleted: () => onRemove(item),
            ),
          ActionChip(
            label: const Text('+ 추가'),
            labelStyle: const TextStyle(color: Colors.black54, fontSize: 13),
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFFE5E7EB)),
            shape: const StadiumBorder(),
            onPressed: () => _handleAdd(context),
          ),
        ],
      ),
    );
  }
}