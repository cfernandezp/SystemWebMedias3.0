import 'package:flutter_test/flutter_test.dart';
import 'package:system_web_medias/features/user/data/models/user_profile_model.dart';

void main() {
  group('UserProfileModel', () {
    group('fromJson', () {
      test('should map snake_case to camelCase correctly', () {
        // Arrange
        final json = {
          'id': 'uuid-123',
          'nombre_completo': 'Juan Pérez',
          'email': 'juan@example.com',
          'rol': 'VENDEDOR',
          'avatar_url': null,
          'sidebar_collapsed': true,
        };

        // Act
        final model = UserProfileModel.fromJson(json);

        // Assert
        expect(model.id, 'uuid-123');
        expect(model.nombreCompleto, 'Juan Pérez');
        expect(model.email, 'juan@example.com');
        expect(model.rol, 'VENDEDOR');
        expect(model.avatarUrl, null);
        expect(model.sidebarCollapsed, true);
      });

      test('should handle avatar_url correctly', () {
        // Arrange
        final json = {
          'id': 'uuid-123',
          'nombre_completo': 'Juan Pérez',
          'email': 'juan@example.com',
          'rol': 'ADMIN',
          'avatar_url': 'https://example.com/avatar.jpg',
          'sidebar_collapsed': false,
        };

        // Act
        final model = UserProfileModel.fromJson(json);

        // Assert
        expect(model.avatarUrl, 'https://example.com/avatar.jpg');
        expect(model.hasAvatar, true);
      });
    });

    group('toJson', () {
      test('should map camelCase to snake_case correctly', () {
        // Arrange
        const model = UserProfileModel(
          id: 'uuid-123',
          nombreCompleto: 'María García',
          email: 'maria@example.com',
          rol: 'GERENTE',
          avatarUrl: null,
          sidebarCollapsed: false,
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['id'], 'uuid-123');
        expect(json['nombre_completo'], 'María García');
        expect(json['email'], 'maria@example.com');
        expect(json['rol'], 'GERENTE');
        expect(json['avatar_url'], null);
        expect(json['sidebar_collapsed'], false);
      });
    });

    group('initials', () {
      test('should generate initials from two-word name', () {
        // Arrange
        const model = UserProfileModel(
          id: 'uuid',
          nombreCompleto: 'Juan Pérez',
          email: 'juan@example.com',
          rol: 'VENDEDOR',
          sidebarCollapsed: false,
        );

        // Act & Assert
        expect(model.initials, 'JP');
      });

      test('should generate initials from three-word name', () {
        // Arrange
        const model = UserProfileModel(
          id: 'uuid',
          nombreCompleto: 'Juan Carlos Pérez',
          email: 'juan@example.com',
          rol: 'VENDEDOR',
          sidebarCollapsed: false,
        );

        // Act & Assert
        expect(model.initials, 'JC'); // Primeras dos palabras
      });

      test('should generate initial from single-word name', () {
        // Arrange
        const model = UserProfileModel(
          id: 'uuid',
          nombreCompleto: 'Juan',
          email: 'juan@example.com',
          rol: 'VENDEDOR',
          sidebarCollapsed: false,
        );

        // Act & Assert
        expect(model.initials, 'J');
      });

      test('should handle names with extra spaces', () {
        // Arrange
        const model = UserProfileModel(
          id: 'uuid',
          nombreCompleto: '  Juan   Pérez  ',
          email: 'juan@example.com',
          rol: 'VENDEDOR',
          sidebarCollapsed: false,
        );

        // Act & Assert
        expect(model.initials, 'JP');
      });
    });

    group('roleBadge', () {
      test('should return "Administrador" for ADMIN', () {
        const model = UserProfileModel(
          id: 'uuid',
          nombreCompleto: 'Admin User',
          email: 'admin@example.com',
          rol: 'ADMIN',
          sidebarCollapsed: false,
        );

        expect(model.roleBadge, 'Administrador');
      });

      test('should return "Gerente" for GERENTE', () {
        const model = UserProfileModel(
          id: 'uuid',
          nombreCompleto: 'Manager User',
          email: 'manager@example.com',
          rol: 'GERENTE',
          sidebarCollapsed: false,
        );

        expect(model.roleBadge, 'Gerente');
      });

      test('should return "Vendedor" for VENDEDOR', () {
        const model = UserProfileModel(
          id: 'uuid',
          nombreCompleto: 'Seller User',
          email: 'seller@example.com',
          rol: 'VENDEDOR',
          sidebarCollapsed: false,
        );

        expect(model.roleBadge, 'Vendedor');
      });

      test('should return original role for unknown role', () {
        const model = UserProfileModel(
          id: 'uuid',
          nombreCompleto: 'Unknown User',
          email: 'unknown@example.com',
          rol: 'CUSTOM_ROLE',
          sidebarCollapsed: false,
        );

        expect(model.roleBadge, 'CUSTOM_ROLE');
      });
    });

    group('hasAvatar', () {
      test('should return true when avatar URL is set', () {
        const model = UserProfileModel(
          id: 'uuid',
          nombreCompleto: 'Test User',
          email: 'test@example.com',
          rol: 'VENDEDOR',
          avatarUrl: 'https://example.com/avatar.jpg',
          sidebarCollapsed: false,
        );

        expect(model.hasAvatar, true);
      });

      test('should return false when avatar URL is null', () {
        const model = UserProfileModel(
          id: 'uuid',
          nombreCompleto: 'Test User',
          email: 'test@example.com',
          rol: 'VENDEDOR',
          avatarUrl: null,
          sidebarCollapsed: false,
        );

        expect(model.hasAvatar, false);
      });

      test('should return false when avatar URL is empty', () {
        const model = UserProfileModel(
          id: 'uuid',
          nombreCompleto: 'Test User',
          email: 'test@example.com',
          rol: 'VENDEDOR',
          avatarUrl: '',
          sidebarCollapsed: false,
        );

        expect(model.hasAvatar, false);
      });
    });

    group('copyWith', () {
      test('should update sidebar_collapsed', () {
        // Arrange
        const original = UserProfileModel(
          id: 'uuid',
          nombreCompleto: 'Test User',
          email: 'test@example.com',
          rol: 'VENDEDOR',
          sidebarCollapsed: false,
        );

        // Act
        final copy = original.copyWith(sidebarCollapsed: true);

        // Assert
        expect(copy.id, 'uuid');
        expect(copy.nombreCompleto, 'Test User');
        expect(copy.sidebarCollapsed, true); // Changed
      });
    });
  });
}
