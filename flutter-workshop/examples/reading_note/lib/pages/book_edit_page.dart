import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/book.dart';
import '../state/book_list.dart';
import '../theme/app_theme.dart';
import '../widgets/paper_layer.dart';
import '../widgets/star_rating.dart';

class BookEditPage extends ConsumerStatefulWidget {
  final Book? existing;
  const BookEditPage({super.key, this.existing});

  @override
  ConsumerState<BookEditPage> createState() => _BookEditPageState();
}

class _BookEditPageState extends ConsumerState<BookEditPage> {
  late final TextEditingController _titleCtl;
  late final TextEditingController _authorCtl;
  late final TextEditingController _noteCtl;
  late int _rating;
  bool _canSave = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleCtl = TextEditingController(text: e?.title ?? '');
    _authorCtl = TextEditingController(text: e?.author ?? '');
    _noteCtl = TextEditingController(text: e?.note ?? '');
    _rating = e?.rating ?? 0;
    _canSave = _titleCtl.text.trim().isNotEmpty;
    _titleCtl.addListener(_onTitleChanged);
  }

  void _onTitleChanged() {
    final next = _titleCtl.text.trim().isNotEmpty;
    if (next != _canSave) setState(() => _canSave = next);
  }

  @override
  void dispose() {
    _titleCtl.removeListener(_onTitleChanged);
    _titleCtl.dispose();
    _authorCtl.dispose();
    _noteCtl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_canSave) return;
    final notifier = ref.read(bookListProvider.notifier);
    if (_isEdit) {
      notifier.update(widget.existing!.copyWith(
        title: _titleCtl.text.trim(),
        author: _authorCtl.text.trim(),
        note: _noteCtl.text.trim(),
        rating: _rating,
      ));
    } else {
      notifier.add(
        title: _titleCtl.text.trim(),
        author: _authorCtl.text.trim(),
        note: _noteCtl.text.trim(),
        rating: _rating,
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.cream,
      body: PaperLayer(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _Header(isEdit: _isEdit)),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(28, 8, 28, 120),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _FieldLabel('01', 'タイトル', required: true),
                        const SizedBox(height: 6),
                        _UnderlineField(
                          controller: _titleCtl,
                          hint: 'たとえば — ノルウェイの森',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(color: AppPalette.ink),
                          autofocus: !_isEdit,
                        ),
                        const SizedBox(height: 36),
                        _FieldLabel('02', '著者'),
                        const SizedBox(height: 6),
                        _UnderlineField(
                          controller: _authorCtl,
                          hint: '—  村上 春樹',
                          style: editorialItalic(
                            size: 18,
                            color: AppPalette.ink,
                          ).copyWith(height: 1.4),
                        ),
                        const SizedBox(height: 36),
                        _FieldLabel('03', '評価'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            StarRatingInput(
                              value: _rating,
                              onChanged: (v) => setState(() => _rating = v),
                              size: 30,
                            ),
                            const SizedBox(width: 16),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              child: Text(
                                _rating == 0 ? '未評価' : '$_rating / 5',
                                key: ValueKey(_rating),
                                style: editorialItalic(
                                  size: 14,
                                  color: AppPalette.inkMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 36),
                        _FieldLabel('04', '感想  ·  メモ'),
                        const SizedBox(height: 8),
                        _NoteField(controller: _noteCtl),
                        const SizedBox(height: 40),
                        _StampSaveButton(
                          enabled: _canSave,
                          isEdit: _isEdit,
                          onPressed: _save,
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool isEdit;
  const _Header({required this.isEdit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _GhostButton(
                icon: Icons.arrow_back_rounded,
                label: 'CLOSE',
                onTap: () => Navigator.of(context).maybePop(),
              ),
              const Spacer(),
              Text(
                isEdit ? 'EDIT  /  推敲中' : 'NEW  /  起筆',
                style: editorialLabel(size: 11, letter: 2.4),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Container(height: 1, color: AppPalette.ink),
          const SizedBox(height: 18),
          Text(
            isEdit ? 'メモを編集' : 'メモを書く',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 6),
          Text(
            isEdit
                ? '一文字ずつ、丁寧に書き直しましょう。'
                : '思い出したまま、自由に綴ってください。',
            style: editorialItalic(size: 15, color: AppPalette.inkMuted),
          ),
          const SizedBox(height: 24),
          Container(height: 0.6, color: AppPalette.hairlineSoft),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _GhostButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _GhostButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_GhostButton> createState() => _GhostButtonState();
}

class _GhostButtonState extends State<_GhostButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(
              color: _hover ? AppPalette.ink : AppPalette.hairline,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 14, color: AppPalette.ink),
              const SizedBox(width: 6),
              Text(widget.label,
                  style: editorialLabel(
                    size: 10,
                    letter: 1.8,
                    color: AppPalette.ink,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String number;
  final String label;
  final bool required;
  const _FieldLabel(this.number, this.label, {this.required = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(number,
            style: editorialItalic(size: 13, color: AppPalette.accent)),
        const SizedBox(width: 8),
        Container(width: 18, height: 0.8, color: AppPalette.hairline),
        const SizedBox(width: 10),
        Text(label,
            style: editorialLabel(
              size: 11,
              letter: 2.4,
              color: AppPalette.ink,
            )),
        if (required) ...[
          const SizedBox(width: 8),
          Text('REQUIRED',
              style: editorialLabel(
                size: 9,
                letter: 1.8,
                color: AppPalette.accent,
              )),
        ],
      ],
    );
  }
}

class _UnderlineField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final TextStyle? style;
  final bool autofocus;

  const _UnderlineField({
    required this.controller,
    required this.hint,
    this.style,
    this.autofocus = false,
  });

  @override
  State<_UnderlineField> createState() => _UnderlineFieldState();
}

class _UnderlineFieldState extends State<_UnderlineField> {
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: widget.controller,
          focusNode: _focus,
          autofocus: widget.autofocus,
          style: widget.style ?? Theme.of(context).textTheme.titleLarge,
          cursorColor: AppPalette.accent,
          cursorWidth: 1.4,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: (widget.style ?? Theme.of(context).textTheme.titleLarge)
                ?.copyWith(color: AppPalette.hairline),
            border: InputBorder.none,
            isCollapsed: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 6),
          ),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          height: focused ? 1.6 : 0.8,
          color: focused ? AppPalette.ink : AppPalette.hairline,
        ),
      ],
    );
  }
}

