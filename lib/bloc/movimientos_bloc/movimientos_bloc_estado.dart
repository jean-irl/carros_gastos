abstract class MovimientoEstado {
  get mensajeError => null;
}

class EstadoMovimientoInicial extends MovimientoEstado {}

class MovimientoSeleccionadoEstado extends MovimientoEstado {
  final int idSeleccionado;

  MovimientoSeleccionadoEstado({required this.idSeleccionado});
}

class GetAllMovimientos extends MovimientoEstado {
  final List<Map<String, dynamic>> movimientos;

  GetAllMovimientos({required this.movimientos});
}

class MovimientoInsertado extends MovimientoEstado {}

class MovimientoEliminado extends MovimientoEstado {}

class MovimientoActualizado extends MovimientoEstado {}

class ErrorGetAllMovimientos extends MovimientoEstado {
  @override
  final String mensajeError;

  ErrorGetAllMovimientos({required this.mensajeError});
}

class ErrorGetAllCarrosCategoriasList extends MovimientoEstado {
  @override
  final String mensajeError;

  ErrorGetAllCarrosCategoriasList({required this.mensajeError});
}

class ErrorAlInsertarMovimiento extends MovimientoEstado {
  @override
  final String mensajeError;

  ErrorAlInsertarMovimiento({required this.mensajeError});
}

class ErrorAlEliminarMovimiento extends MovimientoEstado {
  @override
  final String mensajeError;

  ErrorAlEliminarMovimiento({required this.mensajeError});
}

class ErrorAlActualizarMovimiento extends MovimientoEstado {
  @override
  final String mensajeError;

  ErrorAlActualizarMovimiento({required this.mensajeError});
}
