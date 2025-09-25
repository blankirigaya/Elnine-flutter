// widgets/full_player.dart
import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/lyrics_service.dart';

class FullPlayer extends StatefulWidget {
  final Song currentSong;
  final bool isPlaying;
  final int currentTime;
  final int duration;
  final double volume;
  final bool isShuffled;
  final String repeatMode;
  final bool isLiked;
  final SongLyrics? lyrics;
  final int activeLyricIndex;
  final VoidCallback onClose;
  final VoidCallback onPlayPause;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onShuffle;
  final VoidCallback onRepeat;
  final VoidCallback onLikeToggle;
  final Function(double) onVolumeChange;
  final Function(double) onSeek;

  const FullPlayer({
    Key? key,
    required this.currentSong,
    required this.isPlaying,
    required this.currentTime,
    required this.duration,
    required this.volume,
    required this.isShuffled,
    required this.repeatMode,
    required this.isLiked,
    this.lyrics,
    this.activeLyricIndex = -1,
    required this.onClose,
    required this.onPlayPause,
    required this.onPrevious,
    required this.onNext,
    required this.onShuffle,
    required this.onRepeat,
    required this.onLikeToggle,
    required this.onVolumeChange,
    required this.onSeek,
  }) : super(key: key);

  @override
  _FullPlayerState createState() => _FullPlayerState();
}

class _FullPlayerState extends State<FullPlayer> {
  bool showAlbumArt =
      false; // Changed default to false to show lyrics by default
  ScrollController _lyricsScrollController = ScrollController();

  @override
  void didUpdateWidget(FullPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Auto-scroll lyrics to active line when not showing album art
    if (widget.activeLyricIndex != oldWidget.activeLyricIndex &&
        widget.activeLyricIndex >= 0 &&
        !showAlbumArt) {
      _scrollToActiveLyric();
    }
  }

