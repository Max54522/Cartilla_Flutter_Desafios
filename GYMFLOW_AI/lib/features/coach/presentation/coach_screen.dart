import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../training/data/workout_store.dart';
import '../domain/coach_chat.dart';

class _Message {
  const _Message(this.text, {required this.fromUser});
  final String text;
  final bool fromUser;
}

class CoachScreen extends StatefulWidget {
  const CoachScreen({super.key});

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final List<_Message> _messages = [
    const _Message(
      '¡Hola! Soy tu coach de GYMFLOW AI. Preguntame qué entrenar, cómo vas o pedime un consejo.',
      fromUser: false,
    ),
  ];
  bool _typing = false;

  static const _suggestions = [
    '¿Qué entreno hoy?',
    '¿Cómo voy?',
    '¿Cómo subo el peso?',
    'Descanso',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send(String text) async {
    final clean = text.trim();
    if (clean.isEmpty || _typing) return;
    _controller.clear();
    setState(() {
      _messages.add(_Message(clean, fromUser: true));
      _typing = true;
    });
    _scrollToEnd();

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    final answer = CoachChat.reply(clean, WorkoutStore.instance.entries);
    setState(() {
      _messages.add(_Message(answer, fromUser: false));
      _typing = false;
    });
    _scrollToEnd();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coach IA')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_typing ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == _messages.length) {
                  return const _Bubble(text: 'Escribiendo...', fromUser: false);
                }
                final m = _messages[i];
                return _Bubble(text: m.text, fromUser: m.fromUser);
              },
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _suggestions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => ActionChip(
                label: Text(_suggestions[i]),
                backgroundColor: AppColors.surfaceLight,
                side: BorderSide.none,
                labelStyle: const TextStyle(color: AppColors.secondary),
                onPressed: () => _send(_suggestions[i]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: _send,
                    decoration: InputDecoration(
                      hintText: 'Escribile a tu coach...',
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () => _send(_controller.text),
                  icon: const Icon(Icons.send_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(52, 52),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text, required this.fromUser});

  final String text;
  final bool fromUser;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: fromUser ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(text),
      ),
    );
  }
}