import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/firebase/firebase_providers.dart';
import '../models/models.dart';

/// Lesezugriff auf Stammdaten und Konfiguration (für Clients nur lesbar).
class CatalogRepository {
  CatalogRepository(this._db);

  final FirebaseFirestore _db;

  Future<AppConfig> loadConfig() async {
    final snap = await _db.doc('config/app').get();
    final data = snap.data();
    return data == null ? AppConfig.fallback : AppConfig.fromJson(data);
  }

  Future<List<Recipe>> loadRecipes() async {
    final snap = await _db.collection('recipes').get();
    return [for (final d in snap.docs) Recipe.fromJson(d.data())];
  }

  Future<List<Ingredient>> loadIngredients() async {
    final snap = await _db.collection('ingredients').get();
    return [for (final d in snap.docs) Ingredient.fromJson(d.data())];
  }

  Future<List<Product>> loadProducts(Retailer retailer) async {
    final snap =
        await _db.collection('products').where('retailer', isEqualTo: retailer.wire).get();
    return [for (final d in snap.docs) Product.fromJson(d.data())];
  }

  Future<int> countRecipes() async {
    final agg = await _db.collection('recipes').count().get();
    return agg.count ?? 0;
  }
}

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => CatalogRepository(ref.watch(firestoreProvider)),
);

final appConfigProvider = FutureProvider<AppConfig>(
  (ref) => ref.watch(catalogRepositoryProvider).loadConfig(),
);
