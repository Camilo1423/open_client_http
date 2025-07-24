import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interactive_json_preview/interactive_json_preview.dart';
import 'package:open_client_http/presentation/provider/response/response_provider.dart';
import 'package:open_client_http/presentation/provider/request/request_provider.dart';
import 'package:open_client_http/presentation/provider/current_request/current_request_provider.dart';
import 'package:open_client_http/presentation/router/index.dart';
import 'package:open_client_http/presentation/widget/widgets.dart';

class RenderResponseScreen extends ConsumerStatefulWidget {
  const RenderResponseScreen({super.key});

  static const String name = "render_response_screen";

  @override
  ConsumerState<RenderResponseScreen> createState() =>
      _RenderResponseScreenState();
}

class _RenderResponseScreenState extends ConsumerState<RenderResponseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isPrettyMode = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _reloadRequest() {
    final currentRequest = ref.read(currentRequestProvider);
    if (currentRequest.url.trim().isNotEmpty) {
      ref.read(requestExecutionProvider.notifier).executeRequest(currentRequest);
    }
  }

  @override
  Widget build(BuildContext context) {
    final response = ref.watch(responseProvider);
    final currentRequest = ref.watch(currentRequestProvider);
    final isLoading = ref.watch(isRequestLoadingProvider);
    final requestError = ref.watch(requestErrorProvider);
    final theme = Theme.of(context);

    // Listen to request errors and show snackbar
    ref.listen<String?>(requestErrorProvider, (previous, next) {
      if (next != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request failed: $next'),
            backgroundColor: theme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    if (response == null) {
      return Scaffold(
        appBar: AppBarCustom(
          titleText: 'Response',
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No response to display',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Send a request to see the response here',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBarCustom(
        titleText: 'Response',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouterPath.home),
        ),
        actions: [
          IconButton(
            onPressed: isLoading ? null : () => _reloadRequest(),
            icon: isLoading 
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.onSurface,
                      ),
                    ),
                  )
                : const Icon(Icons.refresh_rounded),
            tooltip: isLoading ? 'Loading...' : 'Reload Request',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildResponseInfo(response, theme),
          _buildTabBar(theme),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBodyTab(response, theme),
                _buildHeadersTab(response, theme),
                _buildCookiesTab(response, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseInfo(response, ThemeData theme) {
    final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
    final isClientError =
        response.statusCode >= 400 && response.statusCode < 500;
    final isServerError = response.statusCode >= 500;

    Color chipColor;
    if (isSuccess) {
      chipColor = Colors.green;
    } else if (isClientError) {
      chipColor = Colors.orange;
    } else if (isServerError) {
      chipColor = Colors.red;
    } else {
      chipColor = theme.colorScheme.primary;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Chip(
            label: Text(
              '${response.statusCode} ${response.reasonPhrase}',
              style: TextStyle(
                color: chipColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            backgroundColor: chipColor.withValues(alpha: 0.1),
            side: BorderSide(color: chipColor.withValues(alpha: 0.3)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 14,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        response.formattedResponseTime,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.data_usage_rounded,
                        size: 14,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        response.formattedSize,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        indicatorColor: theme.colorScheme.primary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        tabs: const [
          Tab(text: 'Body'),
          Tab(text: 'Headers'),
          Tab(text: 'Cookies'),
        ],
      ),
    );
  }

  Widget _buildBodyTab(response, ThemeData theme) {
    return Column(
      children: [
        if (response.isJson) _buildPrettyRawToggle(theme),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: response.body.isEmpty
                ? _buildEmptyState('No response body', theme)
                : response.isJson && _isPrettyMode
                ? _buildPrettyJsonView(response.body, theme)
                : _buildRawView(response.body, theme),
          ),
        ),
      ],
    );
  }

  Widget _buildPrettyRawToggle(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.code_rounded,
            size: 16,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 8),
          Text(
            'JSON View:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const Spacer(),
          Switch(
            value: _isPrettyMode,
            onChanged: (value) {
              setState(() {
                _isPrettyMode = value;
              });
            },
            activeColor: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            _isPrettyMode ? 'Pretty' : 'Raw',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrettyJsonView(String jsonBody, ThemeData theme) {
    try {
      final jsonData = jsonDecode(jsonBody);
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
          color: theme.colorScheme.surface,
        ),
        padding: const EdgeInsets.all(16),
        child: InteractiveJsonPreview(data: jsonData),
      );
    } catch (e) {
      return _buildRawView(jsonBody, theme);
    }
  }

  Widget _buildRawView(String content, ThemeData theme) {
    try {
      final jsonData = jsonDecode(content);
      final prettyJson = const JsonEncoder.withIndent('  ').convert(jsonData);
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
          color: theme.colorScheme.surface,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Text(
            prettyJson,
            style: TextStyle(
              fontFamily: 'Courier New',
              fontSize: 13,
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ),
      );
    } catch (e) {
      return _buildRawViewHelp(content, theme);
    }
  }

  Widget _buildRawViewHelp(String content, ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
        color: theme.colorScheme.surface,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          content,
          style: TextStyle(
            fontFamily: 'Courier New',
            fontSize: 13,
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildHeadersTab(response, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: response.headers.isEmpty
          ? _buildEmptyState('No response headers', theme)
          : _buildKeyValueList(response.headers, theme),
    );
  }

  Widget _buildCookiesTab(response, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: response.cookies.isEmpty
          ? _buildEmptyState('No cookies', theme)
          : _buildKeyValueList(response.cookies, theme),
    );
  }

  Widget _buildKeyValueList(Map<String, String> data, ThemeData theme) {
    return ListView.separated(
      itemCount: data.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final entry = data.entries.elementAt(index);
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              width: 1,
            ),
            color: theme.colorScheme.surface,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                entry.value,
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Courier New',
                  color: theme.colorScheme.onSurface,
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
