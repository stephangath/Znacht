import { CATEGORIES, productId, RETAILERS } from '../src/model/types';

describe('Datenmodell', () => {
  test('Produkt-ID ist {retailer}_{ingredientId}', () => {
    expect(productId('migros', 'karotten')).toBe('migros_karotten');
  });

  test('Händlerliste entspricht der Spezifikation', () => {
    expect([...RETAILERS]).toEqual(['migros', 'coop', 'aldi', 'lidl', 'denner']);
  });

  test('Kategorien sind eindeutig', () => {
    expect(new Set(CATEGORIES).size).toBe(CATEGORIES.length);
  });
});
