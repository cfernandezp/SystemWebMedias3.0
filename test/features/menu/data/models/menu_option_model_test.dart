import 'package:flutter_test/flutter_test.dart';
import 'package:system_web_medias/features/menu/data/models/menu_option_model.dart';

void main() {
  group('MenuOptionModel', () {
    group('fromJson', () {
      test('should parse JSON without children correctly', () {
        // Arrange
        final json = {
          'id': 'dashboard',
          'label': 'Dashboard',
          'icon': 'dashboard',
          'route': '/dashboard',
          'children': null,
        };

        // Act
        final model = MenuOptionModel.fromJson(json);

        // Assert
        expect(model.id, 'dashboard');
        expect(model.label, 'Dashboard');
        expect(model.icon, 'dashboard');
        expect(model.route, '/dashboard');
        expect(model.children, null);
        expect(model.hasChildren, false);
        expect(model.isNavigable, true);
      });

      test('should parse JSON with children correctly (recursive)', () {
        // Arrange
        final json = {
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
            {
              'id': 'productos-stock',
              'label': 'Control de stock',
              'icon': null,
              'route': '/products/stock',
              'children': null,
            },
          ],
        };

        // Act
        final model = MenuOptionModel.fromJson(json);

        // Assert
        expect(model.id, 'productos');
        expect(model.label, 'Productos');
        expect(model.icon, 'inventory');
        expect(model.route, null);
        expect(model.hasChildren, true);
        expect(model.isNavigable, false);
        expect(model.isGroup, true);
        expect(model.children!.length, 2);

        // Assert first child
        final firstChild = model.children![0];
        expect(firstChild.id, 'productos-catalogo');
        expect(firstChild.label, 'Gestionar catálogo');
        expect(firstChild.route, '/products');
        expect(firstChild.hasChildren, false);

        // Assert second child
        final secondChild = model.children![1];
        expect(secondChild.id, 'productos-stock');
        expect(secondChild.label, 'Control de stock');
        expect(secondChild.route, '/products/stock');
      });

      test('should handle empty children array as null', () {
        // Arrange
        final json = {
          'id': 'test',
          'label': 'Test',
          'icon': 'test',
          'route': '/test',
          'children': [],
        };

        // Act
        final model = MenuOptionModel.fromJson(json);

        // Assert
        expect(model.children, isEmpty); // Lista vacía, no null
        expect(model.hasChildren, false);
      });
    });

    group('toJson', () {
      test('should convert model to JSON correctly', () {
        // Arrange
        const model = MenuOptionModel(
          id: 'dashboard',
          label: 'Dashboard',
          icon: 'dashboard',
          route: '/dashboard',
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['id'], 'dashboard');
        expect(json['label'], 'Dashboard');
        expect(json['icon'], 'dashboard');
        expect(json['route'], '/dashboard');
        expect(json['children'], null);
      });

      test('should convert model with children to JSON correctly', () {
        // Arrange
        const model = MenuOptionModel(
          id: 'productos',
          label: 'Productos',
          icon: 'inventory',
          children: [
            MenuOptionModel(
              id: 'productos-catalogo',
              label: 'Gestionar catálogo',
              route: '/products',
            ),
          ],
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['id'], 'productos');
        expect(json['children'], isA<List>());
        expect((json['children'] as List).length, 1);
        expect((json['children'] as List)[0]['id'], 'productos-catalogo');
      });
    });

    group('hasChildren', () {
      test('should return true when has children', () {
        const model = MenuOptionModel(
          id: 'test',
          label: 'Test',
          children: [
            MenuOptionModel(id: 'child', label: 'Child'),
          ],
        );

        expect(model.hasChildren, true);
      });

      test('should return false when children is null', () {
        const model = MenuOptionModel(
          id: 'test',
          label: 'Test',
        );

        expect(model.hasChildren, false);
      });

      test('should return false when children is empty', () {
        const model = MenuOptionModel(
          id: 'test',
          label: 'Test',
          children: [],
        );

        expect(model.hasChildren, false);
      });
    });

    group('toEntityList', () {
      test('should convert list of models to list of entities', () {
        // Arrange
        final models = [
          const MenuOptionModel(id: '1', label: 'One'),
          const MenuOptionModel(id: '2', label: 'Two'),
        ];

        // Act
        final entities = MenuOptionModel.toEntityList(models);

        // Assert
        expect(entities.length, 2);
        expect(entities[0].id, '1');
        expect(entities[1].id, '2');
      });
    });

    group('copyWith', () {
      test('should create copy with updated values', () {
        // Arrange
        const original = MenuOptionModel(
          id: 'test',
          label: 'Test',
          icon: 'icon',
          route: '/test',
        );

        // Act
        final copy = original.copyWith(label: 'Updated', route: '/updated');

        // Assert
        expect(copy.id, 'test'); // Unchanged
        expect(copy.label, 'Updated'); // Changed
        expect(copy.icon, 'icon'); // Unchanged
        expect(copy.route, '/updated'); // Changed
      });
    });
  });
}
