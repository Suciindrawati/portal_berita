class Berita {
  final String id;
  final String judul;
  final String konten;
  final String penulis;
  final DateTime tanggal;
  final String? gambarUrl;

  Berita({
    required this.id,
    required this.judul,
    required this.konten,
    required this.penulis,
    required this.tanggal,
    this.gambarUrl,
  });

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'judul': judul,
      'konten': konten,
      'penulis': penulis,
      'tanggal': tanggal.toIso8601String(),
      'gambarUrl': gambarUrl,
    };
  }

  // Create from Map
  factory Berita.fromMap(Map<String, dynamic> map) {
    return Berita(
      id: map['id'] ?? '',
      judul: map['judul'] ?? '',
      konten: map['konten'] ?? '',
      penulis: map['penulis'] ?? '',
      tanggal: DateTime.parse(map['tanggal']),
      gambarUrl: map['gambarUrl'],
    );
  }

  // Create from NewsAPI response (backward compatibility)
  factory Berita.fromNewsApi(Map<String, dynamic> article) {
    // Parse published date
    DateTime? publishedDate;
    try {
      if (article['publishedAt'] != null) {
        publishedDate = DateTime.parse(article['publishedAt']);
      }
    } catch (e) {
      publishedDate = DateTime.now();
    }

    // Get author or source name
    String author = article['author'] ?? 
                    article['source']?['name'] ?? 
                    'Tidak diketahui';

    // Get content or description
    String content = article['content'] ?? 
                     article['description'] ?? 
                     article['title'] ?? 
                     'Tidak ada konten';

    // Remove [Removed] or [Source] tags from content
    content = content.replaceAll(RegExp(r'\[.*?\]'), '').trim();
    if (content.isEmpty) {
      content = article['description'] ?? article['title'] ?? 'Tidak ada konten';
    }

    return Berita(
      id: article['url'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      judul: article['title'] ?? 'Tanpa judul',
      konten: content,
      penulis: author,
      tanggal: publishedDate ?? DateTime.now(),
      gambarUrl: article['urlToImage'],
    );
  }

  // Create from NewsData.io response
  factory Berita.fromNewsDataIo(Map<String, dynamic> article) {
    // Parse published date (format: "2025-12-06 18:33:52")
    DateTime? publishedDate;
    try {
      if (article['pubDate'] != null) {
        final dateStr = article['pubDate'].toString();
        // Convert format "2025-12-06 18:33:52" to ISO format
        publishedDate = DateTime.parse(dateStr.replaceAll(' ', 'T'));
      }
    } catch (e) {
      publishedDate = DateTime.now();
    }

    // Get author/creator (bisa array atau string)
    String author = 'Tidak diketahui';
    if (article['creator'] != null) {
      if (article['creator'] is List) {
        final creators = article['creator'] as List;
        if (creators.isNotEmpty) {
          author = creators.first.toString();
        }
      } else {
        author = article['creator'].toString();
      }
    } else if (article['source_name'] != null) {
      author = article['source_name'].toString();
    }

    // Get content or description
    String content = article['description'] ?? 
                     article['content'] ?? 
                     article['title'] ?? 
                     'Tidak ada konten';

    // Remove tags if content contains "ONLY AVAILABLE IN PAID PLANS"
    if (content.contains('ONLY AVAILABLE')) {
      content = article['description'] ?? article['title'] ?? 'Tidak ada konten';
    }

    // Get image URL - ini yang penting untuk menampilkan gambar!
    String? imageUrl = article['image_url'];

    return Berita(
      id: article['article_id'] ?? 
          article['link'] ?? 
          DateTime.now().millisecondsSinceEpoch.toString(),
      judul: article['title'] ?? 'Tanpa judul',
      konten: content,
      penulis: author,
      tanggal: publishedDate ?? DateTime.now(),
      gambarUrl: imageUrl, // Menggunakan image_url dari newsdata.io
    );
  }
}