class _NoteField extends StatefulWidget {
  final TextEditingController controller;
  const _NoteField({required this.controller});

  @override
  State<_NoteField> createState() => _NoteFieldState();
}

class _NoteFieldState extends State<_NoteField> {
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppPalette.paper.withValues(alpha: 0.7),
        border: Border.all(
          color: focused ? AppPalette.ink : AppPalette.hairlineSoft,
          width: focused ? 1.2 : 0.8,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focus,
        minLines: 5,
        maxLines: null,
        cursorColor: AppPalette.accent,
        cursorWidth: 1.4,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.7),
        decoration: InputDecoration(
          hintText:
              '読み終えた瞬間の気持ち、好きだった一節、誰かに薦めたい理由 ——',
          hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppPalette.hairline,
                fontStyle: FontStyle.italic,
              ),
          border: InputBorder.none,
          isCollapsed: true,
        ),
      ),
    );
  }
}

class _StampSaveButton extends StatefulWidget {
  final bool enabled;
  final bool isEdit;
  final VoidCallback onPressed;

  const _StampSaveButton({
    required this.enabled,
    required this.isEdit,
    required this.onPressed,
  });

  @override
  State<_StampSaveButton> createState() => _StampSaveButtonState();
}

class _StampSaveButtonState extends State<_StampSaveButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (!enabled)
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Text(
              'タイトルを入力してください',
              style: editorialItalic(
                size: 13,
                color: AppPalette.inkMuted,
              ),
            ),
          ),
        MouseRegion(
          cursor: enabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.forbidden,
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: GestureDetector(
            onTap: enabled ? widget.onPressed : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              decoration: BoxDecoration(
                color: enabled ? AppPalette.accent : AppPalette.hairlineSoft,
                border: Border.all(
                  color: enabled ? AppPalette.accent : AppPalette.hairline,
                  width: 1.4,
                ),
                boxShadow: [
                  if (enabled)
                    BoxShadow(
                      color: AppPalette.accent.withValues(
                          alpha: _hover ? 0.35 : 0.18),
                      blurRadius: _hover ? 18 : 10,
                      offset: const Offset(2, 4),
                    ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.isEdit ? '上書きする' : '書きとめる',
                    style: editorialLabel(
                      size: 12,
                      letter: 2.4,
                      color: enabled
                          ? AppPalette.cream
                          : AppPalette.inkMuted,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.east_rounded,
                    size: 16,
                    color: enabled
                        ? AppPalette.cream
                        : AppPalette.inkMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
