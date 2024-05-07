// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Future<void> _signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } on AuthException catch (error) {
      SnackBar(
        content: Text(error.message),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    } catch (error) {
      SnackBar(
        content: const Text('Unexpected error occurred'),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    } finally {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Flex(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          direction: Axis.vertical,
          children: [
            const Text(
              " Settings",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Text(Supabase.instance.client.auth.currentUser?.email ??
                  "You must log in"),
            ),
            const SizedBox(
              height: 20,
            ),
            ShadButton(
              text: Text(Supabase.instance.client.auth.currentUser != null
                  ? "Logout"
                  : "Login"),
              onPressed: () {
                if (Supabase.instance.client.auth.currentUser != null) {
                  _signOut;
                } else {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
            )
          ],
        ),
      ],
    );
  }
}
