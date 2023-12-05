abstract class CategoriaEvento {}

class CategoriaInicializada extends CategoriaEvento {}

class CategoriaSeleccionada extends CategoriaEvento {
  final int indiceSeleccionado;

  CategoriaSeleccionada({required this.indiceSeleccionado});
}

class GetCategorias extends CategoriaEvento {}

class InsertarCategoria extends CategoriaEvento {
  final String nombrecategoria;

  InsertarCategoria({required this.nombrecategoria});
}

class EliminarCategoria extends CategoriaEvento {
  final int idcategoria;

  EliminarCategoria({required this.idcategoria});
}

class UpdateCategoria extends CategoriaEvento {
  final String nombrecategoria;
  final int idcategoria;

  UpdateCategoria({required this.nombrecategoria, required this.idcategoria});
}

class ArchivarCategoria extends CategoriaEvento {
  final int idcategoria;

  ArchivarCategoria({required this.idcategoria});
}
