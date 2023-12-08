import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:carros_gastos/database_helper/carros_database_helper.dart';
import 'package:carros_gastos/bloc/carros_bloc/carros_bloc_event.dart';
import 'package:carros_gastos/bloc/carros_bloc/carros_bloc_state.dart';

class CarroBloc extends Bloc<CarroEvento, CarroEstado> {
  final DBCarro dbCarro;
  late List<Map<String, dynamic>> allCarros = []; // Lista de todos los carros
  late List<Map<String, dynamic>> carrosArchivados =
      []; // Lista de carros archivados

  CarroBloc(this.dbCarro) : super(EstadoInicial()) {
    on<Inicializado>((event, emit) {
      emit(EstadoInicial());
    });

//Carros
    on<CarroSeleccionado>((event, emit) {
      final int idSeleccionado = event.indiceSeleccionado;
      emit(CarroSeleccionadoEstado(idSeleccionado: idSeleccionado));
    });

    on<GetCarros>((event, emit) async {
      try {
        final allCarros = await dbCarro.getCarros();
        final carrosArchivados =
            allCarros.where((carro) => carro['archivado'] == 1).toList();
        emit(GetAllCarros(
            carros: allCarros, carrosArchivados: carrosArchivados));
      } catch (e) {
        emit(ErrorGetAllCarros(
            mensajeError: 'Error al cargar todos los carros: $e'));
      }
    });

    on<InsertarCarro>((event, emit) async {
      try {
        await dbCarro.addCarro(event.apodo);

        emit(CarroInsertado());
        add(GetCarros());
      } catch (e) {
        emit(ErrorAlInsertarCarro(mensajeError: 'Error al insertar el carro.'));
      }
    });

    on<EliminarCarro>((event, emit) {
      try {
        // Llama al método de la base de datos para eliminar el carro
        dbCarro.deleteCarro(event.idCarro);
        emit(CarroEliminado());
        add(GetCarros());
      } catch (e) {
        emit(ErrorAlEliminarCarro(mensajeError: 'Error al eliminar el carro.'));
      }
    });

    on<UpdateCarro>((event, emit) async {
      try {
        dbCarro.updateCarro(event.apodo, event.idcarro);

        emit(CarroActualizado());
        add(GetCarros());
      } catch (e) {
        emit(ErrorAlActualizarCarro(
            mensajeError: 'Error al insertar el carro.'));
      }
    });

    on<ArchivarCarro>((event, emit) async {
      try {
        dbCarro.archivarCarro(event.idcarro);

        emit(CarroArchivado());
        add(GetCarros());
      } catch (e) {
        emit(ErrorAlArchivarCarro(mensajeError: 'Error al insertar el carro.'));
      }
    });
  }
}
