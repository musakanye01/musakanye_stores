enum InventorySortOption {
  nameAscending,
  nameDescending,
  stockLowToHigh,
  stockHighToLow,
  priceLowToHigh,
  priceHighToLow,
}

extension InventorySortOptionLabel on InventorySortOption {
  String get label => switch (this) {
    InventorySortOption.nameAscending => 'Name: A–Z',
    InventorySortOption.nameDescending => 'Name: Z–A',
    InventorySortOption.stockLowToHigh => 'Stock: Low to high',
    InventorySortOption.stockHighToLow => 'Stock: High to low',
    InventorySortOption.priceLowToHigh => 'Price: Low to high',
    InventorySortOption.priceHighToLow => 'Price: High to low',
  };
}
