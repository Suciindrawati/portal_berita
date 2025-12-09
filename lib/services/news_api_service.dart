import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/berita.dart';

class NewsApiService {
  static const String _apiKey = 'pub_baad8678c711437b8618d97c1e7cc4c2';
  static const String _baseUrl = 'https://newsdata.io/api/1';
  
  // Get all news - mengambil berita dari berbagai sumber
  Future<List<Berita>> getAllNewsIndonesia() async {
    try {
      List<Berita> allBerita = [];
      Set<String> seenIds = {}; // Untuk menghindari duplikasi
      
      // Ambil berita dari berbagai domain/sumber
      final domains = ['bbc', 'cnn', 'reuters', 'theguardian'];
      
      for (var domain in domains) {
        try {
          final url = Uri.parse(
            '$_baseUrl/latest?apikey=$_apiKey&domain=$domain',
          );
          
          final response = await http.get(url);
          
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            
            if (data['status'] == 'success' && data['results'] != null) {
              final List<dynamic> articles = data['results'];
              for (var article in articles) {
                final berita = Berita.fromNewsDataIo(article);
                // Hanya tambahkan jika belum ada (berdasarkan article_id)
                if (!seenIds.contains(berita.id)) {
                  allBerita.add(berita);
                  seenIds.add(berita.id);
                }
              }
            }
          }
        } catch (e) {
          // Lanjutkan ke domain berikutnya jika ada error
          continue;
        }
      }
      
      // Jika masih sedikit, ambil dari latest tanpa filter domain
      if (allBerita.length < 20) {
        try {
          final url = Uri.parse(
            '$_baseUrl/latest?apikey=$_apiKey&country=id&language=id',
          );
          
          final response = await http.get(url);
          
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            
            if (data['status'] == 'success' && data['results'] != null) {
              final List<dynamic> articles = data['results'];
              for (var article in articles) {
                final berita = Berita.fromNewsDataIo(article);
                if (!seenIds.contains(berita.id)) {
                  allBerita.add(berita);
                  seenIds.add(berita.id);
                }
              }
            }
          }
        } catch (e) {
          // Ignore error
        }
      }
      
      // Sort berdasarkan tanggal terbaru
      allBerita.sort((a, b) => b.tanggal.compareTo(a.tanggal));
      
      if (allBerita.isEmpty) {
        throw Exception('Tidak ada artikel ditemukan');
      }
      
      return allBerita;
    } catch (e) {
      rethrow;
    }
  }
  
  // Get news with filters
  Future<List<Berita>> getNews({
    String? country,
    String? category,
    String? query,
  }) async {
    try {
      List<Berita> allBerita = [];
      Set<String> seenIds = {};
      
      // Build URL parameters
      final Map<String, String> params = {
        'apikey': _apiKey,
      };
      
      if (country != null && country.isNotEmpty) {
        params['country'] = country;
      }
      
      if (category != null && category.isNotEmpty) {
        params['category'] = category;
      }
      
      if (query != null && query.isNotEmpty) {
        params['q'] = query;
      }
      
      // Build URL
      final queryString = params.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
      final url = Uri.parse('$_baseUrl/latest?$queryString');
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'success' && data['results'] != null) {
          final List<dynamic> articles = data['results'];
          for (var article in articles) {
            final berita = Berita.fromNewsDataIo(article);
            if (!seenIds.contains(berita.id)) {
              allBerita.add(berita);
              seenIds.add(berita.id);
            }
          }
        }
      } else {
        throw Exception('Gagal mengambil berita: ${response.statusCode}');
      }
      
      // Sort berdasarkan tanggal terbaru
      allBerita.sort((a, b) => b.tanggal.compareTo(a.tanggal));
      
      if (allBerita.isEmpty) {
        throw Exception('Tidak ada artikel ditemukan');
      }
      
      return allBerita;
    } catch (e) {
      rethrow;
    }
  }
  
  // Get top headlines from Indonesia (untuk backward compatibility)
  Future<List<Berita>> getTopHeadlinesIndonesia() async {
    return getAllNewsIndonesia();
  }
  
  // Search news
  Future<List<Berita>> searchNewsIndonesia({String? query}) async {
    try {
      final searchQuery = query ?? 'indonesia';
      final url = Uri.parse(
        '$_baseUrl/latest?apikey=$_apiKey&q=$searchQuery&language=id',
      );
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'success' && data['results'] != null) {
          final List<dynamic> articles = data['results'];
          return articles.map((article) {
            return Berita.fromNewsDataIo(article);
          }).toList();
        } else {
          throw Exception('Tidak ada artikel ditemukan');
        }
      } else {
        throw Exception('Gagal mengambil berita: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}

