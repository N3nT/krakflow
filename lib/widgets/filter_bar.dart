import 'package:flutter/material.dart';

class FilterBar extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const FilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(
          onPressed: () => onFilterChanged("wszystkie"),
          child: Text(
            "Wszystkie",
            style: TextStyle(
              fontWeight: selectedFilter == "wszystkie"
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),

        TextButton(
          onPressed: () => onFilterChanged("do zrobienia"),
          child: Text(
            "Do zrobienia",
            style: TextStyle(
              fontWeight: selectedFilter == "do zrobienia"
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),

        TextButton(
          onPressed: () => onFilterChanged("zrobione"),
          child: Text(
            "Zrobione",
            style: TextStyle(
              fontWeight: selectedFilter == "zrobione"
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}