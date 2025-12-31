import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Ringtone {
  final String title;
  final String uri;
  final String id;
  Ringtone({required this.title, required this.uri, required this.id});
}

class RingtoneView extends StatefulWidget {
  const RingtoneView({super.key});
  @override
  State<RingtoneView> createState() => _RingtoneViewState();
}

class _RingtoneViewState extends State<RingtoneView>
    with SingleTickerProviderStateMixin {
  List<Ringtone> ringtones = [];
  final MethodChannel _channel = const MethodChannel('flutter_channel');
  bool _isPlaying = false;
  String? _currentPlaying;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text(
          "Ringtones",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: _showSearch),
          PopupMenuButton<String>(
            onSelected: (value) => _showSortOptions(value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'name', child: Text('Sort by Name')),
              const PopupMenuItem(
                value: 'platform',
                child: Text('System Sounds'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Stats
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${ringtones.length} ringtones',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(
                        _isPlaying ? 'Now playing...' : 'Tap to preview',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _isPlaying
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isPlaying ? 'Playing' : 'Ready',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Ringtones List
          Expanded(
            child: ringtones.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: ringtones.length,
                    itemBuilder: (context, index) {
                      final ringtone = ringtones[index];
                      final isCurrent = _currentPlaying == ringtone.title;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: _buildRingtoneCard(ringtone, isCurrent, index),
                      );
                    },
                  ),
          ),

          // Enhanced Get Ringtones Button
          Container(
            padding: const EdgeInsets.all(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: ElevatedButton.icon(
                onPressed: ringtones.isEmpty ? _getRingtones : null,
                icon: ringtones.isNotEmpty
                    ? const Icon(Icons.refresh, size: 20)
                    : const Icon(Icons.download, size: 20),
                label: Text(ringtones.isEmpty ? 'Load Ringtones' : 'Refresh'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: ringtones.isEmpty ? 2 : 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_note_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 24),
          Text(
            'No ringtones loaded',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to load available ringtones',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildRingtoneCard(Ringtone ringtone, bool isCurrent, int index) {
    return Card(
      elevation: isCurrent ? 8 : 2,
      shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _playRingtone(ringtone),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Enhanced Play Button with Animation
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: isCurrent && _isPlaying
                        ? _scaleAnimation.value
                        : 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCurrent
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline,
                          width: 2,
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          isCurrent && _isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: isCurrent
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
                        onPressed: () => _playRingtone(ringtone),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(width: 16),

              // Ringtone Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ringtone.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'System sound • ${ringtone.uri.split('/').last}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Playing indicator
              if (isCurrent && _isPlaying)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 8,
                        height: 8,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Playing',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _playRingtone(Ringtone ringtone) async {
    _animationController.forward().then((_) => _animationController.reverse());

    try {
      final bool played = await _channel.invokeMethod("playRingtone", {
        "title": ringtone.title,
      });
      if (played) {
        setState(() {
          _isPlaying = true;
          _currentPlaying = ringtone.title;
        });
        // Auto stop after 5 seconds
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted && _currentPlaying == ringtone.title) {
            setState(() {
              _isPlaying = false;
              _currentPlaying = null;
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Playback error: $e')));
      }
    }
  }

  Future<void> _getRingtones() async {
    try {
      final List<dynamic> dynamicResult = await _channel.invokeMethod(
        "getRingtones",
      );
      setState(() {
        ringtones = dynamicResult.map((item) {
          return Ringtone(
            title: item['title'] as String,
            uri: item['uri'] as String,
            id: item['id'] as String,
          );
        }).toList();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Loaded ${ringtones.length} ringtones'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showSearch() {
    showSearch(context: context, delegate: RingtoneSearchDelegate(ringtones));
  }

  void _showSortOptions(String option) {
    // Implement sorting logic
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Sorting by $option')));
  }
}

// Simple Search Delegate (bonus feature)
class RingtoneSearchDelegate extends SearchDelegate<Ringtone?> {
  final List<Ringtone> ringtones;
  RingtoneSearchDelegate(this.ringtones);

  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) {
    final results = ringtones
        .where(
          (ringtone) =>
              ringtone.title.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) =>
          ListTile(title: Text(results[index].title)),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) => buildResults(context);
}
