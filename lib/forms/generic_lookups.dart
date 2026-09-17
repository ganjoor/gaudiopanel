import 'package:flutter/material.dart';

/// Shows a modal dialog that stays on screen until the user explicitly
/// dismisses it (as opposed to a SnackBar, which can auto-dismiss before
/// being noticed). [icon]/[iconColor] let callers give the dialog a visual
/// cue at a glance; [errorAlert] and [successAlert] below cover the two
/// most common cases.
Future<void> alert(BuildContext context, String title, String msg,
    {IconData icon = Icons.info_outline,
    Color iconColor = Colors.blueGrey}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[Text(msg)],
          ),
        ),
        actions: <Widget>[
          ElevatedButton.icon(
            icon: const Icon(Icons.check),
            label: const Text('تأیید'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

/// Persistent, explicitly-dismissed error dialog — use this instead of a
/// SnackBar for anything the user genuinely needs to see and acknowledge.
Future<void> errorAlert(BuildContext context, String msg) => alert(
      context,
      'خطا',
      msg,
      icon: Icons.error_outline,
      iconColor: Colors.red,
    );

/// Persistent confirmation dialog for a successfully completed action
/// (distinct from [errorAlert] so a success message never gets shown with
/// an error title/icon by mistake).
Future<void> successAlert(BuildContext context, String msg,
        {String title = 'انجام شد'}) =>
    alert(
      context,
      title,
      msg,
      icon: Icons.check_circle_outline,
      iconColor: Colors.green,
    );

/// A consistent "nothing here yet" placeholder for empty lists, used across
/// every data section instead of leaving a blank area with no explanation.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const EmptyState({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
