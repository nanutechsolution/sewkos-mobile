import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static const String _favoriteKey = 'favorite_kos_ids';

  static Future<List<String>> getFavoriteKosIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoriteKey) ?? [];
  }

  static Future<void> addFavoriteKos(int kosId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = await getFavoriteKosIds();
    if (!favorites.contains(kosId.toString())) {
      favorites.add(kosId.toString());
      await prefs.setStringList(_favoriteKey, favorites);
    }
  }

  static Future<void> removeFavoriteKos(int kosId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = await getFavoriteKosIds();
    favorites.remove(kosId.toString());
    await prefs.setStringList(_favoriteKey, favorites);
  }

  static Future<bool> isFavorite(int kosId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList(_favoriteKey) ?? [];
    return favorites.contains(kosId.toString());
  }
}
