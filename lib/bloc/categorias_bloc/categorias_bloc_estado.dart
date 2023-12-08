abstract class CategoriaEstado {
  get mensajeError => null;
}

class EstadoCategoriaInicial extends CategoriaEstado {}

class CategoriaSeleccionadoEstado extends CategoriaEstado {
  final int idSeleccionado;

  CategoriaSeleccionadoEstado({required this.idSeleccionado});
}

class GetAllCategorias extends CategoriaEstado {
  final List<Map<String, dynamic>> categorias;
  final List<Map<String, dynamic>> categoriasarchivadas;

  GetAllCategorias(
      {required this.categorias, required this.categoriasarchivadas});
}

class CategoriaInsertada extends CategoriaEstado {}

class CategoriaEliminada extends CategoriaEstado {}

class CategoriaActualizada extends CategoriaEstado {}

class CategoriaArchivada extends CategoriaEstado {}

class ErrorGetAllCategorias extends CategoriaEstado {
  @override
  final String mensajeError;

  ErrorGetAllCategorias({required this.mensajeError});
}

class ErrorAlInsertarCategoria extends CategoriaEstado {
  @override
  final String mensajeError;

  ErrorAlInsertarCategoria({required this.mensajeError});
}

class ErrorAlEliminarCategoria extends CategoriaEstado {
  @override
  final String mensajeError;

  ErrorAlEliminarCategoria({required this.mensajeError});
}

class ErrorAlActualizarCategoria extends CategoriaEstado {
  @override
  final String mensajeError;

  ErrorAlActualizarCategoria({required this.mensajeError});
}

class ErrorAlArchivarCategoria extends CategoriaEstado {
  @override
  final String mensajeError;

  ErrorAlArchivarCategoria({required this.mensajeError});
}