  void _scrollToActiveLyric() {
    if (_lyricsScrollController.hasClients && widget.activeLyricIndex >= 0) {
      final offset = widget.activeLyricIndex * 80.0; // Approximate line height
      _lyricsScrollController.animateTo(
        offset,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  String formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  bool get isDesktop {
    return MediaQuery.of(context).size.width > 800;
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.duration > 0
        ? widget.currentTime / widget.duration
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFbe29ec).withOpacity(0.1), Colors.white],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.black87,
              size: isDesktop ? 24 : 30,
            ),
            onPressed: widget.onClose,
          ),
          title: Text(
            'Now Playing',
            style: TextStyle(
              color: Colors.black87,
              fontSize: isDesktop ? 16 : 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                showAlbumArt ? Icons.lyrics : Icons.album,
                color: Colors.black87,
                size: isDesktop ? 20 : 24,
              ),
              onPressed: () {
                setState(() {
                  showAlbumArt = !showAlbumArt;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.more_vert, 
                color: Colors.black87, 
                size: isDesktop ? 20 : 24,
              ),
              onPressed: () => _showOptionsMenu(),
            ),
          ],
        ),
        body: _buildPlayerView(progress),
      ),
    );
  }

  Widget _buildPlayerView(double progress) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          SizedBox(height: 20),
          // Lyrics Display or Album Art
          Expanded(
            flex: 3,
            child: showAlbumArt ? _buildAlbumArt() : _buildLyricsDisplay(),
          ),
          SizedBox(height: 40),
          // Song Info with Volume and Like
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.currentSong.title,
                      style: TextStyle(
                        fontSize: isDesktop ? 20 : 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 5),
                    Text(
                      widget.currentSong.artist,
                      style: TextStyle(
                        fontSize: isDesktop ? 16 : 18, 
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.currentSong.album.isNotEmpty)
                      Text(
                        widget.currentSong.album,
                        style: TextStyle(
                          fontSize: isDesktop ? 12 : 14, 
                          color: Colors.grey[500],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              SizedBox(width: 20),
              // Volume Control
              Container(
                width: isDesktop ? 120 : 150,
                child: Row(
                  children: [
                    Icon(
                      Icons.volume_down, 
                      color: Colors.grey[600],
                      size: isDesktop ? 18 : 20,
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: isDesktop ? 1.5 : 2,
                          thumbShape: RoundSliderThumbShape(
                            enabledThumbRadius: isDesktop ? 4 : 5,
                          ),
                          overlayShape: RoundSliderOverlayShape(
                            overlayRadius: isDesktop ? 8 : 10,
                          ),
                          activeTrackColor: Color(0xFFbe29ec),
                          inactiveTrackColor: Colors.grey[300],
                          thumbColor: Color(0xFFbe29ec),
                        ),
                        child: Slider(
                          value: widget.volume.clamp(0.0, 100.0),
                          min: 0,
                          max: 100,
                          onChanged: widget.onVolumeChange,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.volume_up, 
                      color: Colors.grey[600],
                      size: isDesktop ? 18 : 20,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),
              // Like Button
              GestureDetector(
                onTap: widget.onLikeToggle,
                child: Container(
                  padding: EdgeInsets.all(isDesktop ? 6 : 8),
                  decoration: BoxDecoration(
                    color: widget.isLiked
                        ? Color(0xFFbe29ec).withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    widget.isLiked ? Icons.favorite : Icons.favorite_outline,
                    color: widget.isLiked
                        ? Color(0xFFbe29ec)
                        : Colors.grey[600],
                    size: isDesktop ? 24 : 30,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          // Progress Bar
          Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: isDesktop ? 2 : 3,
                  thumbShape: RoundSliderThumbShape(
                    enabledThumbRadius: isDesktop ? 5 : 6,
                  ),
                  overlayShape: RoundSliderOverlayShape(
                    overlayRadius: isDesktop ? 10 : 12,
                  ),
                  activeTrackColor: Color(0xFFbe29ec),
                  inactiveTrackColor: Colors.grey[300],
                  thumbColor: Color(0xFFbe29ec),
                ),
                child: Slider(
                  value: progress.clamp(0.0, 1.0),
                  onChanged: widget.onSeek,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatTime(widget.currentTime),
                      style: TextStyle(
                        color: Colors.grey[600], 
                        fontSize: isDesktop ? 12 : 14,
                      ),
                    ),
                    Text(
                      formatTime(widget.duration),
                      style: TextStyle(
                        color: Colors.grey[600], 
                        fontSize: isDesktop ? 12 : 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                Icons.shuffle,
                onPressed: widget.onShuffle,
                isActive: widget.isShuffled,
              ),
              _buildControlButton(
                Icons.skip_previous,
                onPressed: widget.onPrevious,
                size: isDesktop ? 28 : 35,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFFbe29ec),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFbe29ec).withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: widget.onPlayPause,
                  icon: Icon(
                    widget.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: isDesktop ? 28 : 35,
                  ),
                  iconSize: isDesktop ? 50 : 60,
                ),
              ),
              _buildControlButton(
                Icons.skip_next,
                onPressed: widget.onNext,
                size: isDesktop ? 28 : 35,
              ),
              _buildControlButton(
                widget.repeatMode == 'one' ? Icons.repeat_one : Icons.repeat,
                onPressed: widget.onRepeat,
                isActive: widget.repeatMode != 'off',
              ),
            ],
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildLyricsDisplay() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFbe29ec).withOpacity(0.05),
            Colors.white.withOpacity(0.9),
          ],
        ),
        border: Border.all(color: Color(0xFFbe29ec).withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: widget.lyrics != null && widget.lyrics!.lines.isNotEmpty
          ? Column(
              children: [
                // Lyrics header with mini album art
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFbe29ec).withOpacity(0.05),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.currentSong.image,
                          width: isDesktop ? 32 : 40,
                          height: isDesktop ? 32 : 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: isDesktop ? 32 : 40,
                              height: isDesktop ? 32 : 40,
                              decoration: BoxDecoration(
                                color: Color(0xFFbe29ec).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.music_note,
                                color: Color(0xFFbe29ec),
                                size: isDesktop ? 16 : 20,
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lyrics',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isDesktop ? 12 : 14,
                                color: Color(0xFFbe29ec),
                              ),
                            ),
                            if (widget.lyrics!.source != null)
                              Text(
                                'Source: ${widget.lyrics!.source}',
                                style: TextStyle(
                                  fontSize: isDesktop ? 10 : 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.lyrics, 
                        color: Color(0xFFbe29ec), 
                        size: isDesktop ? 16 : 20,
                      ),
                    ],
                  ),
                ),
                // Scrollable lyrics
                Expanded(
                  child: ListView.builder(
                    controller: _lyricsScrollController,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    itemCount: widget.lyrics!.lines.length,
                    itemBuilder: (context, index) {
                      final line = widget.lyrics!.lines[index];
                      final isActive = index == widget.activeLyricIndex;
                      final isUpcoming = index > widget.activeLyricIndex;
                      final isPast = index < widget.activeLyricIndex;

                      return GestureDetector(
                        onTap: () {
                          // Seek to this lyric line
                          final seekTime =
                              line.startTimeMs / 1000.0 / widget.duration;
                          widget.onSeek(seekTime);
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          padding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 8,
                          ),
                          margin: EdgeInsets.symmetric(vertical: 2),
                          decoration: BoxDecoration(
                            color: isActive
                                ? Color(0xFFbe29ec).withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: isActive
                                ? Border.all(
                                    color: Color(0xFFbe29ec).withOpacity(0.3),
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              // Chorus indicator
                              if (line.isChorus)
                                Container(
                                  width: 4,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFbe29ec),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  margin: EdgeInsets.only(right: 12),
                                ),
                              // Lyric text
                              Expanded(
                                child: Text(
                                  line.text,
                                  style: TextStyle(
                                    fontSize: isActive 
                                        ? (isDesktop ? 16 : 18) 
                                        : (isDesktop ? 14 : 16),
                                    fontWeight: isActive
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isActive
                                        ? Color(0xFFbe29ec)
                                        : isPast
                                        ? Colors.grey[500]
                                        : isUpcoming
                                        ? Colors.grey[700]
                                        : Colors.grey[600],
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              // Time indicator for active line
                              if (isActive)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFbe29ec).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    formatTime(line.startTimeMs ~/ 1000),
                                    style: TextStyle(
                                      fontSize: isDesktop ? 10 : 12,
                                      color: Color(0xFFbe29ec),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lyrics_outlined,
                    size: isDesktop ? 48 : 64,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No lyrics available',
                    style: TextStyle(
                      fontSize: isDesktop ? 16 : 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Lyrics will appear here when available',
                    style: TextStyle(
                      fontSize: isDesktop ? 12 : 14, 
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  // Small album art as fallback
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.currentSong.image,
                      width: isDesktop ? 100 : 120,
                      height: isDesktop ? 100 : 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: isDesktop ? 100 : 120,
                          height: isDesktop ? 100 : 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFbe29ec).withOpacity(0.3),
                                Color(0xFFbe29ec).withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.music_note,
                            color: Color(0xFFbe29ec),
                            size: isDesktop ? 32 : 40,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAlbumArt() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Hero(
        tag: 'player-image-${widget.currentSong.id}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              widget.currentSong.image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFbe29ec).withOpacity(0.3),
                        Color(0xFFbe29ec).withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(
                    Icons.music_note,
                    color: Color(0xFFbe29ec),
                    size: isDesktop ? 64 : 80,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton(
    IconData icon, {
    required VoidCallback onPressed,
    bool isActive = false,
    double? size,
  }) {
    final buttonSize = size ?? (isDesktop ? 20 : 25);
    
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: isActive ? Color(0xFFbe29ec) : Colors.grey[700],
        size: buttonSize,
      ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.share, size: isDesktop ? 20 : 24),
              title: Text(
                'Share',
                style: TextStyle(fontSize: isDesktop ? 14 : 16),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.playlist_add, size: isDesktop ? 20 : 24),
              title: Text(
                'Add to Playlist',
                style: TextStyle(fontSize: isDesktop ? 14 : 16),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.info, size: isDesktop ? 20 : 24),
              title: Text(
                'Song Info',
                style: TextStyle(fontSize: isDesktop ? 14 : 16),
              ),
              onTap: () {
                Navigator.pop(context);
                _showSongInfo();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSongInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Song Information',
          style: TextStyle(fontSize: isDesktop ? 16 : 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Title', widget.currentSong.title),
            _buildInfoRow('Artist', widget.currentSong.artist),
            _buildInfoRow('Album', widget.currentSong.album),
            _buildInfoRow('Duration', widget.currentSong.duration),
            if (widget.lyrics != null)
              _buildInfoRow('Lyrics', '${widget.lyrics!.lines.length} lines'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(fontSize: isDesktop ? 14 : 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isDesktop ? 12 : 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: isDesktop ? 12 : 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _lyricsScrollController.dispose();
    super.dispose();
  }
}