import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:Zentry/core/network/api_exception.dart';
import 'package:Zentry/core/providers/auth_controller.dart';
import 'package:Zentry/core/providers/engagement_controller.dart';
import 'package:Zentry/core/providers/posts_controller.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';

import 'drawing_canvas_page.dart';
import 'media_editor/image_editor_screen.dart';
import 'media_editor/video_trim_screen.dart';

class CreateScreen extends StatefulWidget {
  final int initialPostType;

  final String? communityId;
  final String? communityName;

  final String? challengeId;

  const CreateScreen({
    super.key,
    this.initialPostType = 0,
    this.communityId,
    this.communityName,
    this.challengeId,
  });

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen>
    with TickerProviderStateMixin {
  late TabController _mainTabController;

  late int selectedPostType = widget.initialPostType;

  bool isPublishing = false;

  String storyVisibility = 'public';

  List<String> _buildTiposPost(AppLocalizations l10n) {
    return [
      l10n.createPostTypePost,
      l10n.createPostTypeStory,
      l10n.createPostTypeReel,
      l10n.createPostTypeDrawing,
      l10n.createPostTypeArticle,
    ];
  }

  final List<String> hashtags = [
    "#Arte",
    "#Música",
    "#GameDev",
    "#Programación",
    "#Diseño",
    "#PixelArt",
    "#Blender",
    "#Unity",
    "#Animación",
    "#Modelado3D",
    "#UIUX",
    "#Ilustración",
  ];

  final List<String> selectedTags = [];

  List<String> _buildRoles(AppLocalizations l10n) {
    return [
      l10n.createRoleArtist,
      l10n.createRoleMusician,
      l10n.createRoleProgrammer,
      l10n.createRoleWriter,
      l10n.createRoleEditor,
      l10n.createRoleScreenwriter,
    ];
  }

  final List<String> selectedRoles = [];

  final TextEditingController descripcionController = TextEditingController();

  final TextEditingController articleTitleController = TextEditingController();
  final TextEditingController articleController = TextEditingController();
  final FocusNode articleFocusNode = FocusNode();

  final TextEditingController proyectoTituloController =
      TextEditingController();

  final TextEditingController proyectoDescripcionController =
      TextEditingController();

  final TextEditingController colaboracionTituloController =
      TextEditingController();

  final TextEditingController colaboracionDescripcionController =
      TextEditingController();

  File? selectedImage;

  File? selectedVideo;

  double? videoTrimStart;
  double? videoTrimEnd;

  PlatformFile? selectedFile;

  final List<PlatformFile> archivosProyecto = [];

  VideoPlayerController? _videoController;

  bool publica = true;

  double progresoProyecto = 0.65;

  @override
  void initState() {
    super.initState();

    _mainTabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _mainTabController.dispose();

    _videoController?.dispose();

    descripcionController.dispose();
    articleTitleController.dispose();
    articleController.dispose();
    articleFocusNode.dispose();

    proyectoTituloController.dispose();

    proyectoDescripcionController.dispose();

    colaboracionTituloController.dispose();

    colaboracionDescripcionController.dispose();

    super.dispose();
  }

  /// Deriva un título no vacío (el backend exige `title`).
  String _deriveTitle(String source, {String fallback = 'Publicación'}) {
    final firstLine = source.trim().split('\n').first.trim();
    if (firstLine.isEmpty) return fallback;
    return firstLine.length <= 80
        ? firstLine
        : '${firstLine.substring(0, 80)}…';
  }

  /// Publica en el backend real (`POST /api/core/posts`) para la pestaña
  /// "Nueva publicación" en los subtipos Post / Dibujo / Artículo.
  /// Devuelve `true` si se manejó aquí; `false` si debe seguir el flujo local
  /// (historias, reels, proyectos, colaboraciones — aún sin endpoint equivalente).
  Future<bool> _tryPublishBackendPost(
    PostsController postsController,
    AppLocalizations l10n,
  ) async {
    final tools = selectedTags.isEmpty ? null : selectedTags.join(',');

    String title;
    String? content;
    String contentType;
    String? imagePath;

    if (selectedPostType == 4) {
      // Artículo
      contentType = 'article';
      content = articleController.text.trim();
      title = articleTitleController.text.trim().isNotEmpty
          ? articleTitleController.text.trim()
          : _deriveTitle(content, fallback: l10n.createPostTypeArticle);
    } else if (selectedPostType == 0 || selectedPostType == 3) {
      // Publicación normal o dibujo (canvas)
      contentType = selectedPostType == 3 ? 'canvas' : 'post';
      content = descripcionController.text.trim();
      title = _deriveTitle(content);
      imagePath = selectedImage?.path;
    } else {
      return false; // historia / reel → flujo local
    }

    try {
      await postsController.createBackendPost(
        title: title,
        content: content.isEmpty ? null : content,
        contentType: contentType,
        visibility: 'public',
        tools: tools,
        imagePath: imagePath,
      );
      await postsController.refreshFeed();
      return true;
    } on ApiException catch (e) {
      if (!mounted) return true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          content: Text(
            e.fieldErrors.isNotEmpty ? e.fieldErrors.values.first : e.message,
            style: GoogleFonts.poppins(color: Colors.white),
          ),
        ),
      );
      return true; // manejado (con error): no caer al flujo local
    }
  }

  Future<void> publicarContenido() async {
    final l10n = AppLocalizations.of(context)!;
    final tiposPost = _buildTiposPost(l10n);
    final activeTab = _mainTabController.index;

    final bool hasContent;
    switch (activeTab) {
      case 1:
        hasContent =
            proyectoTituloController.text.trim().isNotEmpty ||
            proyectoDescripcionController.text.trim().isNotEmpty;
        break;
      case 2:
        hasContent =
            colaboracionTituloController.text.trim().isNotEmpty ||
            colaboracionDescripcionController.text.trim().isNotEmpty;
        break;
      default:
        hasContent = selectedPostType == 4
            ? articleController.text.trim().isNotEmpty
            : descripcionController.text.trim().isNotEmpty ||
                  selectedImage != null ||
                  selectedVideo != null ||
                  selectedFile != null;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      isPublishing = true;
    });

    // Pestaña 0 + subtipos con endpoint real: publica contra el backend.
    if (activeTab == 0 &&
        hasContent &&
        selectedPostType != 1 &&
        selectedPostType != 2) {
      final handled = await _tryPublishBackendPost(
        context.read<PostsController>(),
        l10n,
      );
      if (handled) {
        if (!mounted) return;
        setState(() => isPublishing = false);
        final coinsBefore = context.read<EngagementController>().zCoins;
        await context.read<EngagementController>().registerPost();
        final coins = context.read<EngagementController>().zCoins - coinsBefore;
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1A1A2E),
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.greenAccent),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    coins > 0
                        ? l10n.createPublishSuccessWithCoins(coins)
                        : l10n.createPublishSuccessMessage,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        limpiarContenido();
        return;
      }
    }

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      isPublishing = false;
    });

    var coinsEarned = 0;

    if (hasContent) {
      final postsController = context.read<PostsController>();
      final engagementController = context.read<EngagementController>();
      final userName =
          context.read<AuthController>().currentUser?.displayName ?? 'Tú';

      switch (activeTab) {
        case 1:
          postsController.addPost(
            title: proyectoTituloController.text.trim(),
            content: proyectoDescripcionController.text.trim(),
            category: l10n.createTabProject,
            user: userName,
            progress: progresoProyecto,
            roles: List<String>.from(selectedRoles),
            tags: List<String>.from(selectedTags),
            communityId: widget.communityId,
            communityName: widget.communityName,
            challengeId: widget.challengeId,
          );
          break;
        case 2:
          postsController.addPost(
            title: colaboracionTituloController.text.trim(),
            content: colaboracionDescripcionController.text.trim(),
            category: l10n.createTabCollaboration,
            user: userName,
            tags: List<String>.from(selectedTags),
            isPublicCollab: publica,
            communityId: widget.communityId,
            communityName: widget.communityName,
            challengeId: widget.challengeId,
          );
          break;
        default:
          if (selectedPostType == 1) {
            postsController.addStory(
              content: descripcionController.text.trim(),
              user: userName,
              userId: context.read<AuthController>().currentUser?.id ?? 0,
              visibility: storyVisibility,
              imageFile: selectedImage,
              videoFile: selectedVideo,
              videoTrimStart: videoTrimStart,
              videoTrimEnd: videoTrimEnd,
            );
          } else if (selectedPostType == 4) {
            postsController.addPost(
              title: articleTitleController.text.trim(),
              content: articleController.text.trim(),
              category: tiposPost[selectedPostType],
              user: userName,
              communityId: widget.communityId,
              communityName: widget.communityName,
              challengeId: widget.challengeId,
            );
          } else {
            postsController.addPost(
              content: descripcionController.text.trim(),
              category: tiposPost[selectedPostType],
              user: userName,
              imageFile: selectedImage,
              videoFile: selectedVideo,
              fileName: selectedFile?.name,
              communityId: widget.communityId,
              communityName: widget.communityName,
              challengeId: widget.challengeId,
              fileSizeBytes: selectedFile?.size,
              videoTrimStart: videoTrimStart,
              videoTrimEnd: videoTrimEnd,
            );
          }
      }

      final coinsBefore = engagementController.zCoins;
      await engagementController.registerPost();
      coinsEarned = engagementController.zCoins - coinsBefore;
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1A1A2E),

        elevation: 0,

        behavior: SnackBarBehavior.floating,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),

        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.greenAccent),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                coinsEarned > 0
                    ? l10n.createPublishSuccessWithCoins(coinsEarned)
                    : l10n.createPublishSuccessMessage,

                style: GoogleFonts.poppins(
                  color: Colors.white,

                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    limpiarContenido();
  }

  void limpiarContenido() {
    descripcionController.clear();

    articleTitleController.clear();

    articleController.clear();

    proyectoTituloController.clear();

    proyectoDescripcionController.clear();

    colaboracionTituloController.clear();

    colaboracionDescripcionController.clear();

    selectedImage = null;

    selectedVideo = null;

    videoTrimStart = null;

    videoTrimEnd = null;

    selectedFile = null;

    _videoController?.dispose();

    _videoController = null;

    selectedTags.clear();

    selectedRoles.clear();

    archivosProyecto.clear();

    progresoProyecto = 0.5;

    publica = true;

    FocusScope.of(context).unfocus();

    setState(() {});
  }

  Future<void> pickImage({ImageSource source = ImageSource.gallery}) async {
    final picker = ImagePicker();

    final image = await picker.pickImage(source: source, imageQuality: 85);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);

        selectedVideo = null;
      });
    }
  }

  Future<void> pickVideo({ImageSource source = ImageSource.gallery}) async {
    final picker = ImagePicker();

    final video = await picker.pickVideo(source: source);

    if (video != null) {
      selectedVideo = File(video.path);
      videoTrimStart = null;
      videoTrimEnd = null;

      _videoController?.dispose();

      _videoController = VideoPlayerController.file(selectedVideo!)
        ..initialize().then((_) {
          setState(() {});
        });

      setState(() {
        selectedImage = null;
      });
    }
  }

  Future<void> editSelectedImage() async {
    if (selectedImage == null) return;

    final result = await Navigator.push<File>(
      context,
      MaterialPageRoute(
        builder: (_) => ImageEditorScreen(imageFile: selectedImage!),
      ),
    );

    if (result != null) {
      setState(() => selectedImage = result);
    }
  }

  Future<void> trimSelectedVideo() async {
    if (selectedVideo == null) return;

    final result = await Navigator.push<Map<String, double>>(
      context,
      MaterialPageRoute(
        builder: (_) => VideoTrimScreen(videoFile: selectedVideo!),
      ),
    );

    if (result != null) {
      setState(() {
        videoTrimStart = result['start'];
        videoTrimEnd = result['end'];
      });
    }
  }

  Future<void> openCameraSheet() async {
    final l10n = AppLocalizations.of(context)!;

    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white),
                title: Text(
                  l10n.createActionTakePhoto,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(sheetContext, 'photo'),
              ),
              ListTile(
                leading: const Icon(Icons.videocam, color: Colors.white),
                title: Text(
                  l10n.createActionRecordVideo,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(sheetContext, 'video'),
              ),
            ],
          ),
        );
      },
    );

    if (choice == 'photo') {
      await pickImage(source: ImageSource.camera);
    } else if (choice == 'video') {
      await pickVideo(source: ImageSource.camera);
    }
  }

  Future<void> openDrawingCanvas() async {
    final result = await Navigator.push<File>(
      context,
      MaterialPageRoute(builder: (_) => const DrawingCanvasPage()),
    );

    if (result != null) {
      setState(() {
        selectedImage = result;
        selectedVideo = null;
      });
    }
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        selectedFile = result.files.first;
      });
    }
  }

  Future<void> pickProjectFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      setState(() {
        archivosProyecto.addAll(result.files);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tiposPost = _buildTiposPost(l10n);
    final roles = _buildRoles(l10n);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),

          onPressed: () {
            FocusScope.of(context).unfocus();

            limpiarContenido();

            ScaffoldMessenger.of(context).clearSnackBars();
          },
        ),

        title: Text(
          l10n.createScreenTitle,

          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 30,
          ),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),

            child: ElevatedButton(
              onPressed: isPublishing ? null : publicarContenido,

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),

                padding: const EdgeInsets.symmetric(horizontal: 18),
              ),

              child: isPublishing
                  ? const SizedBox(
                      width: 18,
                      height: 18,

                      child: CircularProgressIndicator(
                        color: Colors.white,

                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      l10n.createPublishButton,

                      style: GoogleFonts.poppins(
                        color: Colors.white,

                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],

        bottom: TabBar(
          controller: _mainTabController,

          indicatorColor: const Color(0xFF8B5CF6),

          labelColor: Colors.white,

          unselectedLabelColor: Colors.white38,

          labelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),

          tabs: [
            Tab(text: l10n.createTabNewPost),

            Tab(text: l10n.createTabProject),

            Tab(text: l10n.createTabCollaboration),
          ],
        ),
      ),

      body: TabBarView(
        controller: _mainTabController,

        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                SizedBox(
                  height: 42,

                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,

                    itemCount: tiposPost.length,

                    itemBuilder: (_, index) {
                      final isSelected = selectedPostType == index;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedPostType = index;

                            selectedFile = null;
                          });
                        },

                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),

                          margin: const EdgeInsets.only(right: 10),

                          padding: const EdgeInsets.symmetric(horizontal: 18),

                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),

                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF8B5CF6),

                                      Color(0xFFEC4899),
                                    ],
                                  )
                                : null,

                            color: isSelected ? null : const Color(0xFF1A1A2E),
                          ),

                          child: Center(
                            child: Text(
                              tiposPost[index],

                              style: GoogleFonts.poppins(
                                color: Colors.white,

                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    if (selectedPostType == 0) ...[
                      Expanded(
                        child: buildActionButton(
                          icon: Icons.image,

                          title: l10n.createActionImage,

                          onTap: pickImage,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: buildActionButton(
                          icon: Icons.videocam,

                          title: l10n.createActionVideo,

                          onTap: pickVideo,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: buildActionButton(
                          icon: Icons.attach_file,

                          title: l10n.createActionFile,

                          onTap: pickFile,
                        ),
                      ),
                    ],

                    if (selectedPostType == 1) ...[
                      Expanded(
                        child: buildActionButton(
                          icon: Icons.image,

                          title: l10n.createActionImage,

                          onTap: pickImage,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: buildActionButton(
                          icon: Icons.videocam,

                          title: l10n.createActionVideo,

                          onTap: pickVideo,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: buildActionButton(
                          icon: Icons.camera_alt,

                          title: l10n.createActionCamera,

                          onTap: openCameraSheet,
                        ),
                      ),
                    ],

                    if (selectedPostType == 2)
                      Expanded(
                        child: buildActionButton(
                          icon: Icons.video_collection,

                          title: l10n.createActionSelectReel,

                          onTap: pickVideo,
                        ),
                      ),

                    if (selectedPostType == 3)
                      Expanded(
                        child: buildActionButton(
                          icon: Icons.brush,

                          title: l10n.createActionOpenCanvas,

                          onTap: openDrawingCanvas,
                        ),
                      ),
                  ],
                ),

                if (selectedPostType == 1) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      ChoiceChip(
                        label: Text(l10n.storyVisibilityPublic),
                        selected: storyVisibility == 'public',
                        onSelected: (_) =>
                            setState(() => storyVisibility = 'public'),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text(l10n.storyVisibilityFollowers),
                        selected: storyVisibility == 'followers',
                        onSelected: (_) =>
                            setState(() => storyVisibility = 'followers'),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 18),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),

                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),

                    borderRadius: BorderRadius.circular(18),
                  ),

                  child: Row(
                    children: [
                      const Icon(
                        Icons.verified_user,

                        color: Color(0xFF8B5CF6),

                        size: 18,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          l10n.createContentGuidelineText,

                          style: GoogleFonts.poppins(
                            color: Colors.white60,

                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                if (selectedPostType == 4)
                  buildArticleEditor(l10n)
                else ...[
                  if (selectedImage != null) buildImagePreview(),

                  if (selectedVideo != null &&
                      _videoController != null &&
                      _videoController!.value.isInitialized)
                    buildVideoPreview(),

                  if (selectedFile != null && selectedPostType == 0)
                    buildFilePreview(selectedFile!, l10n),

                  if (selectedImage != null ||
                      selectedVideo != null ||
                      selectedFile != null)
                    const SizedBox(height: 18),

                  buildInput(
                    controller: descripcionController,

                    hint: l10n.createPostHint,

                    maxLines: 4,
                  ),
                ],

                const SizedBox(height: 22),

                buildSectionTitle(l10n.createSectionHashtags),

                const SizedBox(height: 15),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,

                  children: hashtags.map((tag) {
                    final selected = selectedTags.contains(tag);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (selected) {
                            selectedTags.remove(tag);
                          } else {
                            selectedTags.add(tag);
                          }
                        });
                      },

                      child: buildSelectableTag(tag, selected),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                buildInput(
                  controller: proyectoTituloController,

                  hint: l10n.createProjectTitleHint,
                ),

                const SizedBox(height: 18),

                buildInput(
                  controller: proyectoDescripcionController,

                  hint: l10n.createProjectDescriptionHint,

                  maxLines: 5,
                ),

                const SizedBox(height: 25),

                buildSectionTitle(l10n.createSectionProgress),

                const SizedBox(height: 12),

                ClipRRect(
                  borderRadius: BorderRadius.circular(20),

                  child: LinearProgressIndicator(
                    value: progresoProyecto,

                    minHeight: 12,

                    backgroundColor: Colors.white10,

                    valueColor: const AlwaysStoppedAnimation(Color(0xFF8B5CF6)),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  l10n.createProjectProgressPercent(
                    (progresoProyecto * 100).toInt(),
                  ),

                  style: GoogleFonts.poppins(color: Colors.white54),
                ),

                Slider(
                  value: progresoProyecto,

                  activeColor: const Color(0xFF8B5CF6),

                  onChanged: (value) {
                    setState(() {
                      progresoProyecto = value;
                    });
                  },
                ),

                const SizedBox(height: 22),

                buildSectionTitle(l10n.createSectionRolesNeeded),

                const SizedBox(height: 15),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,

                  children: roles.map((rol) {
                    final selected = selectedRoles.contains(rol);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (selected) {
                            selectedRoles.remove(rol);
                          } else {
                            selectedRoles.add(rol);
                          }
                        });
                      },

                      child: buildSelectableTag(rol, selected),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 22),

                buildSectionTitle(l10n.createSectionHashtags),

                const SizedBox(height: 15),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,

                  children: hashtags.map((tag) {
                    final selected = selectedTags.contains(tag);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (selected) {
                            selectedTags.remove(tag);
                          } else {
                            selectedTags.add(tag);
                          }
                        });
                      },

                      child: buildSelectableTag(tag, selected),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 25),

                buildSectionTitle(l10n.createSectionProjectFiles),

                const SizedBox(height: 15),

                buildUploadCard(l10n),

                const SizedBox(height: 18),

                ...archivosProyecto.map((file) {
                  return buildProjectFileCard(file, l10n);
                }),
              ],
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                buildInput(
                  controller: colaboracionTituloController,

                  hint: l10n.createCollabSearchHint,
                ),

                const SizedBox(height: 18),

                buildInput(
                  controller: colaboracionDescripcionController,

                  hint: l10n.createCollabDescriptionHint,

                  maxLines: 5,
                ),

                const SizedBox(height: 25),

                buildSectionTitle(l10n.createSectionSkills),

                const SizedBox(height: 15),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,

                  children: hashtags.map((tag) {
                    final selected = selectedTags.contains(tag);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (selected) {
                            selectedTags.remove(tag);
                          } else {
                            selectedTags.add(tag);
                          }
                        });
                      },

                      child: buildSelectableTag(tag, selected),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 28),

                Container(
                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),

                    borderRadius: BorderRadius.circular(24),
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            l10n.createPublicCollabTitle,

                            style: GoogleFonts.poppins(
                              color: Colors.white,

                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            l10n.createPublicCollabSubtitle,

                            style: GoogleFonts.poppins(
                              color: Colors.white54,

                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      Switch(
                        value: publica,

                        activeColor: const Color(0xFF8B5CF6),

                        onChanged: (v) {
                          setState(() {
                            publica = v;
                          });
                        },
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

  void _wrapArticleSelection(String prefix, String suffix) {
    final text = articleController.text;
    final selection = articleController.selection;

    final start = selection.start < 0 ? text.length : selection.start;
    final end = selection.end < 0 ? text.length : selection.end;

    final selected = text.substring(start, end);
    final newText = text.replaceRange(start, end, '$prefix$selected$suffix');

    articleController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: start + prefix.length + selected.length + suffix.length,
      ),
    );
    articleFocusNode.requestFocus();
  }

  void _insertArticleLinePrefix(String prefix) {
    final text = articleController.text;
    final offset = articleController.selection.baseOffset < 0
        ? text.length
        : articleController.selection.baseOffset;

    final lineStart =
        text.lastIndexOf('\n', (offset - 1).clamp(0, text.length)) + 1;
    final newText = text.replaceRange(lineStart, lineStart, prefix);

    articleController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: offset + prefix.length),
    );
    articleFocusNode.requestFocus();
  }

  Widget _articleToolbarButton(
    IconData icon,
    VoidCallback onTap, {
    String? tooltip,
  }) {
    final button = InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: const Color(0xFF1A1A2E), size: 20),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip, child: button);
  }

  Widget buildArticleEditor(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFEDEDF2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _articleToolbarButton(
                Icons.format_bold,
                () => _wrapArticleSelection('**', '**'),
                tooltip: l10n.createArticleBoldTooltip,
              ),
              _articleToolbarButton(
                Icons.format_italic,
                () => _wrapArticleSelection('_', '_'),
                tooltip: l10n.createArticleItalicTooltip,
              ),
              _articleToolbarButton(
                Icons.format_underline,
                () => _wrapArticleSelection('__', '__'),
                tooltip: l10n.createArticleUnderlineTooltip,
              ),
              _articleToolbarButton(
                Icons.format_list_bulleted,
                () => _insertArticleLinePrefix('- '),
                tooltip: l10n.createArticleBulletTooltip,
              ),
              _articleToolbarButton(
                Icons.title,
                () => _insertArticleLinePrefix('# '),
                tooltip: l10n.createArticleTitleTooltip,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          constraints: const BoxConstraints(minHeight: 360),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAF7),
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: articleTitleController,
                style: GoogleFonts.merriweather(
                  color: const Color(0xFF1A1A2E),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: l10n.createArticleTitleHint,
                  hintStyle: GoogleFonts.merriweather(color: Colors.black38),
                ),
              ),
              const Divider(color: Colors.black12),
              TextField(
                controller: articleController,
                focusNode: articleFocusNode,
                minLines: 12,
                maxLines: null,
                style: GoogleFonts.merriweather(
                  color: const Color(0xFF1A1A2E),
                  fontSize: 15,
                  height: 1.6,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: l10n.createArticleBodyHint,
                  hintStyle: GoogleFonts.merriweather(color: Colors.black38),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            l10n.createArticleWordCount(
              articleController.text.trim().isEmpty
                  ? 0
                  : articleController.text.trim().split(RegExp(r'\s+')).length,
            ),
            style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget buildInput({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),

        borderRadius: BorderRadius.circular(22),
      ),

      child: TextField(
        controller: controller,

        maxLines: maxLines,

        style: GoogleFonts.poppins(color: Colors.white),

        decoration: InputDecoration(
          border: InputBorder.none,

          contentPadding: const EdgeInsets.all(18),

          hintText: hint,

          hintStyle: GoogleFonts.poppins(color: Colors.white38),
        ),
      ),
    );
  }

  Widget buildActionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        height: 55,

        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),

          borderRadius: BorderRadius.circular(18),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(icon, color: const Color(0xFF8B5CF6), size: 20),

            const SizedBox(width: 8),

            Text(
              title,

              style: GoogleFonts.poppins(
                color: Colors.white,

                fontWeight: FontWeight.w500,

                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildImagePreview() {
    return Padding(
      padding: const EdgeInsets.only(top: 22),

      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),

            child: Container(
              width: double.infinity,
              height: 220,

              color: Colors.black,

              child: Image.file(selectedImage!, fit: BoxFit.cover),
            ),
          ),

          Positioned(
            top: 10,
            left: 10,

            child: GestureDetector(
              onTap: editSelectedImage,

              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),

                decoration: BoxDecoration(
                  color: Colors.black54,

                  borderRadius: BorderRadius.circular(20),
                ),

                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.tune, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      AppLocalizations.of(context)!.mediaEditButton,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 10,
            right: 10,

            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedImage = null;
                });
              },

              child: Container(
                width: 38,
                height: 38,

                decoration: BoxDecoration(
                  color: Colors.black54,

                  borderRadius: BorderRadius.circular(50),
                ),

                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildVideoPreview() {
    return Padding(
      padding: const EdgeInsets.only(top: 22),

      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),

            child: Container(
              width: double.infinity,
              height: 220,

              color: Colors.black,

              child: FittedBox(
                fit: BoxFit.cover,

                child: SizedBox(
                  width: _videoController!.value.size.width,

                  height: _videoController!.value.size.height,

                  child: VideoPlayer(_videoController!),
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (_videoController!.value.isPlaying) {
                    _videoController!.pause();
                  } else {
                    _videoController!.play();
                  }
                });
              },

              child: Center(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),

                  opacity: _videoController!.value.isPlaying ? 0 : 1,

                  child: Container(
                    width: 75,
                    height: 75,

                    decoration: BoxDecoration(
                      color: Colors.black54,

                      borderRadius: BorderRadius.circular(50),
                    ),

                    child: Icon(
                      _videoController!.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,

                      color: Colors.white,

                      size: 42,
                    ),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: 10,
            left: 10,

            child: GestureDetector(
              onTap: trimSelectedVideo,

              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),

                decoration: BoxDecoration(
                  color: Colors.black54,

                  borderRadius: BorderRadius.circular(20),
                ),

                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.content_cut,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      AppLocalizations.of(context)!.mediaTrimButton,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 10,
            right: 10,

            child: GestureDetector(
              onTap: () {
                _videoController?.dispose();

                _videoController = null;

                setState(() {
                  selectedVideo = null;
                  videoTrimStart = null;
                  videoTrimEnd = null;
                });
              },

              child: Container(
                width: 38,
                height: 38,

                decoration: BoxDecoration(
                  color: Colors.black54,

                  borderRadius: BorderRadius.circular(50),
                ),

                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFilePreview(PlatformFile file, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(top: 22),

      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(18),

            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),

              borderRadius: BorderRadius.circular(24),
            ),

            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,

                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                    ),

                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: const Icon(Icons.description, color: Colors.white),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        file.name,

                        maxLines: 1,

                        overflow: TextOverflow.ellipsis,

                        style: GoogleFonts.poppins(
                          color: Colors.white,

                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        l10n.createFileSizeKb(
                          (file.size / 1024).toStringAsFixed(1),
                        ),

                        style: GoogleFonts.poppins(
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

          Positioned(
            top: 10,
            right: 10,

            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedFile = null;
                });
              },

              child: Container(
                width: 34,
                height: 34,

                decoration: BoxDecoration(
                  color: Colors.black54,

                  borderRadius: BorderRadius.circular(50),
                ),

                child: const Icon(Icons.close, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUploadCard(AppLocalizations l10n) {
    return GestureDetector(
      onTap: pickProjectFiles,

      child: Container(
        width: double.infinity,

        padding: const EdgeInsets.all(22),

        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),

          borderRadius: BorderRadius.circular(24),
        ),

        child: Column(
          children: [
            Container(
              width: 65,
              height: 65,

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                ),

                borderRadius: BorderRadius.circular(22),
              ),

              child: const Icon(
                Icons.cloud_upload,
                color: Colors.white,
                size: 34,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              l10n.createUploadFilesTitle,

              style: GoogleFonts.poppins(
                color: Colors.white,

                fontWeight: FontWeight.w600,

                fontSize: 17,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              l10n.createUploadFilesSubtitle,

              textAlign: TextAlign.center,

              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProjectFileCard(PlatformFile file, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),

        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        children: [
          const Icon(
            Icons.insert_drive_file,

            color: Color(0xFF8B5CF6),

            size: 32,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  file.name,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: GoogleFonts.poppins(
                    color: Colors.white,

                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  l10n.createFileSizeKb((file.size / 1024).toStringAsFixed(1)),

                  style: GoogleFonts.poppins(
                    color: Colors.white54,

                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Text(
      title,

      style: GoogleFonts.poppins(
        color: Colors.white,

        fontWeight: FontWeight.w600,

        fontSize: 17,
      ),
    );
  }

  Widget buildSelectableTag(String text, bool selected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),

      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),

        gradient: selected
            ? const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
              )
            : null,

        color: selected ? null : const Color(0xFF1A1A2E),
      ),

      child: Text(
        text,

        style: GoogleFonts.poppins(
          color: Colors.white,

          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
