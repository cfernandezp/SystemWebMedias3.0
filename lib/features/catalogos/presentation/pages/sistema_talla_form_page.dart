import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/injection/injection_container.dart';
import '../../../../shared/design_system/atoms/corporate_button.dart';
import '../../../../shared/design_system/atoms/corporate_form_field.dart';
import '../widgets/valor_rango_input.dart';
import '../widgets/valor_letras_input.dart';
import '../widgets/valor_talla_delete_confirm_dialog.dart';
import '../bloc/sistemas_talla/sistemas_talla_bloc.dart';
import '../bloc/sistemas_talla/sistemas_talla_event.dart';
import '../bloc/sistemas_talla/sistemas_talla_state.dart';
import '../../data/models/create_sistema_talla_request.dart';
import '../../data/models/update_sistema_talla_request.dart';

/// Página de formulario para crear/editar sistema de tallas (CA-002, CA-003, CA-006, CA-007, CA-008)
///
/// Criterios de Aceptación:
/// - CA-002: Agregar nuevo sistema de tallas
/// - CA-003: Configurar valores por tipo de sistema
/// - CA-006: Editar sistema existente
/// - CA-007: Gestión de valores en edición (agregar, modificar, eliminar)
/// - CA-008: Validación de eliminación de valores
class SistemaTallaFormPage extends StatelessWidget {
  final Map<String, dynamic>? sistema;

  const SistemaTallaFormPage({
    Key? key,
    this.sistema,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SistemasTallaBloc>(),
      child: _SistemaTallaFormPageContent(sistema: sistema),
    );
  }
}

class _SistemaTallaFormPageContent extends StatefulWidget {
  final Map<String, dynamic>? sistema;

  const _SistemaTallaFormPageContent({
    Key? key,
    this.sistema,
  }) : super(key: key);

  @override
  State<_SistemaTallaFormPageContent> createState() => _SistemaTallaFormPageContentState();
}

