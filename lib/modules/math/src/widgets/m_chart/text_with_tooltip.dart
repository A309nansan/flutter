import 'package:flutter/material.dart';

class TextWithTooltip extends StatelessWidget {
  final String text;
  final String title;
  final String subtext;

  const TextWithTooltip({
    Key? key,
    required this.text,
    required this.title,
    required this.subtext,
  }) : super(key: key);

  void _showBottomTooltip(BuildContext context) {
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withOpacity(0.05), // ✅ 훨씬 더 투명하게
      backgroundColor: Colors.white,
      isScrollControlled: true, // ✅ 더 큰 화면에서 부드럽게
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Text(subtext, style: const TextStyle(fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("닫기", style: TextStyle(color: Colors.blue)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showBottomTooltip(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            margin: EdgeInsets.fromLTRB(4, 4, 4, 4),
            child:          const Icon(Icons.info_outline, size: 22, color: Colors.blueAccent),
          )

        ],
      ),
    );
  }
}