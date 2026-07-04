import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../network/result.dart';
import 'app_skeleton.dart';
import 'app_state_views.dart';

/// Renders one of four states (loading/error/empty/data) from Riverpod's [AsyncValue]
/// in a single consistent shape — a screen only supplies `data`, never hand-writing
/// if/else per state. This is the join point between the UI and the API/mock repository layer.
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    this.isEmpty,
    this.emptyBuilder,
    this.loadingBuilder,
    this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(BuildContext context, T data) data;
  final bool Function(T data)? isEmpty;
  final WidgetBuilder? emptyBuilder;
  final WidgetBuilder? loadingBuilder;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => loadingBuilder?.call(context) ?? const SkeletonList(),
      error: (error, stackTrace) {
        final failure = error is AppFailure ? error : AppFailure.server();
        return ErrorStateView(
          message: failure.message,
          onRetry: failure.retryable ? onRetry : null,
        );
      },
      data: (value) {
        if (isEmpty != null && isEmpty!(value)) {
          return emptyBuilder?.call(context) ??
              const EmptyStateView(title: 'Chưa có dữ liệu');
        }
        return data(context, value);
      },
    );
  }
}
