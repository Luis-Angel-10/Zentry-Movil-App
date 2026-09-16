import 'package:flutter/material.dart';

class StoreColorItem {
  final String id;
  final Color color;
  final int price;

  const StoreColorItem({
    required this.id,
    required this.color,
    required this.price,
  });
}

const List<StoreColorItem> kStoreColors = [
  StoreColorItem(id: 'store_rose', color: Color(0xFFF43F5E), price: 150),
  StoreColorItem(id: 'store_lime', color: Color(0xFF84CC16), price: 150),
  StoreColorItem(id: 'store_sky', color: Color(0xFF0EA5E9), price: 200),
  StoreColorItem(id: 'store_violet', color: Color(0xFF8B5CF6), price: 200),
  StoreColorItem(id: 'store_amber', color: Color(0xFFF59E0B), price: 250),
  StoreColorItem(id: 'store_emerald', color: Color(0xFF10B981), price: 250),
  StoreColorItem(id: 'store_fuchsia', color: Color(0xFFD946EF), price: 320),
  StoreColorItem(id: 'store_gold', color: Color(0xFFD4AF37), price: 400),
];
