import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_theme.dart';
import '../../core/app_constants.dart';
import '../music_parser/parse_failure.dart';
import '../music_parser/rakuten_url_validator.dart';
import '../result/result_screen.dart';
import 'parse_state.dart';
import 'url_input_controller.dart';
import 'widgets/loading_overlay.dart';

class UrlInputScreen extends ConsumerStatefulWidget {
  const UrlInputScreen({super.key});

  @override
  ConsumerState<UrlInputScreen> createState() => _UrlInputScreenState();
}

class _UrlInputScreenState extends ConsumerState<UrlInputScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _hasText => _controller.text.trim().isNotEmpty;

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) {
      return;
    }
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void _clear() {
    _controller.clear();
  }

  void _submit() {
    _focusNode.unfocus();
    ref.read(urlInputControllerProvider.notifier).submit(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ParseState>(urlInputControllerProvider, (previous, next) {
      if (next is ParseSuccess) {
        final collection = next.collection;
        ref.read(urlInputControllerProvider.notifier).reset();
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ResultScreen(collection: collection),
          ),
        );
      }
    });

    final state = ref.watch(urlInputControllerProvider);
    final isLoading = state is ParseLoading;
    final failure = state is ParseFailureState ? state.failure : null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _Header(),
                          const SizedBox(height: 28),
                          Text(
                            'Paste a Rakuten Music album or playlist link and '
                            'we will fetch its details.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.black54, height: 1.4),
                          ),
                          const SizedBox(height: 20),
                          _UrlField(
                            controller: _controller,
                            focusNode: _focusNode,
                            hasText: _hasText,
                            onPaste: _pasteFromClipboard,
                            onClear: _clear,
                            onSubmitted: _hasText ? (_) => _submit() : null,
                          ),
                          const SizedBox(height: 10),
                          _ValidationHint(input: _controller.text),
                          if (failure != null) ...[
                            const SizedBox(height: 20),
                            _ErrorCard(
                              failure: failure,
                              onRetry: _hasText ? _submit : null,
                            ),
                          ],
                          const SizedBox(height: 28),
                          FilledButton.icon(
                            onPressed: (_hasText && !isLoading)
                                ? _submit
                                : null,
                            icon: const Icon(Icons.travel_explore_rounded),
                            label: const Text('Fetch Collection'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (isLoading) const LoadingOverlay(),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.brandGradient,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.library_music_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    AppConstants.appTagline,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const _WaveformDecoration(),
        ],
      ),
    );
  }
}

class _WaveformDecoration extends StatelessWidget {
  const _WaveformDecoration();

  static const List<double> _heights = [
    14,
    26,
    20,
    34,
    44,
    28,
    18,
    30,
    40,
    22,
    16,
    32,
    24,
    12,
    28,
    20,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: _heights.map((height) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _UrlField extends StatelessWidget {
  const _UrlField({
    required this.controller,
    required this.focusNode,
    required this.hasText,
    required this.onPaste,
    required this.onClear,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasText;
  final VoidCallback onPaste;
  final VoidCallback onClear;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.url,
      textInputAction: TextInputAction.go,
      autocorrect: false,
      minLines: 1,
      maxLines: 2,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: 'Rakuten Music URL',
        hintText: 'Paste a Rakuten Music link',
        prefixIcon: const Icon(Icons.link_rounded),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasText)
              IconButton(
                tooltip: 'Clear',
                icon: const Icon(Icons.close_rounded),
                onPressed: onClear,
              ),
            IconButton(
              tooltip: 'Paste',
              icon: const Icon(Icons.content_paste_rounded),
              onPressed: onPaste,
            ),
          ],
        ),
      ),
    );
  }
}

class _ValidationHint extends StatelessWidget {
  const _ValidationHint({required this.input});

  final String input;

  @override
  Widget build(BuildContext context) {
    if (input.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    const validator = RakutenUrlValidator();
    final result = validator.validate(input);
    final isValid = result is ValidRakutenUrl;
    final message = switch (result) {
      ValidRakutenUrl() => 'Valid Rakuten Music link.',
      InvalidRakutenUrl(:final ParseFailure failure) => failure.message,
    };
    final color = isValid ? const Color(0xFF15803D) : const Color(0xFFB45309);

    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle_rounded : Icons.info_outline_rounded,
          size: 18,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(message, style: TextStyle(color: color, fontSize: 13)),
        ),
      ],
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.failure, required this.onRetry});

  final ParseFailure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.danger),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  failure.message,
                  style: const TextStyle(
                    color: Color(0xFF991B1B),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: onRetry,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: AppColors.danger,
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Retry'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
