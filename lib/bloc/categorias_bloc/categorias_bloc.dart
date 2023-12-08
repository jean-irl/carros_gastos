import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carros_gastos/bloc/categorias_bloc/categorias_bloc_estado.dart';
import 'package:carros_gastos/bloc/categorias_bloc/categorias_bloc_eventos.dart';
import 'package:carros_gastos/database_helper/carros_database_helper.dart';

class CategoriaBloc extends Bloc<CategoriaEvento, CategoriaEstado> {
  final DBCarro dbCarro;
  late List<Map<String, dynamic>> allCategorias =
      []; // Lista de todas las categorias
  late List<Map<String, dynamic>> categoriasArchivadas =
      []; // Lista de categorias archivadas
  CategoriaBloc(this.dbCarro) : super(EstadoCategoriaInicial()) {
    on<CategoriaInicializada>((event, emit) {
      emit(EstadoCategoriaInicial());
    });

    on<CategoriaSeleccionada>((event, emit) {
      final int idSeleccionado = event.indiceSeleccionado;
      emit(CategoriaSeleccionadoEstado(idSeleccionado: idSeleccionado));
    });

    on<GetCategorias>((event, emit) async {
      try {
        final allCategorias = await dbCarro.getCategorias();
        final catetegoriasArchivadas = allCategorias
            .where((categoria) => categoria['archivado'] == 1)
            .toList();
        emit(GetAllCategorias(
            categorias: allCategorias,
            categoriasarchivadas: catetegoriasArchivadas));
      } catch (e) {
        emit(ErrorGetAllCategorias(
            mensajeError: 'Error al cargar todas las categorias: $e'));
      }
    });

    on<InsertarCategoria>((event, emit) async {
      try {
        await dbCarro.addCategoria(event.nombrecategoria);

        emit(CategoriaInsertada());
        add(GetCategorias());
      } catch (e) {
        emit(ErrorAlInsertarCategoria(
            mensajeError: 'Error al insertar la categoria.'));
      }
    });

    on<EliminarCategoria>((event, emit) {
      try {
        // Llama al método de la base de datos para eliminar el carro
        dbCarro.deleteCategoria(event.idcategoria);
        emit(CategoriaEliminada());
        add(GetCategorias());
      } catch (e) {
        emit(ErrorAlEliminarCategoria(
            mensajeError: 'Error al eliminar la categoria.'));
      }
    });

    on<UpdateCategoria>((event, emit) async {
      try {
        dbCarro.updateCategoria(event.nombrecategoria, event.idcategoria);

        emit(CategoriaActualizada());
        add(GetCategorias());
      } catch (e) {
        emit(ErrorAlActualizarCategoria(
            mensajeError: 'Error al insertar el carro.'));
      }
    });

    on<ArchivarCategoria>((event, emit) async {
      try {
        dbCarro.archivarCategoria(event.idcategoria);

        emit(CategoriaArchivada());
        add(GetCategorias());
      } catch (e) {
        emit(ErrorAlArchivarCategoria(
            mensajeError: 'Error al archivar categoria.'));
      }
    });
  }
}
