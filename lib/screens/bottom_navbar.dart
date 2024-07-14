import 'package:flutter/material.dart';

class CustomNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            tooltip: 'Weather',
            onPressed: () => onTap(0),
            icon: Icon(
              Icons.cloud,
              color: currentIndex == 0 ? Colors.deepPurple : Colors.grey,
            ),
          ),
          IconButton(
            tooltip: 'Fetch new Data',
            onPressed: () => onTap(1),
            icon: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.refresh,
                color: Colors.deepPurple,
              ),
            ),
          ),
          IconButton(
            tooltip: 'UV Forecast',
            onPressed: () => onTap(2),
            icon: Icon(
              Icons.sunny,
              color: currentIndex == 2 ? Colors.deepPurple : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
