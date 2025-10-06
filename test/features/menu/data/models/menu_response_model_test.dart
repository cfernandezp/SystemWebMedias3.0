import 'package:flutter_test/flutter_test.dart';
import 'package:system_web_medias/features/menu/data/models/menu_response_model.dart';

void main() {
  group('MenuResponseModel', () {
    group('fromJson', () {
      test('should parse JSON correctly', () {
        // Arrange
        final json = {
          'role': 'VENDEDOR',
          'menu': [
            {
              'id': 'dashboard',
              'label': 'Dashboard',
              'icon': 'dashboard',
              'route': '/dashboard',
              'children': null,
            },
            {
              'id': 'productos',
              'label': 'Productos',
              'icon': 'inventory',
              'route': null,
              'children': [
                {
                  'id': 'productos-catalogo',
                  'label': 'Gestionar catálogo',
                  'icon': null,
                  'route': '/products',
                  'children': null,
                },
              ],
            },
          ],
        };

        // Act
        final model = MenuResponseModel.fromJson(json);

        // Assert
        expect(model.role, 'VENDEDOR');
        expect(model.menu.length, 2);
        expect(model.menu[0].id, 'dashboard');
        expect(model.menu[1].id, 'productos');
        expect(model.menu[1].hasChildren, true);
      });

      test('should parse JSON with empty menu array', () {
        // Arrange
        final json = {
          'role': 'VENDEDOR',
          'menu': [],
        };

        // Act
        final model = MenuResponseModel.fromJson(json);

        // Assert
        expect(model.role, 'VENDEDOR');
        expect(model.menu, isEmpty);
      });
    });

    group('toJson', () {
      test('should convert model to JSON correctly', () {
        // Arrange
        final model = MenuResponseModel(
          role: 'ADMIN',
          menu: const [],
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['role'], 'ADMIN');
        expect(json['menu'], isA<List>());
        expect((json['menu'] as List).isEmpty, true);
      });
    });

    group('copyWith', () {
      test('should create copy with updated role', () {
        // Arrange
        final original = MenuResponseModel(
          role: 'VENDEDOR',
          menu: const [],
        );

        // Act
        final copy = original.copyWith(role: 'ADMIN');

        // Assert
        expect(copy.role, 'ADMIN');
        expect(copy.menu, isEmpty);
      });
    });
  });
}
