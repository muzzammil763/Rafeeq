import 'dart:async';
import 'dart:io';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rafeeq/ui/quran/sixteen_line_quran/quran_pages_config.dart';

/// Custom download service that handles Quran image downloads
/// Runs independently of UI and persists until app closes or download completes
///
/// All state updates are done via Stream - no callbacks that can hold references to disposed widgets
class QuranDownloadService {
  static final QuranDownloadService _instance =
      QuranDownloadService._internal();
  factory QuranDownloadService() => _instance;
  QuranDownloadService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': '*/*', 'Accept-Encoding': 'gzip, deflate, br'},
    ),
  );

  // Track active downloads
  final Map<int, bool> _downloadingJuz = {};
  final Map<int, double> _juzProgress = {};
  final Map<int, int> _downloadedPagesCount = {};

  // Stream controllers for progress updates
  final _progressController = StreamController<DownloadProgress>.broadcast();
  Stream<DownloadProgress> get progressStream => _progressController.stream;

  // Stream for overall bulk download progress
  final _bulkProgressController =
      StreamController<BulkDownloadProgress>.broadcast();
  Stream<BulkDownloadProgress> get bulkProgressStream =>
      _bulkProgressController.stream;

  // Dispose guard flag
  bool _disposed = false;

  bool get isAnyDownloading => _downloadingJuz.values.any((v) => v);

  /// Reset all download states - call this when starting fresh
  void resetAllDownloads() {
    _downloadingJuz.clear();
    _juzProgress.clear();
    _downloadedPagesCount.clear();
    developer.log('Download states reset', name: 'QuranDownload');
  }

  /// Download a single Juz
  /// Returns immediately and streams progress via progressStream
  Future<bool> downloadJuz(int juzNumber) async {
    if (_downloadingJuz[juzNumber] == true) {
      developer.log(
        'Juz $juzNumber is already downloading',
        name: 'QuranDownload',
      );
      return false;
    }

    try {
      _downloadingJuz[juzNumber] = true;
      _juzProgress[juzNumber] = 0.0;

      final pages = QuranPagesConfig.getJuzPages(juzNumber);
      final totalPages = pages.length;
      final directory = await _getDownloadDirectory();

      // Count existing files first (for resume)
      int existingCount = 0;
      for (final page in pages) {
        final filename = QuranPagesConfig.getPageFilename(page);
        final file = File('$directory/$filename');
        if (await file.exists()) {
          existingCount++;
        }
      }
      _downloadedPagesCount[juzNumber] = existingCount;

      developer.log(
        'Starting download of Juz $juzNumber ($totalPages pages) - $existingCount already exist',
        name: 'QuranDownload',
      );

      int successCount = existingCount;
      int failCount = 0;

      for (int i = 0; i < pages.length; i++) {
        if (!_downloadingJuz[juzNumber]!) {
          // Download was cancelled
          developer.log(
            'Download cancelled for Juz $juzNumber',
            name: 'QuranDownload',
          );
          return false;
        }

        final page = pages[i];
        final filename = QuranPagesConfig.getPageFilename(page);
        final url = QuranPagesConfig.getPageUrl(page);
        final filePath = '$directory/$filename';

        // Check if already exists
        final file = File(filePath);
        if (await file.exists()) {
          successCount++;
          _downloadedPagesCount[juzNumber] = successCount;
          final progress = (i + 1) / totalPages;
          _juzProgress[juzNumber] = progress;

          _notifyProgress(juzNumber, progress, i + 1, totalPages, filename);
          continue;
        }

        try {
          await _downloadFile(url, filePath);
          successCount++;
          _downloadedPagesCount[juzNumber] = successCount;

          final progress = (i + 1) / totalPages;
          _juzProgress[juzNumber] = progress;

          _notifyProgress(juzNumber, progress, i + 1, totalPages, filename);

          developer.log(
            'Downloaded: $filename ($successCount/$totalPages)',
            name: 'QuranDownload',
          );
        } catch (e) {
          failCount++;
          developer.log(
            'Failed to download $filename: $e',
            name: 'QuranDownload',
          );

          // Retry once
          try {
            await Future.delayed(const Duration(seconds: 1));
            await _downloadFile(url, filePath);
            successCount++;
            failCount--;
            _downloadedPagesCount[juzNumber] = successCount;

            final progress = (i + 1) / totalPages;
            _juzProgress[juzNumber] = progress;

            _notifyProgress(juzNumber, progress, i + 1, totalPages, filename);
          } catch (e2) {
            developer.log(
              'Retry failed for $filename: $e2',
              name: 'QuranDownload',
            );
          }
        }
      }

      final isComplete = successCount >= totalPages;

      if (isComplete) {
        developer.log(
          'Juz $juzNumber fully downloaded! ($successCount/$totalPages)',
          name: 'QuranDownload',
        );
      } else if (failCount > 0) {
        developer.log(
          'Download incomplete: $successCount succeeded, $failCount failed',
          name: 'QuranDownload',
        );
      }

      return isComplete;
    } catch (e) {
      developer.log(
        'Error downloading Juz $juzNumber: $e',
        name: 'QuranDownload',
      );
      return false;
    } finally {
      _downloadingJuz[juzNumber] = false;
    }
  }

  /// Download all Juz (skipping already downloaded ones)
  /// Streams progress via bulkProgressStream
  Future<void> downloadAllJuz() async {
    developer.log('downloadAllJuz() called', name: 'QuranDownload');
    try {
      // Count what needs to be downloaded
      int totalPagesToDownload = 0;
      final List<int> pendingJuz = [];

      for (int i = 1; i <= 30; i++) {
        final isDownloaded = await _isJuzDownloaded(i);
        developer.log(
          'Juz $i isDownloaded: $isDownloaded',
          name: 'QuranDownload',
        );
        if (!isDownloaded) {
          final pageCount = QuranPagesConfig.getJuzPageCount(i);
          totalPagesToDownload += pageCount;
          pendingJuz.add(i);
          developer.log(
            'Juz $i added to pending list ($pageCount pages)',
            name: 'QuranDownload',
          );
        }
      }

      developer.log(
        'Pending Juz count: ${pendingJuz.length}, Total pages to download: $totalPagesToDownload',
        name: 'QuranDownload',
      );

      if (pendingJuz.isEmpty) {
        developer.log('All Juz already downloaded!', name: 'QuranDownload');
        _bulkProgressController.add(
          BulkDownloadProgress(
            totalJuz: 30,
            totalPages: 0,
            completedJuz: 30,
            downloadedPages: 0,
            currentJuzNumber: 0,
            currentPageName: '',
            isComplete: true,
          ),
        );
        return;
      }

      developer.log(
        'Starting bulk download: ${pendingJuz.length} Juz, '
        '$totalPagesToDownload pages',
        name: 'QuranDownload',
      );

      _bulkProgressController.add(
        BulkDownloadProgress(
          totalJuz: pendingJuz.length,
          totalPages: totalPagesToDownload,
          completedJuz: 0,
          downloadedPages: 0,
          currentJuzNumber: pendingJuz.first,
          currentPageName: '',
          justCompletedJuzNumber: null,
          isComplete: false,
        ),
      );

      int completedCount = 0;
      int overallDownloadedPages = 0;
      int? lastCompletedJuz;

      // Track current Juz progress for smooth updates
      int currentJuzDownloadedPages = 0;

      for (final juzNumber in pendingJuz) {
        final pages = QuranPagesConfig.getJuzPages(juzNumber);
        final pageCount = pages.length;
        currentJuzDownloadedPages = 0;

        developer.log(
          'Starting Juz $juzNumber ($pageCount pages)',
          name: 'QuranDownload',
        );

        // Start downloading this Juz
        final downloadFuture = downloadJuz(juzNumber);

        // Poll progress while downloading
        while (_downloadingJuz[juzNumber] == true) {
          await Future.delayed(const Duration(milliseconds: 100));

          // Get current progress for this Juz
          final currentProgress = _downloadedPagesCount[juzNumber] ?? 0;
          if (currentProgress != currentJuzDownloadedPages) {
            currentJuzDownloadedPages = currentProgress;

            // Calculate overall progress
            final totalDownloadedSoFar =
                overallDownloadedPages + currentJuzDownloadedPages;
            final currentPageIndex = currentJuzDownloadedPages - 1;
            final currentPageName =
                currentPageIndex >= 0 && currentPageIndex < pages.length
                ? QuranPagesConfig.getPageFilename(pages[currentPageIndex])
                : '';

            _bulkProgressController.add(
              BulkDownloadProgress(
                totalJuz: pendingJuz.length,
                totalPages: totalPagesToDownload,
                completedJuz: completedCount,
                downloadedPages: totalDownloadedSoFar,
                currentJuzNumber: juzNumber,
                currentPageName: currentPageName,
                justCompletedJuzNumber: null,
                isComplete: false,
              ),
            );
          }
        }

        // Wait for download to complete
        await downloadFuture;

        completedCount++;
        overallDownloadedPages += pageCount;
        lastCompletedJuz = juzNumber;

        // Final update for this Juz
        _bulkProgressController.add(
          BulkDownloadProgress(
            totalJuz: pendingJuz.length,
            totalPages: totalPagesToDownload,
            completedJuz: completedCount,
            downloadedPages: overallDownloadedPages,
            currentJuzNumber: juzNumber,
            currentPageName: pages.isNotEmpty
                ? QuranPagesConfig.getPageFilename(pages.last)
                : '',
            justCompletedJuzNumber: lastCompletedJuz,
            isComplete: completedCount >= pendingJuz.length,
          ),
        );
      }

      developer.log(
        'Bulk download complete: $completedCount/${pendingJuz.length} Juz',
        name: 'QuranDownload',
      );
    } catch (e) {
      developer.log('Error in bulk download: $e', name: 'QuranDownload');
    }
  }

  /// Check if a Juz is fully downloaded
  Future<bool> _isJuzDownloaded(int juzNumber) async {
    final pages = QuranPagesConfig.getJuzPages(juzNumber);
    final directory = await _getDownloadDirectory();

    for (final page in pages) {
      final filename = QuranPagesConfig.getPageFilename(page);
      final file = File('$directory/$filename');
      if (!await file.exists()) {
        return false;
      }
    }
    return true;
  }

  /// Download a single file
  Future<void> _downloadFile(String url, String filePath) async {
    final response = await _dio.download(
      url,
      filePath,
      options: Options(
        followRedirects: true,
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
  }

  /// Get download directory
  Future<String> _getDownloadDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final quranDir = Directory('${appDir.path}/16_line_quran_images');
    if (!await quranDir.exists()) {
      await quranDir.create(recursive: true);
    }
    return quranDir.path;
  }

  /// Notify progress via stream
  void _notifyProgress(
    int juzNumber,
    double progress,
    int downloaded,
    int total,
    String currentFile,
  ) {
    _progressController.add(
      DownloadProgress(
        juzNumber: juzNumber,
        progress: progress,
        downloadedPages: downloaded,
        totalPages: total,
        currentFile: currentFile,
      ),
    );
  }

  /// Get current progress for a Juz
  double? getJuzProgress(int juzNumber) => _juzProgress[juzNumber];

  /// Check if a Juz is currently downloading
  bool isJuzDownloading(int juzNumber) => _downloadingJuz[juzNumber] ?? false;

  /// Cancel all downloads
  void cancelAll() {
    for (final key in _downloadingJuz.keys) {
      _downloadingJuz[key] = false;
    }
    developer.log('All downloads cancelled', name: 'QuranDownload');
  }

  /// Dispose
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _progressController.close();
    _bulkProgressController.close();
  }
}

/// Download progress data class for single Juz
class DownloadProgress {
  final int juzNumber;
  final double progress;
  final int downloadedPages;
  final int totalPages;
  final String currentFile;

  DownloadProgress({
    required this.juzNumber,
    required this.progress,
    required this.downloadedPages,
    required this.totalPages,
    required this.currentFile,
  });
}

/// Bulk download progress data class
class BulkDownloadProgress {
  final int totalJuz;
  final int totalPages;
  final int completedJuz;
  final int downloadedPages;
  final int currentJuzNumber;
  final String currentPageName;
  final int? justCompletedJuzNumber;
  final bool isComplete;

  BulkDownloadProgress({
    required this.totalJuz,
    required this.totalPages,
    required this.completedJuz,
    required this.downloadedPages,
    required this.currentJuzNumber,
    required this.currentPageName,
    this.justCompletedJuzNumber,
    required this.isComplete,
  });
}
