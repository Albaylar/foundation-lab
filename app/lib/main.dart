import 'package:flutter/material.dart';
import 'design/tokens.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(extensions: const [AppTokens.light]),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        extensions: const [AppTokens.dark],
      ),
      home: const TokenPreviewPage(),
    );
  }
} // ← MainApp burada biter

class TokenPreviewPage extends StatelessWidget {
  const TokenPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Scaffold(
      backgroundColor: t.colors.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(t.spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: t.spacing.md,
                runSpacing: t.spacing.md,
                children: [
                  _Swatch(name: 'primary', color: t.colors.primary),
                  _Swatch(name: 'surface', color: t.colors.surface),
                  _Swatch(name: 'onSurface', color: t.colors.onSurface),
                  _Swatch(name: 'muted', color: t.colors.muted),
                  _Swatch(name: 'success', color: t.colors.success),
                  _Swatch(name: 'danger', color: t.colors.danger),
                ],
              ),
              SizedBox(height: t.spacing.xl),
              // TODO 3: spacing çubukları buraya gelecek
            ],
          ),
        ),
      ),
    );
  }
} // ← TokenPreviewPage burada biter

class _Swatch extends StatelessWidget {
  const _Swatch({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(t.radius.sm),
            border: Border.all(color: t.colors.muted),
          ),
        ),
        SizedBox(height: t.spacing.xs),
        Text(name, style: TextStyle(color: t.colors.muted, fontSize: 12)),
      ],
    );
  }
} // ← _Swatch burada biter