class _SistemaTallaFormPageContentState extends State<_SistemaTallaFormPageContent> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();

  String _tipoSistema = 'NUMERO';
  bool _activo = true;
  bool _isEditMode = false;
  bool _isLoading = false;

  final List<TextEditingController> _valoresControllers = [];
  final Map<TextEditingController, String> _valoresIds = {}; // controller -> valor_id

  @override
  void initState() {
    super.initState();

    if (widget.sistema != null) {
      _isEditMode = true;
      _nombreController.text = widget.sistema!['nombre']?.toString() ?? '';
      final descripcion = widget.sistema!['descripcion'];
      _descripcionController.text = descripcion != null ? descripcion.toString() : '';
      _tipoSistema = widget.sistema!['tipo_sistema']?.toString() ?? 'NUMERO';
      _activo = widget.sistema!['activo'] as bool? ?? true;

      // Cargar valores existentes en modo edición
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadExistingValores();
      });
    } else {
      _addValorField();
    }
  }

  /// Carga valores existentes del sistema desde el backend (CA-007)
  void _loadExistingValores() {
    if (widget.sistema != null && widget.sistema!['id'] != null) {
      context.read<SistemasTallaBloc>().add(
            LoadSistemaTallaValoresEvent(widget.sistema!['id']),
          );
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    for (var controller in _valoresControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addValorField() {
    if (!_isEditMode) {
      // Modo crear: solo agregar controller
      setState(() {
        _valoresControllers.add(TextEditingController());
      });
    } else {
      // Modo editar: mostrar diálogo para agregar valor
      _showAddValorDialog();
    }
  }

  /// Muestra diálogo para agregar nuevo valor en modo edición (CA-007)
  void _showAddValorDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Agregar Valor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_tipoSistema == 'NUMERO' || _tipoSistema == 'RANGO')
              ValorRangoInput(controller: controller)
            else if (_tipoSistema == 'LETRA')
              ValorLetrasInput(controller: controller),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.dispose();
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final valor = controller.text.trim();
              if (valor.isNotEmpty) {
                Navigator.pop(context);
                _handleAddValor(valor);
              }
              controller.dispose();
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  /// Handler para agregar valor (CA-007)
  void _handleAddValor(String valor) {
    if (widget.sistema == null || widget.sistema!['id'] == null) return;

    setState(() {
      _isLoading = true;
    });

    context.read<SistemasTallaBloc>().add(
          AddValorTallaEvent(
            sistemaId: widget.sistema!['id'],
            valor: valor,
            orden: _valoresControllers.length + 1,
          ),
        );
  }

  void _removeValorField(TextEditingController controller) {
    if (!_isEditMode) {
      // Modo crear: solo eliminar controller
      setState(() {
        _valoresControllers.remove(controller);
        controller.dispose();
      });
    } else {
      // Modo editar: mostrar confirmación antes de eliminar
      _handleDeleteValor(controller);
    }
  }

  /// Handler para eliminar valor con confirmación (CA-007, CA-008)
  void _handleDeleteValor(TextEditingController controller) {
    final valorId = _valoresIds[controller];
    if (valorId == null) return;

    // Verificar que no sea el último valor
    if (_valoresControllers.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se puede eliminar el último valor del sistema'),
          backgroundColor: Color(0xFFF44336),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => ValorTallaDeleteConfirmDialog(
        valor: controller.text,
        productosCount: 0, // Placeholder hasta HU productos
        onConfirm: () {
          Navigator.pop(context);
          _deleteValor(valorId, controller);
        },
      ),
    );
  }

  /// Elimina valor del backend (CA-008)
  void _deleteValor(String valorId, TextEditingController controller) {
    setState(() {
      _isLoading = true;
    });

    context.read<SistemasTallaBloc>().add(
          DeleteValorTallaEvent(
            valorId: valorId,
            force: false,
          ),
        );
  }

  /// Handler para actualizar valor en línea (CA-007)
  void _handleUpdateValor(TextEditingController controller) {
    final valorId = _valoresIds[controller];
    if (valorId == null) return;

    final newValor = controller.text.trim();
    if (newValor.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El valor no puede estar vacío'),
          backgroundColor: Color(0xFFF44336),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    context.read<SistemasTallaBloc>().add(
          UpdateValorTallaEvent(
            valorId: valorId,
            valor: newValor,
            orden: null, // Mantener orden actual
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return BlocListener<SistemasTallaBloc, SistemasTallaState>(
      listener: (context, state) {
        setState(() {
          _isLoading = false;
        });

        if (state is SistemaTallaValoresLoaded) {
          // Cargar valores en controllers
          setState(() {
            _valoresControllers.clear();
            _valoresIds.clear();
            for (var valor in state.valores) {
              final controller = TextEditingController(text: valor.valor);
              _valoresControllers.add(controller);
              _valoresIds[controller] = valor.id;
            }
          });
        }

        if (state is ValorTallaAdded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Valor agregado exitosamente'),
                ],
              ),
              backgroundColor: Color(0xFF4CAF50),
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Recargar valores
          _loadExistingValores();
        }

        if (state is ValorTallaUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Valor actualizado exitosamente'),
                ],
              ),
              backgroundColor: Color(0xFF4CAF50),
              behavior: SnackBarBehavior.floating,
            ),
          );
          _loadExistingValores();
        }

        if (state is ValorTallaDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Valor eliminado exitosamente'),
                ],
              ),
              backgroundColor: Color(0xFF4CAF50),
              behavior: SnackBarBehavior.floating,
            ),
          );
          _loadExistingValores();
        }

        if (state is SistemaTallaCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Sistema creado exitosamente'),
                ],
              ),
              backgroundColor: Color(0xFF4CAF50),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.pop();
        }

        if (state is SistemaTallaUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Sistema actualizado exitosamente'),
                ],
              ),
              backgroundColor: Color(0xFF4CAF50),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.pop();
        }

        if (state is SistemasTallaError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: const Color(0xFFF44336),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(_isEditMode ? 'Editar Sistema de Tallas' : 'Nuevo Sistema de Tallas'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CorporateFormField(
                        controller: _nombreController,
                        label: 'Nombre del Sistema',
                        hintText: 'Ej: Tallas Numéricas Europeas',
                        prefixIcon: Icons.straighten,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nombre es requerido';
                          }
                          if (value.length > 50) {
                            return 'Máximo 50 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      CorporateFormField(
                        controller: _descripcionController,
                        label: 'Descripción (opcional)',
                        hintText: 'Describe el sistema de tallas',
                        prefixIcon: Icons.description,
                        maxLines: 3,
                        validator: (value) {
                          if (value != null && value.length > 200) {
                            return 'Máximo 200 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        initialValue: _tipoSistema,
                        decoration: InputDecoration(
                          labelText: 'Tipo de Sistema',
                          filled: true,
                          fillColor: _isEditMode
                              ? const Color(0xFFF3F4F6)
                              : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          prefixIcon: const Icon(Icons.category),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'UNICA', child: Text('ÚNICA - Talla única')),
                          DropdownMenuItem(value: 'NUMERO', child: Text('NÚMERO - Rangos numéricos')),
                          DropdownMenuItem(value: 'LETRA', child: Text('LETRA - Tallas alfabéticas')),
                          DropdownMenuItem(value: 'RANGO', child: Text('RANGO - Rangos amplios')),
                        ],
                        onChanged: _isEditMode
                            ? null
                            : (value) {
                                setState(() {
                                  _tipoSistema = value!;
                                  _valoresControllers.clear();
                                  if (_tipoSistema != 'UNICA') {
                                    _addValorField();
                                  }
                                });
                              },
                      ),
                      if (_isEditMode)
                        const Padding(
                          padding: EdgeInsets.only(top: 8, left: 16),
                          child: Text(
                            'El tipo de sistema no se puede modificar',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFF59E0B),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),

                      SwitchListTile(
                        title: const Text('Sistema Activo'),
                        subtitle: const Text('Los sistemas inactivos no aparecen en selecciones'),
                        value: _activo,
                        activeTrackColor: theme.colorScheme.primary,
                        onChanged: (value) {
                          setState(() {
                            _activo = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      _buildValoresSection(),

                      const SizedBox(height: 32),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CorporateButton(
                            text: 'Cancelar',
                            variant: ButtonVariant.secondary,
                            onPressed: () => context.pop(),
                          ),
                          const SizedBox(width: 16),
                          CorporateButton(
                            text: _isEditMode ? 'Actualizar' : 'Guardar',
                            isLoading: _isLoading,
                            onPressed: _handleSubmit,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildValoresSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Valores del Sistema',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),

        if (_tipoSistema == 'UNICA') ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Este sistema usa talla única automáticamente. No es necesario configurar valores.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else if (_tipoSistema == 'NUMERO' || _tipoSistema == 'RANGO') ...[
          const Text(
            'Rangos Numéricos (formato: N-M)',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 12),
          ..._valoresControllers.asMap().entries.map((entry) {
            final controller = entry.value;
            final hasId = _valoresIds.containsKey(controller);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: ValorRangoInput(
                      controller: controller,
                      onDelete: _valoresControllers.length > 1
                          ? () => _removeValorField(controller)
                          : null,
                    ),
                  ),
                  if (_isEditMode && hasId) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.save, color: Color(0xFF4ECDC4)),
                      onPressed: () => _handleUpdateValor(controller),
                      tooltip: 'Guardar cambio',
                    ),
                  ],
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _isLoading ? null : _addValorField,
            icon: const Icon(Icons.add),
            label: Text(_isEditMode ? 'Agregar Rango Nuevo' : 'Agregar Rango'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ] else if (_tipoSistema == 'LETRA') ...[
          const Text(
            'Tallas Alfabéticas',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 12),
          ..._valoresControllers.asMap().entries.map((entry) {
            final controller = entry.value;
            final hasId = _valoresIds.containsKey(controller);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: ValorLetrasInput(
                      controller: controller,
                      onDelete: _valoresControllers.length > 1
                          ? () => _removeValorField(controller)
                          : null,
                    ),
                  ),
                  if (_isEditMode && hasId) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.save, color: Color(0xFF4ECDC4)),
                      onPressed: () => _handleUpdateValor(controller),
                      tooltip: 'Guardar cambio',
                    ),
                  ],
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _isLoading ? null : _addValorField,
            icon: const Icon(Icons.add),
            label: Text(_isEditMode ? 'Agregar Talla Nueva' : 'Agregar Talla'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ],
    );
  }

  void _handleSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Validar valores para tipos no-UNICA
    if (_tipoSistema != 'UNICA' && _valoresControllers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Text('Debe agregar al menos un valor al sistema'),
            ],
          ),
          backgroundColor: Color(0xFFF44336),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Preparar valores solo en modo creación
    List<String>? valores;
    if (!_isEditMode && _tipoSistema != 'UNICA') {
      valores = _valoresControllers
          .map((c) => c.text.trim())
          .where((v) => v.isNotEmpty)
          .toList();

      if (valores.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 12),
                Text('Los valores no pueden estar vacíos'),
              ],
            ),
            backgroundColor: Color(0xFFF44336),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    if (_isEditMode) {
      // Modo edición: solo actualizar sistema (valores se gestionan por separado)
      context.read<SistemasTallaBloc>().add(
            UpdateSistemaTallaEvent(
              UpdateSistemaTallaRequest(
                id: widget.sistema!['id'],
                nombre: _nombreController.text.trim(),
                descripcion: _descripcionController.text.trim().isEmpty
                    ? null
                    : _descripcionController.text.trim(),
                activo: _activo,
              ),
            ),
          );
    } else {
      // Modo creación: crear sistema con valores
      context.read<SistemasTallaBloc>().add(
            CreateSistemaTallaEvent(
              CreateSistemaTallaRequest(
                nombre: _nombreController.text.trim(),
                tipoSistema: _tipoSistema,
                descripcion: _descripcionController.text.trim().isEmpty
                    ? null
                    : _descripcionController.text.trim(),
                valores: valores ?? [],
                activo: _activo,
              ),
            ),
          );
    }
  }
}
