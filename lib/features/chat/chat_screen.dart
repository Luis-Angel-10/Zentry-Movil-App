import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import 'package:Zentry/core/providers/auth_controller.dart';
import 'package:Zentry/core/providers/posts_controller.dart';
import 'package:Zentry/core/widgets/zentry_network_image.dart';
import 'package:Zentry/features/create/create_screen.dart';
import 'package:Zentry/features/create/media_editor/audio_trim_screen.dart';
import 'package:Zentry/features/stories/story_viewer_screen.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';
import 'package:Zentry/theme/theme_controller.dart';

import 'call_screen.dart';
import 'media_grid_widget.dart';
import 'real_conversations_list.dart';

class ChatScreen extends StatefulWidget {
  final String? initialContactName;

  final String? initialMessage;

  const ChatScreen({super.key, this.initialContactName, this.initialMessage});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool isChatOpen = false;

  String currentChatName = "";

  final ImagePicker _picker = ImagePicker();

  final TextEditingController _controller = TextEditingController();

  final ScrollController _scroll = ScrollController();

  final AudioRecorder _recorder = AudioRecorder();

  bool isRecording = false;

  String? audioPath;

  List<Map<String, dynamic>> messages = [];

  List<Map<String, dynamic>> callLog = [
    {
      'name': 'Carlos Ruiz',
      'incoming': true,
      'isVideo': false,
      'duration': null,
    },
    {
      'name': 'Ana Torres',
      'incoming': false,
      'isVideo': false,
      'duration': null,
    },
    {
      'name': 'María López',
      'incoming': true,
      'isVideo': true,
      'duration': null,
    },
    {
      'name': 'Alex Rivera',
      'incoming': false,
      'isVideo': false,
      'duration': null,
    },
  ];

  Future<void> _startCall(String name, bool isVideo) async {
    final duration = await Navigator.push<Duration>(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(name: name, isVideo: isVideo),
      ),
    );

    if (duration == null || !mounted) return;

