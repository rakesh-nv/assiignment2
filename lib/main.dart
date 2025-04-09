import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[200],
        body: Center(
          child: Dock<IconData>(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (icon, isDragging, scale) {
              return Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: isDragging ? 0.0 : 1.0,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 48),
                    height: 48,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.primaries[icon.hashCode % Colors.primaries.length],
                    ),
                    child: Center(child: Icon(icon, color: Colors.white)),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  final List<T> items;
  final Widget Function(T item, bool isDragging, double scale) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T> extends State<Dock<T>> {
  late List<T> _items = widget.items.toList();
  Offset mousePosition = Offset.infinite;
  int? draggingIndex;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: MouseRegion(
          onHover: (event) {
            setState(() => mousePosition = event.position);
          },
          onExit: (_) {
            setState(() => mousePosition = Offset.infinite);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.black12,
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_items.length, (index) {
                final icon = _items[index];
                final iconWidth = 64;
                final dockWidth = iconWidth * _items.length;
                final dockStart = (MediaQuery.of(context).size.width - dockWidth) / 2;
                final iconCenterX = dockStart + iconWidth * index + iconWidth / 2;
                final distance = (mousePosition.dx - iconCenterX).abs();
                final scale = max(1.0, 1.6 - (distance / 150).clamp(0, 1));

                return Draggable<int>(
                  data: index,
                  onDragStarted: () => setState(() => draggingIndex = index),
                  onDragEnd: (_) => setState(() => draggingIndex = null),
                  feedback: Material(
                    color: Colors.transparent,
                    child: widget.builder(icon, false, 1.2),
                  ),
                  childWhenDragging: widget.builder(icon, true, 1.0),
                  child: DragTarget<int>(
                    onAccept: (fromIndex) {
                      setState(() {
                        final item = _items.removeAt(fromIndex);
                        _items.insert(index, item);
                      });
                    },
                    builder: (_, __, ___) {
                      return widget.builder(icon, false, scale);
                    },
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
