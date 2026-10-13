/// Configuration for 16-Line Quran pages
/// Pages are numbered from 002.webp to 549.webp
/// Each Juz has a specific range of pages
library;

class QuranPagesConfig {
  QuranPagesConfig._();

  static const String baseUrl =
      'https://github.com/vincenzoh-gh/16-Line-Quran/releases/download/v2';

  /// Total number of pages (002 to 549)
  static const int totalPages = 548;

  /// First page number (002.webp)
  static const int firstPage = 2;

  /// Last page number (549.webp)
  static const int lastPage = 549;

  /// Juz page ranges - easily adjustable
  /// Format: JuzNumber: [startPage, endPage]
  static const Map<int, List<int>> juzPageRanges = {
    // Juz 1: 20 pages (002-020)
    1: [2, 20],
    // Juz 2: 18 pages (021-038)
    2: [21, 38],
    // Juz 3: 18 pages (039-056)
    3: [39, 56],
    // Juz 4: 18 pages (057-074)
    4: [57, 74],
    // Juz 5: 18 pages (075-092)
    5: [75, 92],
    // Juz 6: 18 pages (093-110)
    6: [93, 110],
    // Juz 7: 18 pages (111-128)
    7: [111, 128],
    // Juz 8: 18 pages (129-146)
    8: [129, 146],
    // Juz 9: 18 pages (147-164)
    9: [147, 164],
    // Juz 10: 18 pages (165-182)
    10: [165, 182],
    // Juz 11: 18 pages (183-200)
    11: [183, 200],
    // Juz 12: 18 pages (201-218)
    12: [201, 218],
    // Juz 13: 18 pages (219-236)
    13: [219, 236],
    // Juz 14: 18 pages (237-254)
    14: [237, 254],
    // Juz 15: 18 pages (255-272)
    15: [255, 272],
    // Juz 16: 18 pages (273-290)
    16: [273, 290],
    // Juz 17: 18 pages (291-308)
    17: [291, 308],
    // Juz 18: 18 pages (309-326)
    18: [309, 326],
    // Juz 19: 18 pages (327-344)
    19: [327, 344],
    // Juz 20: 18 pages (345-362)
    20: [345, 362],
    // Juz 21: 18 pages (363-380)
    21: [363, 380],
    // Juz 22: 18 pages (381-398)
    22: [381, 398],
    // Juz 23: 18 pages (399-416)
    23: [399, 416],
    // Juz 24: 18 pages (417-434)
    24: [417, 434],
    // Juz 25: 18 pages (435-452)
    25: [435, 452],
    // Juz 26: 18 pages (453-470)
    26: [453, 470],
    // Juz 27: 18 pages (471-488)
    27: [471, 488],
    // Juz 28: 18 pages (489-506)
    28: [489, 506],
    // Juz 29: 18 pages (509-526)
    29: [509, 526],
    // Juz 30: 24 pages (529-549)
    30: [529, 549],
  };

  /// Get the filename for a page number (e.g., 2 -> "002.webp")
  static String getPageFilename(int pageNumber) {
    return '${pageNumber.toString().padLeft(3, '0')}.webp';
  }

  /// Get the full URL for a page
  static String getPageUrl(int pageNumber) {
    return '$baseUrl/${getPageFilename(pageNumber)}';
  }

  /// Get all pages for a specific Juz
  static List<int> getJuzPages(int juzNumber) {
    final range = juzPageRanges[juzNumber];
    if (range == null) return [];
    return List<int>.generate(
      range[1] - range[0] + 1,
      (index) => range[0] + index,
    );
  }

  /// Get the number of pages in a Juz
  static int getJuzPageCount(int juzNumber) {
    final range = juzPageRanges[juzNumber];
    if (range == null) return 0;
    return range[1] - range[0] + 1;
  }

  /// Get the starting page of a Juz
  static int getJuzStartPage(int juzNumber) {
    return juzPageRanges[juzNumber]?[0] ?? 2;
  }

  /// Get the ending page of a Juz
  static int getJuzEndPage(int juzNumber) {
    return juzPageRanges[juzNumber]?[1] ?? 549;
  }

