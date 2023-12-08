abstract class CarroEstado {
  get mensajeError => null;
}

class EstadoInicial extends CarroEstado {}

class CarroSeleccionadoEstado extends CarroEstado {
  final int idSeleccionado;

  CarroSeleccionadoEstado({required this.idSeleccionado});
}

class GetAllCarros extends CarroEstado {
  final List<Map<String, dynamic>> carros;
  final List<Map<String, dynamic>> carrosArchivados;

  GetAllCarros({required this.carros, required this.carrosArchivados});
}

class CarroInsertado extends CarroEstado {}

class CarroEliminado extends CarroEstado {}

class CarroActualizado extends CarroEstado {}

class CarroArchivado extends CarroEstado {}

class ErrorGetAllCarros extends CarroEstado {
  @override
  final String mensajeError;

  ErrorGetAllCarros({required this.mensajeError});
}

class ErrorGetAllCarrosDL extends CarroEstado {
  @override
  final String mensajeError;

  ErrorGetAllCarrosDL({required this.mensajeError});
}

class ErrorAlInsertarCarro extends CarroEstado {
  @override
  final String mensajeError;

  ErrorAlInsertarCarro({required this.mensajeError});
}

class ErrorAlEliminarCarro extends CarroEstado {
  @override
  final String mensajeError;

  ErrorAlEliminarCarro({required this.mensajeError});
}

class ErrorAlActualizarCarro extends CarroEstado {
  @override
  final String mensajeError;

  ErrorAlActualizarCarro({required this.mensajeError});
}

class ErrorAlArchivarCarro extends CarroEstado {
  @override
  final String mensajeError;

  ErrorAlArchivarCarro({required this.mensajeError});
}