    setState(() {
      callLog.insert(0, {
        'name': name,
        'incoming': false,
        'isVideo': isVideo,
        'duration': duration,
      });
    });
  }

  String _formatCallDuration(Duration d) {
    final min = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final sec = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$min:$sec";
  }

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);

    if (widget.initialContactName != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        openChat(widget.initialContactName!);
        if (widget.initialMessage != null) {
          _controller.text = widget.initialMessage!;
          sendText();
        }
      });
    }
  }

  List<StoryGroup> _groupedStories(BuildContext context) {
    final posts = context.watch<PostsController>();
    final me = context.watch<AuthController>().currentUser;
    return posts.backendGroupedStories(viewerDisplayName: me?.displayName ?? '');
  }

  void openChat(String name) {
    setState(() {
      isChatOpen = true;

      currentChatName = name;

      messages = [
        {'type': 'text', 'text': 'Hola 👋', 'isMe': false, 'time': _nowLabel()},
      ];
    });
  }

  String _nowLabel() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  void _addMessage(Map<String, dynamic> data) {
    final entry = {...data, 'time': _nowLabel(), 'sending': true};
    setState(() => messages.add(entry));
    scrollDown();

    Future.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      setState(() => entry['sending'] = false);
    });
  }

  void sendText() {
    if (_controller.text.trim().isEmpty) return;

    _addMessage({'type': 'text', 'text': _controller.text, 'isMe': true});

    _controller.clear();
  }

  Future<void> pickImage() async {
    final List<AssetEntity>? assets = await AssetPicker.pickAssets(
      context,

      pickerConfig: const AssetPickerConfig(
        maxAssets: 10,

        requestType: RequestType.image,
      ),
    );

    if (assets == null) return;

    List<File> files = [];

    for (final asset in assets) {
      final file = await asset.file;

      if (file != null) {
        files.add(file);
      }
    }

    if (!mounted || files.isEmpty) return;

    await _openMediaComposer(files, 'image');
  }

  Future<void> pickVideo() async {
    final List<AssetEntity>? assets = await AssetPicker.pickAssets(
      context,

      pickerConfig: const AssetPickerConfig(
        maxAssets: 10,

        requestType: RequestType.video,
      ),
    );

    if (assets == null) return;

    List<File> files = [];

    for (final asset in assets) {
      final file = await asset.file;

      if (file != null) {
        files.add(file);
      }
    }

    if (!mounted || files.isEmpty) return;

    await _openMediaComposer(files, 'video');
  }

  Future<void> _openMediaComposer(List<File> files, String mediaType) async {
    final l10n = AppLocalizations.of(context)!;
    final captionController = TextEditingController();
    final workingFiles = List<File>.from(files);

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF171725),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            mediaType == 'video'
                                ? l10n.chatComposerVideoTitle(
                                    workingFiles.length,
                                  )
                                : l10n.chatComposerImageTitle(
                                    workingFiles.length,
                                  ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white70,
                            ),
                            onPressed: () => Navigator.pop(sheetContext, false),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 92,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: workingFiles.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, i) {
                            final f = workingFiles[i];
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: mediaType == 'video'
                                      ? Container(
                                          width: 80,
                                          height: 80,
                                          color: Colors.black45,
                                          alignment: Alignment.center,
                                          child: const Icon(
                                            Icons.videocam,
                                            color: Colors.white70,
                                          ),
                                        )
                                      : Image.file(
                                          f,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                if (workingFiles.length > 1)
                                  Positioned(
                                    top: -6,
                                    right: -6,
                                    child: GestureDetector(
                                      onTap: () => setSheetState(
                                        () => workingFiles.removeAt(i),
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: const BoxDecoration(
                                          color: Colors.black87,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: captionController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: l10n.chatComposerCaptionHint,
                            hintStyle: const TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: workingFiles.isEmpty
                              ? null
                              : () => Navigator.pop(sheetContext, true),
                          icon: const Icon(Icons.send),
                          label: Text(l10n.chatComposerSendButton),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (confirmed == true && workingFiles.isNotEmpty) {
      final caption = captionController.text.trim();
      _addMessage({
        'type': 'media_group',
        'mediaType': mediaType,
        'files': workingFiles,
        'caption': caption.isEmpty ? null : caption,
        'isMe': true,
      });
    }
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result == null) return;

    for (var f in result.files) {
      _addMessage({
        'type': 'file',
        'file': File(f.path!),
        'name': f.name,
        'size': f.size,
        'isMe': true,
      });
    }
  }

  Future<void> toggleRecording() async {
    final status = await Permission.microphone.request();

    if (!status.isGranted) return;

    if (!isRecording) {
      final dir = await getTemporaryDirectory();

      audioPath =
          '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(const RecordConfig(), path: audioPath!);

      setState(() {
        isRecording = true;
      });
    } else {
      await _recorder.stop();

      setState(() {
        isRecording = false;
      });

      final path = audioPath;
      Map<String, double>? trim;
      if (path != null && mounted) {
        trim = await Navigator.push<Map<String, double>>(
          context,
          MaterialPageRoute(
            builder: (_) => AudioTrimScreen(audioFile: File(path)),
          ),
        );
      }

      if (!mounted) return;

      _addMessage({
        'type': 'audio',
        'file': audioPath,
        'isMe': true,
        if (trim != null) 'trimStart': trim['start'],
        if (trim != null) 'trimEnd': trim['end'],
      });
    }
  }

  void deleteMessage(int index) {
    setState(() {
      messages.removeAt(index);
    });
  }

  void editMessage(int index) {
    final l10n = AppLocalizations.of(context)!;

    final oldText = messages[index]['text'];

    final editController = TextEditingController(text: oldText);

    showDialog(
      context: context,

      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2D),

          title: Text(
            l10n.chatEditMessageDialogTitle,

            style: const TextStyle(color: Colors.white),
          ),

          content: TextField(
            controller: editController,

            style: const TextStyle(color: Colors.white),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: Text(l10n.commonCancel),
            ),

            TextButton(
              onPressed: () {
                setState(() {
                  messages[index]['text'] = editController.text;
                });

                Navigator.pop(context);
              },

              child: Text(l10n.commonSave),
            ),
          ],
        );
      },
    );
  }

  void forwardMessage(Map msg) {
    final l10n = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.chatMessageForwardedSnackbar)));
  }

  void scrollDown() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 200,

          duration: const Duration(milliseconds: 300),

          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final accentColor = context.watch<ThemeController>().accentColor;

    if (isChatOpen) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;

          setState(() {
            isChatOpen = false;
          });
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,

            leading: IconButton(
              icon: const Icon(Icons.arrow_back),

              onPressed: () {
                setState(() {
                  isChatOpen = false;
                });
              },
            ),

            title: Row(
              children: [
                CircleAvatar(
                  radius: 22,

                  backgroundColor: accentColor,

                  child: const Icon(Icons.person),
                ),

                const SizedBox(width: 12),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      currentChatName,

                      style: const TextStyle(
                        color: Colors.white,

                        fontWeight: FontWeight.bold,

                        fontSize: 18,
                      ),
                    ),

                    Text(
                      l10n.chatOnlineStatusLabel,

                      style: const TextStyle(
                        color: Colors.greenAccent,

                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            actions: [
              IconButton(
                icon: const Icon(Icons.call),
                onPressed: () => _startCall(currentChatName, false),
              ),
              IconButton(
                icon: const Icon(Icons.videocam),
                onPressed: () => _startCall(currentChatName, true),
              ),
            ],
          ),

          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scroll,

                  padding: const EdgeInsets.all(14),

                  itemCount: messages.length,

                  itemBuilder: (_, i) {
                    return buildMessage(messages[i], i);
                  },
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),

                decoration: const BoxDecoration(color: Color(0xFF151526)),

                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.image, color: Colors.white70),

                      onPressed: pickImage,
                    ),

                    IconButton(
                      icon: const Icon(Icons.videocam, color: Colors.white70),

                      onPressed: pickVideo,
                    ),

                    IconButton(
                      icon: const Icon(
                        Icons.attach_file,
                        color: Colors.white70,
                      ),

                      onPressed: pickFile,
                    ),

                    IconButton(
                      icon: Icon(
                        isRecording ? Icons.stop_circle : Icons.mic,

                        color: isRecording ? Colors.red : accentColor,
                      ),

                      onPressed: toggleRecording,
                    ),

                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),

                        decoration: BoxDecoration(
                          color: Colors.white10,

                          borderRadius: BorderRadius.circular(30),
                        ),

                        child: TextField(
                          controller: _controller,

                          style: const TextStyle(color: Colors.white),

                          decoration: InputDecoration(
                            hintText: l10n.chatMessageInputHint,

                            hintStyle: const TextStyle(color: Colors.white54),

                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    CircleAvatar(
                      radius: 26,

                      backgroundColor: accentColor,

                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),

                        onPressed: sendText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,

        title: const Text("Zentry", style: TextStyle(color: Colors.white)),

        bottom: TabBar(
          controller: _tabController,

          indicatorColor: accentColor,

          tabs: [
            Tab(text: l10n.chatTabChats),

            Tab(text: l10n.chatTabStatuses),

            Tab(text: l10n.chatTabCalls),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,

        children: [
          const RealConversationsList(),

          ListView(
            padding: const EdgeInsets.only(top: 10),

            children: [
              ListTile(
                leading: Stack(
                  children: [
                    CircleAvatar(
                      radius: 28,

                      backgroundColor: accentColor,

                      child: const Icon(Icons.person, color: Colors.white),
                    ),

                    Positioned(
                      bottom: 0,
                      right: 0,

                      child: Container(
                        width: 20,
                        height: 20,

                        decoration: const BoxDecoration(
                          color: Colors.greenAccent,

                          shape: BoxShape.circle,
                        ),

                        child: const Icon(
                          Icons.add,

                          size: 16,

                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),

                title: Text(
                  l10n.chatMyStatusTitle,

                  style: const TextStyle(
                    color: Colors.white,

                    fontWeight: FontWeight.bold,
                  ),
                ),

                subtitle: Text(
                  l10n.chatMyStatusSubtitle,

                  style: const TextStyle(color: Colors.white54),
                ),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateScreen(initialPostType: 1),
                    ),
                  );
                },
              ),

              () {
                final groups = _groupedStories(context);
                final myName =
                    context.watch<AuthController>().currentUser?.displayName ??
                    '';
                final recent = groups
                    .where((g) => !g.allSeenBy(myName))
                    .toList();
                final viewed = groups
                    .where((g) => g.allSeenBy(myName))
                    .toList();

                if (groups.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    child: Text(
                      l10n.chatNoStatusesLabel,
                      style: const TextStyle(color: Colors.white38),
                    ),
                  );
                }

                return Column(
                  children: [
                    if (recent.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 18,
                          top: 10,
                          bottom: 10,
                        ),
                        child: Text(
                          l10n.chatRecentSectionTitle,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      for (final group in recent)
                        buildEstadoGroupTile(
                          group,
                          seen: false,
                          myName: myName,
                        ),
                    ],
                    if (viewed.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 18,
                          top: 10,
                          bottom: 10,
                        ),
                        child: Text(
                          l10n.chatViewedSectionTitle,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      for (final group in viewed)
                        buildEstadoGroupTile(group, seen: true, myName: myName),
                    ],
                  ],
                );
              }(),
            ],
          ),

          ListView.builder(
            padding: const EdgeInsets.only(top: 10),

            itemCount: callLog.length,

            itemBuilder: (_, i) => buildCallTile(callLog[i], accentColor),
          ),
        ],
      ),
    );
  }

  Widget buildEstadoGroupTile(
    StoryGroup group, {
    required bool seen,
    required String myName,
  }) {
    final latest = group.latest;
    final File? storyImageFile = latest["imageFile"] as File?;
    final String? storyMediaUrl = latest["mediaIsVideo"] == true
        ? null
        : latest["mediaUrl"] as String?;
    final String? storyAvatarUrl = latest["avatarUrl"] as String?;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: seen
              ? null
              : const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFD946EF)],
                ),
          border: seen ? Border.all(color: Colors.white24, width: 2.5) : null,
        ),
        child: ZentryAvatar(
          radius: 26,
          backgroundColor: const Color(0xFF1E1E2D),
          localFilePath: storyImageFile?.path,
          networkUrl: storyMediaUrl ?? storyAvatarUrl,
        ),
      ),

      title: Text(
        group.user,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),

      subtitle: Text(
        latest["time"] as String? ?? '',
        style: const TextStyle(color: Colors.white54),
      ),

      trailing: group.items.length > 1
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${group.items.length}',
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            )
          : null,

      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StoryViewerScreen(
              stories: group.items,
              initialIndex: group.firstUnseenIndexFor(myName),
            ),
          ),
        );
      },
    );
  }

  Widget buildCallTile(Map<String, dynamic> call, Color accentColor) {
    final l10n = AppLocalizations.of(context)!;

    final String name = call['name'] as String;
    final bool incoming = call['incoming'] as bool;
    final bool isVideo = call['isVideo'] as bool? ?? false;
    final Duration? duration = call['duration'] as Duration?;

    return ListTile(
      leading: CircleAvatar(
        radius: 26,

        backgroundColor: accentColor,

        child: const Icon(Icons.person, color: Colors.white),
      ),

      title: Text(
        name,

        style: const TextStyle(
          color: Colors.white,

          fontWeight: FontWeight.w600,
        ),
      ),

      subtitle: Row(
        children: [
          Icon(
            incoming ? Icons.call_received : Icons.call_made,

            color: incoming ? Colors.greenAccent : Colors.redAccent,

            size: 18,
          ),

          const SizedBox(width: 4),

          Icon(
            isVideo ? Icons.videocam : Icons.call,
            color: Colors.white38,
            size: 14,
          ),

          const SizedBox(width: 6),

          Text(
            duration != null
                ? _formatCallDuration(duration)
                : (incoming
                      ? l10n.chatIncomingCallLabel
                      : l10n.chatMissedCallLabel),

            style: const TextStyle(color: Colors.white54),
          ),
        ],
      ),

      trailing: Container(
        width: 42,
        height: 42,

        decoration: BoxDecoration(
          color: Colors.white10,

          borderRadius: BorderRadius.circular(14),
        ),

        child: IconButton(
          onPressed: () => _startCall(name, isVideo),

          icon: Icon(
            isVideo ? Icons.videocam : Icons.call,

            color: accentColor,

            size: 20,
          ),
        ),
      ),
    );
  }

  Widget buildMessage(Map msg, int index) {
    final l10n = AppLocalizations.of(context)!;

    final accentColor = context.watch<ThemeController>().accentColor;

    Widget content;

    switch (msg['type']) {
      case 'media_group':
        content = MediaGridWidget(
          files: List<File>.from(msg['files']),

          isVideo: msg['mediaType'] == 'video',
        );

        break;

      case 'file':
        final file = msg['file'];

        content = GestureDetector(
          onTap: () async {
            await OpenFilex.open(file.path);
          },

          child: Container(
            width: 240,

            padding: const EdgeInsets.all(14),

            decoration: BoxDecoration(
              color: Colors.white10,

              borderRadius: BorderRadius.circular(18),
            ),

            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,

                  decoration: BoxDecoration(
                    color: Colors.red,

                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: const Icon(
                    Icons.picture_as_pdf,

                    color: Colors.white,

                    size: 28,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        msg['name'],

                        maxLines: 2,

                        overflow: TextOverflow.ellipsis,

                        style: const TextStyle(
                          color: Colors.white,

                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        "${(msg['size'] / 1024).toStringAsFixed(1)} KB",

                        style: const TextStyle(
                          color: Colors.white54,

                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

        break;

      case 'audio':
        content = AudioBubble(
          filePath: msg['file'],
          trimStart: msg['trimStart'] as double?,
          trimEnd: msg['trimEnd'] as double?,
        );

        break;

      default:
        content = Text(
          msg['text'],

          style: const TextStyle(color: Colors.white, fontSize: 15),
        );
    }

    return GestureDetector(
      onLongPress: () {
        showModalBottomSheet(
          context: context,

          backgroundColor: const Color(0xFF1E1E2D),

          builder: (_) {
            return SafeArea(
              child: Wrap(
                children: [
                  if (msg['type'] == 'text')
                    ListTile(
                      leading: const Icon(Icons.edit, color: Colors.white),

                      title: Text(
                        l10n.commonEdit,

                        style: const TextStyle(color: Colors.white),
                      ),

                      onTap: () {
                        Navigator.pop(context);

                        editMessage(index);
                      },
                    ),

                  ListTile(
                    leading: const Icon(Icons.forward, color: Colors.white),

                    title: Text(
                      l10n.chatForwardActionLabel,

                      style: const TextStyle(color: Colors.white),
                    ),

                    onTap: () {
                      Navigator.pop(context);

                      forwardMessage(msg);
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),

                    title: Text(
                      l10n.commonDelete,

                      style: const TextStyle(color: Colors.red),
                    ),

                    onTap: () {
                      Navigator.pop(context);

                      deleteMessage(index);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },

      child: Align(
        alignment: msg['isMe'] ? Alignment.centerRight : Alignment.centerLeft,

        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: msg['isMe'] == true
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accentColor.withOpacity(0.55),
                        const Color(0xFF2B2B3D),
                      ],
                    )
                  : null,
              color: msg['isMe'] == true ? null : const Color(0xFF1E1E2D),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(msg['isMe'] == true ? 20 : 4),
                bottomRight: Radius.circular(msg['isMe'] == true ? 4 : 20),
              ),
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    content,
                    if (msg['type'] == 'media_group' &&
                        (msg['caption'] as String?) != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        msg['caption'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                        ),
                      ),
                    ],
                    if ((msg['time'] as String?) != null) ...[
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          msg['time'] as String,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 10.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (msg['sending'] == true)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AudioBubble extends StatefulWidget {
  final String filePath;

  final double? trimStart;
  final double? trimEnd;

  const AudioBubble({
    super.key,

    required this.filePath,
    this.trimStart,
    this.trimEnd,
  });

  @override
  State<AudioBubble> createState() => _AudioBubbleState();
}

class _AudioBubbleState extends State<AudioBubble> {
  final AudioPlayer player = AudioPlayer();

  bool isPlaying = false;

  Duration duration = Duration.zero;

  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();

    initAudio();
  }

  Future<void> initAudio() async {
    await player.setFilePath(widget.filePath);

    final fullDuration = player.duration ?? Duration.zero;

    duration = widget.trimEnd != null && widget.trimStart != null
        ? Duration(
            milliseconds: ((widget.trimEnd! - widget.trimStart!) * 1000)
                .round(),
          )
        : fullDuration;

    if (widget.trimStart != null) {
      await player.seek(
        Duration(milliseconds: (widget.trimStart! * 1000).round()),
      );
    }

    player.positionStream.listen((p) {
      final trimEnd = widget.trimEnd;
      if (trimEnd != null &&
          p >= Duration(milliseconds: (trimEnd * 1000).round())) {
        player.pause();
        player.seek(
          Duration(milliseconds: ((widget.trimStart ?? 0) * 1000).round()),
        );
        return;
      }

      setState(() {
        position = p;
      });
    });

    player.playerStateStream.listen((state) {
      setState(() {
        isPlaying = state.playing;
      });
    });
  }

  String format(Duration d) {
    final min = d.inMinutes.remainder(60).toString().padLeft(2, '0');

    final sec = d.inSeconds.remainder(60).toString().padLeft(2, '0');

    return "$min:$sec";
  }

  Duration get _trimStartDuration =>
      Duration(milliseconds: ((widget.trimStart ?? 0) * 1000).round());

  Duration get _relativePosition {
    final rel = position - _trimStartDuration;
    return rel.isNegative ? Duration.zero : rel;
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = context.watch<ThemeController>().accentColor;

    return Container(
      width: 250,

      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accentColor.withOpacity(0.9), const Color(0xFF7C3AED)],
        ),

        borderRadius: BorderRadius.circular(22),
      ),

      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              if (isPlaying) {
                await player.pause();
              } else {
                await player.play();
              }
            },

            child: Container(
              width: 46,
              height: 46,

              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),

                shape: BoxShape.circle,
              ),

              child: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,

                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2,

                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 5,
                    ),

                    overlayShape: SliderComponentShape.noOverlay,
                  ),

                  child: Slider(
                    activeColor: Colors.white,

                    inactiveColor: Colors.white24,

                    min: 0,

                    max: duration.inMilliseconds.toDouble(),

                    value: _relativePosition.inMilliseconds.toDouble().clamp(
                      0,
                      duration.inMilliseconds.toDouble(),
                    ),

                    onChanged: (value) async {
                      await player.seek(
                        Duration(milliseconds: value.toInt()) +
                            _trimStartDuration,
                      );
                    },
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text(
                      format(_relativePosition),

                      style: const TextStyle(
                        color: Colors.white70,

                        fontSize: 11,
                      ),
                    ),

                    Text(
                      format(duration),

                      style: const TextStyle(
                        color: Colors.white70,

                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    player.dispose();

    super.dispose();
  }
}
