import 'dart:async';

import 'package:material_ui/material_ui.dart';

void showAppMessage(
  BuildContext context, {
  required String title,
  required String message,
  required Color color,
  bool atTop = false,
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  final direction = Directionality.of(context);
  late final OverlayEntry entry;
  var showing = true;
  entry = OverlayEntry(
    builder: (_) => Directionality(
      textDirection: direction,
      child: _AppMessage(
        title: title,
        message: message,
        color: color,
        atTop: atTop,
        onDismiss: () {
          if (!showing) return;
          showing = false;
          entry.remove();
          entry.dispose();
        },
      ),
    ),
  );
  overlay.insert(entry);
}

class _AppMessage extends StatefulWidget {
  const _AppMessage({
    required this.title,
    required this.message,
    required this.color,
    required this.atTop,
    required this.onDismiss,
  });

  final String title;
  final String message;
  final Color color;
  final bool atTop;
  final VoidCallback onDismiss;

  @override
  State<_AppMessage> createState() => _AppMessageState();
}

class _AppMessageState extends State<_AppMessage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _position;
  late final Timer _timeout;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _position = Tween(
      begin: Offset(0, widget.atTop ? -1 : 1),
      end: Offset.zero,
    ).chain(CurveTween(curve: Curves.easeOutCirc)).animate(_controller);
    _controller.forward();
    _timeout = Timer(const Duration(seconds: 3), () async {
      await _controller.reverse();
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _timeout.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.atTop ? Alignment.topCenter : Alignment.bottomCenter,
      child: SlideTransition(
        position: _position,
        child: SafeArea(
          top: widget.atTop,
          bottom: !widget.atTop,
          minimum: EdgeInsets.only(
            bottom: widget.atTop ? 0 : MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Dismissible(
              key: const ValueKey('app-message'),
              direction: DismissDirection.horizontal,
              onDismissed: (_) => widget.onDismiss(),
              child: Material(
                color: widget.color,
                borderRadius: BorderRadius.circular(15),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
