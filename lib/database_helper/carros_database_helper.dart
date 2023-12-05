import 'package:sqflite/sqflite.dart';
//Funcion para WEB
//import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

late Database db;

//SI SE QUIERE TRABAJAR CON WEB SOLO DESCOMENTAR EL IMPORT DE FFIWEB JUNTO CON SU DATABASEFACTORY
//Y COMENTAR EL DATABASEFACTORY QUE ES PARA ANDROID

class DBCarro {
  Future<void> initializeDatabase() async {
    //var fabricaBaseDatos = databaseFactoryFfiWeb; //Funcion para WEB
    var fabricaBaseDatos = databaseFactory; //Funcion para Android
    String rutaBaseDatos =
        '${await fabricaBaseDatos.getDatabasesPath()}/carrosDB.db';

    db = await fabricaBaseDatos.openDatabase(
      rutaBaseDatos,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute(
              'CREATE TABLE IF NOT EXISTS carros (idcarro INTEGER PRIMARY KEY AUTOINCREMENT, apodo TEXT(35) NOT NULL, archivado INT default 1)');

          await db.execute(
              'CREATE TABLE IF NOT EXISTS categorias (idcategoria INTEGER PRIMARY KEY AUTOINCREMENT, nombrecategoria TEXT(35) NOT NULL, archivado INT default 1)');

          await db.execute(
              'CREATE TABLE IF NOT EXISTS movimientos (idmovimiento INTEGER PRIMARY KEY AUTOINCREMENT, nombremovimiento TEXT NOT NULL, idcarro INT NOT NULL, idcategoria INT NOT NULL, gastototal INT NOT NULL, fechagasto TEXT(30) NOT NULL)');

          await db.execute(
              "INSERT INTO categorias (nombrecategoria) VALUES ('Gasolina'),('Mantenimiento'),('Limpieza')");
        },
      ),
    );
  }

//BD PARA CARROS

  Future<List<Map<String, dynamic>>> getCarros() async {
    var resultadoConsulta = await db.rawQuery(
        'SELECT carros.*, COALESCE(SUM(movimientos.gastototal), 0) AS totalgasto FROM carros LEFT JOIN movimientos ON carros.idcarro = movimientos.idcarro GROUP BY carros.idcarro ORDER BY archivado DESC;');
    return resultadoConsulta;
  }

  Future<void> addCarro(String apodo) async {
    await db.rawInsert('INSERT INTO carros (apodo) VALUES (?)', [apodo]);
  }

  Future<void> deleteCarro(int id) async {
    await db.rawDelete('DELETE FROM carros WHERE idcarro = ?', [id]);
  }

  Future<void> updateCarro(String apodo, int id) async {
    await db.rawUpdate(
        'UPDATE carros SET apodo = ? WHERE idcarro = ?', [apodo, id]);
  }

  Future<void> archivarCarro(int id) async {
    await db.rawUpdate(
        'UPDATE carros SET archivado = CASE WHEN archivado = 1 THEN 0 WHEN archivado = 0 THEN 1 ELSE archivado END WHERE idcarro = ?',
        [id]);
  }

//DB PARA CATEGORIAS
  Future<List<Map<String, dynamic>>> getCategorias() async {
    var resultadoConsulta = await db.rawQuery(
        'SELECT categorias.*, COALESCE(SUM(movimientos.gastototal), 0) AS totalgasto FROM categorias LEFT JOIN movimientos ON categorias.idcategoria = movimientos.idcategoria GROUP BY categorias.idcategoria ORDER BY archivado DESC;');
    return resultadoConsulta;
  }

  Future<void> addCategoria(String nombrecategoria) async {
    await db.rawInsert('INSERT INTO categorias (nombrecategoria) VALUES (?)',
        [nombrecategoria]);
  }

  Future<void> deleteCategoria(int id) async {
    await db.rawDelete('DELETE FROM categorias WHERE idcategoria = ?', [id]);
  }

  Future<void> updateCategoria(String nombrecategoria, int id) async {
    await db.rawUpdate(
        'UPDATE categorias SET nombrecategoria = ? WHERE idcategoria = ?',
        [nombrecategoria, id]);
  }

  Future<void> archivarCategoria(int id) async {
    await db.rawUpdate(
        'UPDATE categorias SET archivado = CASE WHEN archivado = 1 THEN 0 WHEN archivado = 0 THEN 1 ELSE archivado END WHERE idcategoria = ?',
        [id]);
  }

//DB PARA GASTOS
  Future<List<Map<String, dynamic>>> getMovimientos() async {
    var resultadoConsulta = await db.rawQuery(
        'SELECT * FROM movimientos INNER JOIN carros ON movimientos.idcarro = carros.idcarro INNER JOIN categorias ON movimientos.idcategoria = categorias.idcategoria;');
    return resultadoConsulta;
  }

  Future<void> addMovimiento(
    String nombremovimiento,
    int idcarro,
    int idcategoria,
    int gastototal,
    String fechagasto,
  ) async {
    try {
      await db.rawInsert(
        'INSERT INTO movimientos (nombremovimiento, idcarro, idcategoria, gastototal, fechagasto) VALUES (?, ?, ?, ?, ?)',
        [nombremovimiento, idcarro, idcategoria, gastototal, fechagasto],
      );
      print('Movimiento insertado correctamente');
    } catch (e) {
      print('Error al insertar el movimiento: $e');
      // Maneja el error de inserción aquí si es necesario
    }
  }

  Future<void> deleteMovimiento(int id) async {
    await db.rawDelete('DELETE FROM movimientos WHERE idmovimiento = ?', [id]);
  }

  Future<void> updateMovimiento(
      String nombremovimiento,
      int idcarro,
      int idcategoria,
      int gastototal,
      int idmovimiento,
      String fechagasto) async {
    await db.rawUpdate(
        'UPDATE movimientos SET nombremovimiento=?,idcarro=?,idcategoria=?,gastototal=?,fechagasto=? WHERE idmovimiento = ?',
        [
          nombremovimiento,
          idcarro,
          idcategoria,
          gastototal,
          fechagasto,
          idmovimiento,
        ]);
  }
}
