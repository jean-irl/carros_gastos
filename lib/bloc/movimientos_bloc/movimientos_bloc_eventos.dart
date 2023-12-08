abstract class MovimientoEvento {}

class MovimientoInicializado extends MovimientoEvento {}

class MovimientoSeleccionado extends MovimientoEvento {
  final int indiceSeleccionado;

  MovimientoSeleccionado({required this.indiceSeleccionado});
}

class GetMovimientos extends MovimientoEvento {}

class InsertarMovimiento extends MovimientoEvento {
  final String nombremovimiento;
  final int idcarro;
  final int idcategoria;
  final int gastototal;
  final String fechagasto;

  InsertarMovimiento({
    required this.nombremovimiento,
    required this.idcarro,
    required this.idcategoria,
    required this.gastototal,
    required this.fechagasto,
  });
}

class EliminarMovimiento extends MovimientoEvento {
  final int idmovimiento;

  EliminarMovimiento({required this.idmovimiento});
}

class UpdateMovimiento extends MovimientoEvento {
  final String nombremovimiento;
  final int idcarro;
  final int idcategoria;
  final int gastototal;
  final int idmovimiento;
  final String fechagasto;

  UpdateMovimiento({
    required this.nombremovimiento,
    required this.idcarro,
    required this.idcategoria,
    required this.gastototal,
    required this.idmovimiento,
    required this.fechagasto,
  });
}