  /// Get which Juz a specific page belongs to
  static int? getJuzForPage(int pageNumber) {
    for (final entry in juzPageRanges.entries) {
      if (pageNumber >= entry.value[0] && pageNumber <= entry.value[1]) {
        return entry.key;
      }
    }
    return null;
  }

  /// Juz position pages (quarter, half, three-quarters)
  /// Format: JuzNumber: [quarterPage, halfPage, threeQuartersPage]
  static const Map<int, List<int>> juzPositionPages = {
    // Juz 1: pages 2-20 (19 pages)
    1: [7, 11, 15],
    // Juz 2: pages 21-38 (18 pages)
    2: [25, 29, 33],
    // Juz 3: pages 39-56 (18 pages)
    3: [43, 47, 51],
    // Juz 4: pages 57-74 (18 pages)
    4: [61, 65, 69],
    // Juz 5: pages 75-92 (18 pages)
    5: [79, 83, 87],
    // Juz 6: pages 93-110 (18 pages)
    6: [97, 101, 105],
    // Juz 7: pages 111-128 (18 pages)
    7: [115, 119, 123],
    // Juz 8: pages 129-146 (18 pages)
    8: [133, 137, 141],
    // Juz 9: pages 147-164 (18 pages)
    9: [151, 155, 159],
    // Juz 10: pages 165-182 (18 pages)
    10: [169, 173, 177],
    // Juz 11: pages 183-200 (18 pages)
    11: [187, 191, 195],
    // Juz 12: pages 201-218 (18 pages)
    12: [205, 209, 213],
    // Juz 13: pages 219-236 (18 pages)
    13: [223, 227, 231],
    // Juz 14: pages 237-254 (18 pages)
    14: [241, 245, 249],
    // Juz 15: pages 255-272 (18 pages)
    15: [259, 263, 267],
    // Juz 16: pages 273-290 (18 pages)
    16: [277, 281, 285],
    // Juz 17: pages 291-308 (18 pages)
    17: [295, 299, 303],
    // Juz 18: pages 309-326 (18 pages)
    18: [313, 317, 321],
    // Juz 19: pages 327-344 (18 pages)
    19: [331, 335, 339],
    // Juz 20: pages 345-362 (18 pages)
    20: [349, 353, 357],
    // Juz 21: pages 363-380 (18 pages)
    21: [367, 371, 375],
    // Juz 22: pages 381-398 (18 pages)
    22: [385, 389, 393],
    // Juz 23: pages 399-416 (18 pages)
    23: [403, 407, 411],
    // Juz 24: pages 417-434 (18 pages)
    24: [421, 425, 429],
    // Juz 25: pages 435-452 (18 pages)
    25: [439, 443, 447],
    // Juz 26: pages 453-470 (18 pages)
    26: [457, 461, 465],
    // Juz 27: pages 471-488 (18 pages)
    27: [475, 479, 483],
    // Juz 28: pages 489-506 (18 pages)
    28: [493, 497, 501],
    // Juz 29: pages 509-526 (18 pages) - Note: there's a gap after page 506
    29: [513, 517, 521],
    // Juz 30: pages 529-549 (21 pages) - Note: there's a gap after page 526
    30: [534, 539, 545],
  };

  /// Get quarter, half, three-quarter page positions for a Juz
  static Map<String, int> getJuzPositionPages(int juzNumber) {
    final pages = getJuzPages(juzNumber);
    if (pages.isEmpty) return {};

    final positions = juzPositionPages[juzNumber];
    if (positions != null) {
      return {
        'start': pages[0],
        'quarter': positions[0],
        'half': positions[1],
        'threeQuarters': positions[2],
      };
    }

    // Fallback to calculated positions if not defined
    final pageCount = pages.length;
    return {
      'start': pages[0],
      'quarter': pages[(pageCount * 0.25).floor()],
      'half': pages[(pageCount * 0.5).floor()],
      'threeQuarters': pages[(pageCount * 0.75).floor()],
    };
  }
}
