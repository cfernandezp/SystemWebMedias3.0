import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/sistemas_talla_repository.dart';
import 'sistemas_talla_event.dart';
import 'sistemas_talla_state.dart';

/// Bloc para gestión de Sistemas de Tallas
///
/// Implementa E002-HU-004 (Gestionar Sistemas de Tallas).
/// Maneja estados y eventos según Clean Architecture.
class SistemasTallaBloc extends Bloc<SistemasTallaEvent, SistemasTallaState> {
  final SistemasTallaRepository repository;

  SistemasTallaBloc({required this.repository}) : super(SistemasTallaInitial()) {
    on<LoadSistemasTallaEvent>(_onLoadSistemasTalla);
    on<CreateSistemaTallaEvent>(_onCreateSistemaTalla);
    on<UpdateSistemaTallaEvent>(_onUpdateSistemaTalla);
    on<LoadSistemaTallaValoresEvent>(_onLoadSistemaTallaValores);
    on<AddValorTallaEvent>(_onAddValorTalla);
    on<UpdateValorTallaEvent>(_onUpdateValorTalla);
    on<DeleteValorTallaEvent>(_onDeleteValorTalla);
    on<ToggleSistemaTallaActivoEvent>(_onToggleSistemaTallaActivo);
  }

  Future<void> _onLoadSistemasTalla(
    LoadSistemasTallaEvent event,
    Emitter<SistemasTallaState> emit,
  ) async {
    emit(SistemasTallaLoading());

    final result = await repository.getSistemasTalla(
      search: event.search,
      tipoFilter: event.tipoFilter,
      activoFilter: event.activoFilter,
    );

    result.fold(
      (failure) => emit(SistemasTallaError(failure.message)),
      (sistemas) => emit(SistemasTallaLoaded(sistemas)),
    );
  }

  Future<void> _onCreateSistemaTalla(
    CreateSistemaTallaEvent event,
    Emitter<SistemasTallaState> emit,
  ) async {
    emit(SistemasTallaLoading());

    final result = await repository.createSistemaTalla(event.request);

    result.fold(
      (failure) => emit(SistemasTallaError(failure.message)),
      (sistema) => emit(SistemaTallaCreated(sistema)),
    );
  }

  Future<void> _onUpdateSistemaTalla(
    UpdateSistemaTallaEvent event,
    Emitter<SistemasTallaState> emit,
  ) async {
    emit(SistemasTallaLoading());

    final result = await repository.updateSistemaTalla(event.request);

    result.fold(
      (failure) => emit(SistemasTallaError(failure.message)),
      (sistema) => emit(SistemaTallaUpdated(sistema)),
    );
  }

  Future<void> _onLoadSistemaTallaValores(
    LoadSistemaTallaValoresEvent event,
    Emitter<SistemasTallaState> emit,
  ) async {
    emit(SistemasTallaLoading());

    final result = await repository.getSistemaTallaValores(event.sistemaId);

    result.fold(
      (failure) => emit(SistemasTallaError(failure.message)),
      (data) => emit(SistemaTallaValoresLoaded(
        data['sistema'],
        data['valores'],
      )),
    );
  }

  Future<void> _onAddValorTalla(
    AddValorTallaEvent event,
    Emitter<SistemasTallaState> emit,
  ) async {
    emit(SistemasTallaLoading());

    final result = await repository.addValorTalla(
      event.sistemaId,
      event.valor,
      event.orden,
    );

    result.fold(
      (failure) => emit(SistemasTallaError(failure.message)),
      (valor) => emit(ValorTallaAdded(valor)),
    );
  }

  Future<void> _onUpdateValorTalla(
    UpdateValorTallaEvent event,
    Emitter<SistemasTallaState> emit,
  ) async {
    emit(SistemasTallaLoading());

    final result = await repository.updateValorTalla(
      event.valorId,
      event.valor,
      event.orden,
    );

    result.fold(
      (failure) => emit(SistemasTallaError(failure.message)),
      (valor) => emit(ValorTallaUpdated(valor)),
    );
  }

  Future<void> _onDeleteValorTalla(
    DeleteValorTallaEvent event,
    Emitter<SistemasTallaState> emit,
  ) async {
    emit(SistemasTallaLoading());

    final result = await repository.deleteValorTalla(
      event.valorId,
      event.force,
    );

    result.fold(
      (failure) => emit(SistemasTallaError(failure.message)),
      (_) => emit(ValorTallaDeleted()),
    );
  }

  Future<void> _onToggleSistemaTallaActivo(
    ToggleSistemaTallaActivoEvent event,
    Emitter<SistemasTallaState> emit,
  ) async {
    emit(SistemasTallaLoading());

    final result = await repository.toggleSistemaTallaActivo(event.id);

    result.fold(
      (failure) => emit(SistemasTallaError(failure.message)),
      (sistema) => emit(SistemaTallaToggled(sistema)),
    );
  }
}
