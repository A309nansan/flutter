import 'package:flutter/material.dart';

class BackgroundSelector extends StatelessWidget {
  final List<String> backgroundPaths;
  final int selectedIndex;
  final ValueChanged<int> onBackgroundSelected;

  const BackgroundSelector({
    super.key,
    required this.backgroundPaths,
    required this.selectedIndex,
    required this.onBackgroundSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(30),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: backgroundPaths.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () => onBackgroundSelected(index),
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withOpacity(0.3),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(70),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
              border: selectedIndex == index
                  ? Border.all(color: Colors.blueAccent, width: 5)
                  : null,
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  backgroundPaths[index],
                  fit: BoxFit.cover,
                ),
                if (selectedIndex == index)
                  Container(
                    color: Colors.black.withAlpha(80),
                    child: const Center(
                      child: Icon(Icons.check_rounded, size: 60, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
