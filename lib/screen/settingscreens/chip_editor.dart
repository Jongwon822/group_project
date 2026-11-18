import 'package:material_ui/material_ui.dart';
import 'add_chip_dialog.dart';

class ChipEditor extends StatelessWidget {
  final List<String> items; // 선택된(관심) 목록
  final List<String> options; // 버튼으로 보여줄 기본 목록
  final String dialogTitle;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;
  final Color color;

  const ChipEditor({
    super.key,
    required this.items,
    this.options = const [],
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

  // 기본 직군 버튼: 누르면 추가, 다시 누르면 빠짐
  Widget _optionChip(String o) {
    final selected = items.contains(o);
    return FilterChip(
      label: Text(o),
      selected: selected,
      onSelected: (on) {
        if (on) {
          onAdd(o);
        } else {
          onRemove(o);
        }
      },
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: selected ? color : Colors.black87,
        fontSize: 13,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      backgroundColor: Colors.white,
      selectedColor: Colors.white,
      side: BorderSide(color: selected ? color : const Color(0xFFE5E7EB)),
      shape: const StadiumBorder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          // 기본 직군 버튼
          for (final o in options) _optionChip(o),
          // 직접 추가한 직군 (기본 목록에 없는 것만): X로 삭제
          for (final item in items)
            if (!options.contains(item))
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
          // 목록에 없는 직군 직접 추가
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