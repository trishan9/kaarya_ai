import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/app/theme/theme_utils.dart';
import 'package:kaarya/core/services/storage/user_session_service.dart';
import 'package:kaarya/core/utils/snackbar_utils.dart';
import 'package:kaarya/features/inbox/presentation/state/inbox_state.dart';
import 'package:kaarya/features/inbox/presentation/view_model/inbox_view_model.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class InboxPage extends ConsumerStatefulWidget {
  const InboxPage({super.key});

  @override
  ConsumerState<InboxPage> createState() => _InboxPageState();
}

enum _InboxFolder { all, unread, archived }

class _InboxPageState extends ConsumerState<InboxPage> {
  final TextEditingController _searchController = TextEditingController();
  StreamChatClient? _client;
  StreamChannelListController? _channelListController;
  Channel? _selectedChannel;
  _InboxFolder _folder = _InboxFolder.all;
  bool _isConnecting = false;
  bool _isInitializing = false;
  bool _isShowingCompactConversation = false;
  String _searchQuery = '';
  String? _connectionError;

  StreamChatThemeData _buildChatTheme(BuildContext context) {
    final materialTheme = Theme.of(context);
    final isDark = materialTheme.brightness == Brightness.dark;
    final base = StreamChatThemeData.fromTheme(materialTheme);
    final textTheme = base.textTheme;
    final colorTheme = base.colorTheme.copyWith(
      brightness: materialTheme.brightness,
      accentPrimary: AppColors.primary,
      appBg: materialTheme.scaffoldBackgroundColor,
      barsBg: appSurfaceColor(context),
      inputBg: appMutedSurfaceColor(context),
      borders: appBorderColor(context),
      textHighEmphasis: appTextPrimaryColor(context),
      textLowEmphasis: appTextSecondaryColor(context),
      linkBg: appSoftSurfaceColor(context),
      overlay: appOverlayColor(context),
      overlayDark: Colors.black.withAlpha(isDark ? 170 : 110),
    );

    return base.copyWith(
      colorTheme: colorTheme,
      ownMessageTheme: base.ownMessageTheme.copyWith(
        messageBackgroundColor: AppColors.primary,
        messageBorderColor: AppColors.primary.withAlpha(120),
        messageTextStyle: textTheme.body.copyWith(color: Colors.white),
        createdAtStyle: textTheme.footnote.copyWith(
          color: Colors.white.withAlpha(180),
        ),
        messageAuthorStyle: textTheme.footnote.copyWith(
          color: Colors.white.withAlpha(180),
        ),
        reactionsBackgroundColor: appSurfaceColor(context),
        reactionsBorderColor: appBorderColor(context),
      ),
      otherMessageTheme: base.otherMessageTheme.copyWith(
        messageBackgroundColor: appMutedSurfaceColor(context),
        messageBorderColor: appBorderColor(context),
        messageTextStyle: textTheme.body.copyWith(
          color: appTextPrimaryColor(context),
        ),
        createdAtStyle: textTheme.footnote.copyWith(
          color: appTextSecondaryColor(context),
        ),
        messageAuthorStyle: textTheme.footnote.copyWith(
          color: appTextSecondaryColor(context),
        ),
      ),
      messageListViewTheme: base.messageListViewTheme.copyWith(
        backgroundColor: appSurfaceColor(context),
      ),
      messageInputTheme: base.messageInputTheme.copyWith(
        inputBackgroundColor: appMutedSurfaceColor(context),
        inputTextStyle: textTheme.body.copyWith(
          color: appTextPrimaryColor(context),
        ),
        actionButtonColor: AppColors.primary,
        expandButtonColor: appTextSecondaryColor(context),
        actionButtonIdleColor: appTextSecondaryColor(context),
        sendButtonColor: AppColors.primary,
        sendButtonIdleColor: appBorderColor(context),
        borderRadius: BorderRadius.circular(18),
        idleBorderGradient: LinearGradient(
          colors: [appBorderColor(context), appBorderColor(context)],
        ),
        activeBorderGradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primary],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchChanged);
    Future.microtask(_initializeInbox);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_handleSearchChanged)
      ..dispose();
    unawaited(_disposeClient());
    super.dispose();
  }

  void _handleSearchChanged() {
    final value = _searchController.text.trim();
    if (value == _searchQuery) return;
    setState(() => _searchQuery = value);
  }

  Future<void> _initializeInbox({bool forceRefresh = false}) async {
    if (_isInitializing) return;
    _isInitializing = true;

    setState(() {
      _isConnecting = true;
      _connectionError = null;
    });

    try {
      await ref
          .read(inboxViewModelProvider.notifier)
          .initialize(forceRefresh: forceRefresh);
      final inboxState = ref.read(inboxViewModelProvider);

      if (!mounted) return;

      if (inboxState.status == InboxLoadStatus.error ||
          inboxState.bootstrap == null) {
        setState(() {
          _isConnecting = false;
          _connectionError =
              inboxState.errorMessage ?? 'Unable to open inbox right now.';
        });
        return;
      }

      await _connectClient(inboxState.bootstrap!);
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> _connectClient(InboxBootstrapPayload payload) async {
    final session = ref.read(userSessionServiceProvider);
    final userId = session.getCurrentUserId();
    final token = payload.token;
    final apiKey = payload.apiKey;

    if (userId == null || token == null || apiKey == null) {
      if (!mounted) return;
      setState(() {
        _isConnecting = false;
        _connectionError = 'Your account session is incomplete for chat.';
      });
      return;
    }

    await _disposeClient();

    final userName = session.getCurrentUserFullName() ?? 'User';
    final userPhoto = session.getCurrentUserProfilePicture();
    final nextClient = StreamChatClient(apiKey, logLevel: Level.OFF);

    try {
      await nextClient.connectUser(
        User(id: userId, name: userName, image: _normalizedString(userPhoto)),
        token,
      );

      final controller = StreamChannelListController(
        client: nextClient,
        filter: Filter.and([
          Filter.equal('type', 'messaging'),
          Filter.in_('members', [userId]),
        ]),
        channelStateSort: const [
          SortOption<ChannelState>.desc('last_message_at'),
          SortOption<ChannelState>.desc('updated_at'),
          SortOption<ChannelState>.desc('created_at'),
        ],
        limit: 30,
      );

      await controller.doInitialLoad();

      if (!mounted) {
        controller.dispose();
        await nextClient.disconnectUser();
        return;
      }

      setState(() {
        _client = nextClient;
        _channelListController = controller;
        _selectedChannel = controller.value.isSuccess
            ? _firstOrNull(controller.value.asSuccess.items)
            : null;
        _isShowingCompactConversation = false;
        _isConnecting = false;
      });

      if (_selectedChannel != null) {
        unawaited(_activateChannel(_selectedChannel!));
      }
    } catch (error) {
      await nextClient.disconnectUser().catchError((_) {});
      if (!mounted) return;
      setState(() {
        _isConnecting = false;
        _connectionError = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _disposeClient() async {
    final controller = _channelListController;
    final client = _client;
    _channelListController = null;
    _client = null;
    _selectedChannel = null;
    controller?.dispose();
    if (client != null) {
      await client.disconnectUser().catchError((_) {});
    }
  }

  Future<void> _activateChannel(Channel channel) async {
    try {
      if (channel.state == null) {
        await channel.watch();
      }
      await channel.markRead();
    } catch (_) {}
  }

  Future<void> _refreshInbox() async {
    if (_client == null || _channelListController == null) {
      await _initializeInbox(forceRefresh: true);
      return;
    }

    try {
      await ref
          .read(inboxViewModelProvider.notifier)
          .initialize(forceRefresh: true);
      await _channelListController!.refresh();
      if (!mounted) return;
      setState(() {
        _connectionError = null;
      });
    } catch (error) {
      if (!mounted) return;
      SnackbarUtils.showError(
        context,
        error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  List<Channel> _filteredChannels(
    List<Channel> channels,
    String currentUserId,
  ) {
    final normalizedQuery = _searchQuery.toLowerCase();

    return channels.where((channel) {
      if (_folder == _InboxFolder.unread && _unreadCount(channel) == 0) {
        return false;
      }
      if (_folder == _InboxFolder.archived && !_isArchivedChannel(channel)) {
        return false;
      }
      if (_folder != _InboxFolder.archived && _isArchivedChannel(channel)) {
        return false;
      }

      if (normalizedQuery.isEmpty) {
        return true;
      }

      return _channelSearchString(
        channel,
        currentUserId,
      ).contains(normalizedQuery);
    }).toList();
  }

  void _syncSelectedChannel(
    List<Channel> channels, {
    required bool autoSelect,
  }) {
    final currentCid = _selectedChannel?.cid;
    final stillVisible = channels.any((channel) => channel.cid == currentCid);
    final nextChannel = stillVisible
        ? _selectedChannel
        : (autoSelect ? _firstOrNull(channels) : null);

    if (nextChannel?.cid == currentCid) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _selectedChannel = nextChannel;
        if (nextChannel == null) {
          _isShowingCompactConversation = false;
        }
      });
      if (nextChannel != null) {
        unawaited(_activateChannel(nextChannel));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref
        .watch(userSessionServiceProvider)
        .getCurrentUserId();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
        actions: [
          IconButton(
            tooltip: 'Refresh inbox',
            onPressed: _isConnecting ? null : _refreshInbox,
            icon: const Icon(LucideIcons.refreshCw),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
          child: currentUserId == null
              ? _InboxStatusView(
                  icon: LucideIcons.lock,
                  title: 'Sign in required',
                  message: 'Your inbox is only available after authentication.',
                  actionLabel: 'Retry',
                  onAction: _initializeInbox,
                )
              : _buildBody(context, currentUserId),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, String currentUserId) {
    if (_isConnecting && _client == null) {
      return const _InboxLoadingView();
    }

    if (_connectionError != null) {
      return _InboxStatusView(
        icon: LucideIcons.messageCircleWarning,
        title: 'Could not open inbox',
        message: _connectionError!,
        actionLabel: 'Try again',
        onAction: () => _initializeInbox(forceRefresh: true),
      );
    }

    final client = _client;
    final listController = _channelListController;

    if (client == null || listController == null) {
      return _InboxStatusView(
        icon: LucideIcons.mailWarning,
        title: 'Inbox unavailable',
        message: 'Chat is not ready yet. Try refreshing the page.',
        actionLabel: 'Reload',
        onAction: () => _initializeInbox(forceRefresh: true),
      );
    }

    return StreamChat(
      client: client,
      child: StreamChatTheme(
        data: _buildChatTheme(context),
        child: AnimatedBuilder(
          animation: listController,
          builder: (context, _) {
            return listController.value.when(
              (items, _, __) {
                final channels = _filteredChannels(items, currentUserId);

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 980;
                    _syncSelectedChannel(channels, autoSelect: !isCompact);
                    final listPane = _buildConversationList(
                      context,
                      channels,
                      isCompact: isCompact,
                    );
                    final detailPane = _buildConversationPanel(
                      context,
                      currentUserId,
                      isCompact: isCompact,
                    );

                    if (isCompact) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child:
                            _isShowingCompactConversation &&
                                _selectedChannel != null
                            ? detailPane
                            : listPane,
                      );
                    }

                    return Row(
                      children: [
                        SizedBox(width: 320, child: listPane),
                        const SizedBox(width: 12),
                        Expanded(child: detailPane),
                      ],
                    );
                  },
                );
              },
              loading: () => const _InboxLoadingView(),
              error: (error) => _InboxStatusView(
                icon: LucideIcons.messageCircleX,
                title: 'Unable to load conversations',
                message: error.message,
                actionLabel: 'Reload',
                onAction: _refreshInbox,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildConversationList(
    BuildContext context,
    List<Channel> channels, {
    required bool isCompact,
  }) {
    return _InboxPanel(
      compact: isCompact,
      child: Column(
        children: [
          _buildListControls(context, channels.length, isCompact: isCompact),
          const SizedBox(height: 12),
          Expanded(
            child: channels.isEmpty
                ? const _EmptyConversationList()
                : ListView.separated(
                    itemCount: channels.length,
                    padding: EdgeInsets.zero,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final channel = channels[index];
                      final otherMember = _otherMember(
                        channel,
                        ref.read(userSessionServiceProvider).getCurrentUserId(),
                      );
                      return _ConversationListTile(
                        channel: channel,
                        otherMember: otherMember,
                        selected: channel.cid == _selectedChannel?.cid,
                        compact: isCompact,
                        onTap: () {
                          setState(() {
                            _selectedChannel = channel;
                            if (isCompact) {
                              _isShowingCompactConversation = true;
                            }
                          });
                          unawaited(_activateChannel(channel));
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildListControls(
    BuildContext context,
    int channelCount, {
    required bool isCompact,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Conversations',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Recent chats and direct updates',
                    style: TextStyle(
                      color: appTextSecondaryColor(context),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: appMutedSurfaceColor(context),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: appBorderColor(context)),
              ),
              child: Text(
                '$channelCount',
                style: TextStyle(
                  color: appTextSecondaryColor(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(LucideIcons.search, size: 18),
                  hintText: 'Find message...',
                  filled: true,
                  fillColor: appMutedSurfaceColor(context),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: appBorderColor(context)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: appBorderColor(context)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(width: 8),
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  _searchController.clear();
                  FocusScope.of(context).unfocus();
                },
                child: Ink(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: appMutedSurfaceColor(context),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: appBorderColor(context)),
                  ),
                  child: Icon(
                    LucideIcons.x,
                    size: 18,
                    color: appTextSecondaryColor(context),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _FolderToggleButton(
              label: 'All',
              selected: _folder == _InboxFolder.all,
              onTap: () => setState(() => _folder = _InboxFolder.all),
              compact: isCompact,
            ),
            _FolderToggleButton(
              label: 'Unread',
              selected: _folder == _InboxFolder.unread,
              onTap: () => setState(() => _folder = _InboxFolder.unread),
              compact: isCompact,
            ),
            _FolderToggleButton(
              label: 'Archived',
              selected: _folder == _InboxFolder.archived,
              onTap: () => setState(() => _folder = _InboxFolder.archived),
              compact: isCompact,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConversationPanel(
    BuildContext context,
    String currentUserId, {
    required bool isCompact,
  }) {
    final channel = _selectedChannel;
    if (channel == null) {
      return _InboxPanel(
        compact: isCompact,
        child: _InboxStatusView(
          icon: LucideIcons.messagesSquare,
          title: 'Select a conversation',
          message:
              'Pick a chat from the list to read messages, send files, and keep the conversation moving.',
        ),
      );
    }

    final otherMember = _otherMember(channel, currentUserId);
    final subtitle = (channel.memberCount ?? 0) > 2
        ? '${channel.memberCount} members'
        : 'Direct message';

    return _InboxPanel(
      key: ValueKey('conversation-${channel.cid}-$isCompact'),
      compact: isCompact,
      child: StreamChannel(
        key: ValueKey(channel.cid),
        channel: channel,
        child: Column(
          children: [
            _ConversationHeader(
              showBackButton: isCompact,
              channelName: _displayName(channel, currentUserId),
              subtitle: subtitle,
              imageUrl: _normalizedString(channel.image ?? otherMember?.image),
              initials: _initialsForName(_displayName(channel, currentUserId)),
              onBack: () => setState(() {
                _isShowingCompactConversation = false;
              }),
              onAudioCall: () => SnackbarUtils.showWarning(
                context,
                'Audio calling is not wired in this Flutter inbox yet.',
              ),
              onVideoCall: () => SnackbarUtils.showWarning(
                context,
                'Video calling is not wired in this Flutter inbox yet.',
              ),
              onMore: () => SnackbarUtils.showSuccess(
                context,
                'Conversation options will be added here.',
              ),
            ),
            Divider(height: 1, color: appSubtleBorderColor(context)),
            const Expanded(child: StreamMessageListView()),
            Divider(height: 1, color: appSubtleBorderColor(context)),
            StreamMessageInput(
              enableVoiceRecording: false,
              hintGetter: (context, _) => 'Write your thoughts here...',
              textInputMargin: const EdgeInsets.all(0),
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _InboxPanel extends StatelessWidget {
  const _InboxPanel({super.key, required this.child, this.compact = false});

  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: appSurfaceColor(context),
        borderRadius: BorderRadius.circular(compact ? 20 : 24),
        border: Border.all(color: appBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDarkMode(context) ? 22 : 10),
            blurRadius: compact ? 16 : 22,
            offset: Offset(0, compact ? 6 : 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(compact ? 20 : 24),
        child: Padding(
          padding: EdgeInsets.all(compact ? 12 : 14),
          child: child,
        ),
      ),
    );
  }
}

class _FolderToggleButton extends StatelessWidget {
  const _FolderToggleButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Ink(
        height: 38,
        width: compact ? null : 96,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : appMutedSurfaceColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.transparent : appBorderColor(context),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : appTextSecondaryColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _ConversationListTile extends StatelessWidget {
  const _ConversationListTile({
    required this.channel,
    required this.otherMember,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  final Channel channel;
  final _MemberPreview? otherMember;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final previewText = _previewText(channel);
    final timestamp = _latestActivity(channel);
    final unreadCount = _unreadCount(channel);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withAlpha(isDarkMode(context) ? 48 : 28)
              : appMutedSurfaceColor(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? AppColors.primary.withAlpha(90)
                : appBorderColor(context),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(compact ? 12 : 14),
          child: Row(
            children: [
              _ConversationAvatar(
                imageUrl: _normalizedString(
                  channel.image ?? otherMember?.image,
                ),
                initials: _initialsForName(
                  channel.name ?? otherMember?.name ?? 'Conversation',
                ),
                online: otherMember?.online ?? false,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            channel.name ?? otherMember?.name ?? 'Conversation',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _formatListTimestamp(timestamp),
                          style: TextStyle(
                            color: appTextSecondaryColor(context),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            previewText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: appTextSecondaryColor(context),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (unreadCount > 0) ...[
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (_isArchivedChannel(channel)) ...[
                      const SizedBox(height: 6),
                      const _InfoChip(
                        label: 'Archived',
                        color: AppColors.warning,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConversationAvatar extends StatelessWidget {
  const _ConversationAvatar({
    required this.imageUrl,
    required this.initials,
    required this.online,
  });

  final String? imageUrl;
  final String initials;
  final bool online;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: appMutedSurfaceColor(context),
          backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
          child: imageUrl == null
              ? Text(
                  initials,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                )
              : null,
        ),
        if (online)
          Positioned(
            right: -1,
            top: -1,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: appSurfaceColor(context), width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(28),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ConversationHeader extends StatelessWidget {
  const _ConversationHeader({
    required this.showBackButton,
    required this.channelName,
    required this.subtitle,
    required this.imageUrl,
    required this.initials,
    required this.onBack,
    required this.onAudioCall,
    required this.onVideoCall,
    required this.onMore,
  });

  final bool showBackButton;
  final String channelName;
  final String subtitle;
  final String? imageUrl;
  final String initials;
  final VoidCallback onBack;
  final VoidCallback onAudioCall;
  final VoidCallback onVideoCall;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          if (showBackButton) ...[
            _HeaderIconButton(icon: LucideIcons.chevronLeft, onTap: onBack),
            const SizedBox(width: 8),
          ],
          _ConversationAvatar(
            imageUrl: imageUrl,
            initials: initials,
            online: false,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  channelName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: appTextSecondaryColor(context),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          _HeaderIconButton(icon: LucideIcons.video, onTap: onVideoCall),
          const SizedBox(width: 6),
          _HeaderIconButton(icon: LucideIcons.phone, onTap: onAudioCall),
          const SizedBox(width: 6),
          _HeaderIconButton(icon: LucideIcons.ellipsis, onTap: onMore),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Ink(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: appMutedSurfaceColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: appBorderColor(context)),
        ),
        child: Icon(icon, size: 18, color: appTextSecondaryColor(context)),
      ),
    );
  }
}

class _InboxStatusView extends StatelessWidget {
  const _InboxStatusView({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final FutureOr<void> Function()? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(22),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: AppColors.primary, size: 30),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: appTextSecondaryColor(context),
                height: 1.5,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () => onAction!.call(),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InboxLoadingView extends StatelessWidget {
  const _InboxLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          SizedBox(height: 14),
          Text(
            'Connecting to inbox...',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _EmptyConversationList extends StatelessWidget {
  const _EmptyConversationList();

  @override
  Widget build(BuildContext context) {
    return _InboxStatusView(
      icon: LucideIcons.inbox,
      title: 'No conversations yet',
      message:
          'Direct messages will appear here once Stream creates channels for your account.',
    );
  }
}

class _MemberPreview {
  const _MemberPreview({this.id, this.name, this.image, this.online = false});

  final String? id;
  final String? name;
  final String? image;
  final bool online;
}

_MemberPreview? _otherMember(Channel channel, String? currentUserId) {
  final members = channel.state?.members ?? const <Member>[];
  User? otherUser;
  for (final member in members) {
    if (member.user?.id != currentUserId) {
      otherUser = member.user;
      break;
    }
  }

  if (otherUser == null) return null;

  return _MemberPreview(
    id: otherUser.id,
    name: otherUser.name,
    image: otherUser.image,
    online: otherUser.online,
  );
}

bool _isArchivedChannel(Channel channel) {
  final extraData = channel.extraData;
  final archived = extraData['archived'];
  if (archived is bool) return archived;
  final status = extraData['status'];
  return status is String && status.toLowerCase() == 'archived';
}

String _channelSearchString(Channel channel, String currentUserId) {
  final memberNames = <String>[];
  for (final member in channel.state?.members ?? const <Member>[]) {
    final user = member.user;
    if (user?.id == currentUserId) continue;
    final name = user?.name.toLowerCase();
    if (name != null && name.isNotEmpty) {
      memberNames.add(name);
    }
  }

  return [
    channel.name?.toLowerCase() ?? '',
    _previewText(channel).toLowerCase(),
    ...memberNames,
  ].join(' ');
}

String _previewText(Channel channel) {
  final messages = channel.state?.messages ?? const <Message>[];
  final latestMessage = _latestVisibleMessage(messages);
  if (latestMessage != null) {
    final text = latestMessage.text?.trim() ?? '';
    if (text.isNotEmpty) {
      return text;
    }
    final attachmentCount = latestMessage.attachments.length;
    if (attachmentCount == 1) {
      return 'Sent an attachment';
    }
    if (attachmentCount > 1) {
      return 'Sent $attachmentCount attachments';
    }
  }
  return 'Nothing yet...';
}

DateTime? _latestActivity(Channel channel) {
  final latestMessage = _latestVisibleMessage(
    channel.state?.messages ?? const [],
  );
  return latestMessage?.createdAt ??
      channel.lastMessageAt ??
      channel.updatedAt ??
      channel.createdAt;
}

String _displayName(Channel channel, String currentUserId) {
  return channel.name ??
      _otherMember(channel, currentUserId)?.name ??
      'Conversation';
}

int _unreadCount(Channel channel) {
  return channel.state?.unreadCount ?? 0;
}

String _formatListTimestamp(DateTime? value) {
  if (value == null) return '';
  final now = DateTime.now();
  final local = value.toLocal();
  final sameDay =
      now.year == local.year &&
      now.month == local.month &&
      now.day == local.day;
  if (sameDay) {
    return DateFormat.jm().format(local);
  }
  return DateFormat('MM/dd/yyyy').format(local);
}

String _initialsForName(String value) {
  final parts = value
      .split(' ')
      .where((part) => part.trim().isNotEmpty)
      .take(2)
      .toList();
  if (parts.isEmpty) return 'IN';
  return parts.map((part) => part[0].toUpperCase()).join();
}

String? _normalizedString(String? value) {
  if (value == null) return null;
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

T? _firstOrNull<T>(List<T> items) {
  if (items.isEmpty) return null;
  return items.first;
}

Message? _latestVisibleMessage(List<Message> messages) {
  for (var index = messages.length - 1; index >= 0; index--) {
    final message = messages[index];
    if (!message.isDeleted) {
      return message;
    }
  }
  return null;
}
