import 'package:bloc/bloc.dart';
import 'package:carros_gastos/bloc/carros_bloc/carros_bloc.dart';
import 'package:carros_gastos/bloc/carros_bloc/carros_bloc_event.dart';
import 'package:carros_gastos/bloc/categorias_bloc/categorias_bloc.dart';
import 'package:carros_gastos/bloc/categorias_bloc/categorias_bloc_eventos.dart';
import 'package:carros_gastos/bloc/movimientos_bloc/movimientos_bloc_estado.dart';
import 'package:carros_gastos/bloc/movimientos_bloc/movimientos_bloc_eventos.dart';
import 'package:carros_gastos/database_helper/carros_database_helper.dart';

class MovimientoBloc extends Bloc<MovimientoEvento, MovimientoEstado> {
  final CategoriaBloc categoriaBloc;
  final CarroBloc carroBloc;
  final DBCarro dbCarro;
  MovimientoBloc(this.dbCarro, this.categoriaBloc, this.carroBloc)
      : super(EstadoMovimientoInicial()) {
    on<MovimientoInicializado>((event, emit) {
      emit(EstadoMovimientoInicial());
    });

    on<MovimientoSeleccionado>((event, emit) {
      final int idSeleccionado = event.indiceSeleccionado;
      emit(MovimientoSeleccionadoEstado(idSeleccionado: idSeleccionado));
    });

    on<GetMovimientos>((event, emit) async {
      try {
        final movimientos = await dbCarro.getMovimientos();
        emit(GetAllMovimientos(movimientos: movimientos));
      } catch (e) {
        emit(ErrorGetAllMovimientos(
            mensajeError: 'Error al cargar todas las movimientos: $e'));
      }
    });

    on<InsertarMovimiento>((event, emit) async {
      try {
        await dbCarro.addMovimiento(
          event.nombremovimiento,
          event.idcarro,
          event.idcategoria,
          event.gastototal,
          event.fechagasto,
        );

        emit(MovimientoInsertado());
        add(GetMovimientos());
        carroBloc.add(GetCarros());
        categoriaBloc.add(GetCategorias());
      } catch (e) {
        emit(ErrorAlInsertarMovimiento(
            mensajeError: 'Error al insertar el movimiento.'));
      }
    });

    on<EliminarMovimiento>((event, emit) {
      try {
        dbCarro.deleteMovimiento(event.idmovimiento);
        emit(MovimientoEliminado());
        add(GetMovimientos());

        carroBloc.add(GetCarros());
        categoriaBloc.add(GetCategorias());
      } catch (e) {
        emit(ErrorAlEliminarMovimiento(
            mensajeError: 'Error al eliminar el movimiento.'));
      }
    });

    on<UpdateMovimiento>((event, emit) async {
      try {
        dbCarro.updateMovimiento(
          event.nombremovimiento,
          event.idcarro,
          event.idcategoria,
          event.gastototal,
          event.idmovimiento,
          event.fechagasto,
        );

        emit(MovimientoActualizado());
        add(GetMovimientos());

        carroBloc.add(GetCarros());
        categoriaBloc.add(GetCategorias());
      } catch (e) {
        emit(ErrorAlActualizarMovimiento(
            mensajeError: 'Error al insertar el carro.'));
      }
    });
  }
}
