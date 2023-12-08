import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

//Carros
import 'package:carros_gastos/bloc/carros_bloc/carros_bloc.dart';
import 'package:carros_gastos/bloc/carros_bloc/carros_bloc_event.dart';
import 'package:carros_gastos/bloc/carros_bloc/carros_bloc_state.dart';
//Categorias
import 'package:carros_gastos/bloc/categorias_bloc/categorias_bloc.dart';
import 'package:carros_gastos/bloc/categorias_bloc/categorias_bloc_estado.dart';
import 'package:carros_gastos/bloc/categorias_bloc/categorias_bloc_eventos.dart';
//Movimientos
import 'package:carros_gastos/bloc/movimientos_bloc/movimientos_bloc.dart';
import 'package:carros_gastos/bloc/movimientos_bloc/movimientos_bloc_estado.dart';
import 'package:carros_gastos/bloc/movimientos_bloc/movimientos_bloc_eventos.dart';
//DB
import 'package:carros_gastos/database_helper/carros_database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final carrosDatabase = DBCarro();
  await carrosDatabase.initializeDatabase();
  final categoriaBlocInstance = CategoriaBloc(carrosDatabase);
  final carroBlocInstance = CarroBloc(carrosDatabase);
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<CarroBloc>(
          create: (context) => carroBlocInstance,
        ),
        BlocProvider<CategoriaBloc>(
          create: (context) => categoriaBlocInstance,
        ),
        BlocProvider<MovimientoBloc>(
          create: (context) => MovimientoBloc(
              carrosDatabase, categoriaBlocInstance, carroBlocInstance),
        ),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: MainApp()),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    //CARROS
    BlocProvider.of<CarroBloc>(context).add(Inicializado());
    BlocProvider.of<CarroBloc>(context).add(GetCarros());
    //CATEGORIAS
    BlocProvider.of<CategoriaBloc>(context).add(CategoriaInicializada());
    BlocProvider.of<CategoriaBloc>(context).add(GetCategorias());
    //MOVIMIENTOS
    BlocProvider.of<MovimientoBloc>(context).add(MovimientoInicializado());
    BlocProvider.of<MovimientoBloc>(context).add(GetMovimientos());
  }

  int _indiceSeleccionado = 0;

  final List<Widget> _paginas = [
    const ListaCarros(),
    const ListaCategorias(),
    const ListaMovimientos(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
            child: Text(
          'Control de Gastos Vehicular',
          style: TextStyle(color: Color.fromRGBO(250, 240, 228, 1)),
        )),
        backgroundColor: const Color.fromRGBO(28, 29, 50, 1),
        actions: const [],
      ),
      body: BlocBuilder<CarroBloc, CarroEstado>(
        builder: (context, state) {
          return _paginas[_indiceSeleccionado];
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.car_crash_outlined),
            label: 'Carros',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categorias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments_outlined),
            label: 'Gastos',
          )
        ],
        currentIndex: _indiceSeleccionado,
        onTap: _onTabTapped,
        backgroundColor: const Color.fromRGBO(28, 29, 50, 1),
        selectedItemColor: const Color.fromRGBO(243, 210, 50, 1),
        unselectedItemColor: const Color.fromRGBO(250, 240, 228, 1),
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _indiceSeleccionado = index;
    });
  }
}

class ListaCarros extends StatefulWidget {
  const ListaCarros({super.key});

  @override
  State<ListaCarros> createState() => _ListaCarrosState();
}

class _ListaCarrosState extends State<ListaCarros> {
  TextEditingController barraBusqueda = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<CarroBloc, CarroEstado>(
        builder: (context, state) {
          if (state is GetAllCarros) {
            List<Map<String, dynamic>> carrosFiltrados = state.carros
                .where((carro) => carro['apodo']!
                    .toLowerCase()
                    .contains(barraBusqueda.text.toLowerCase()))
                .toList();
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: barraBusqueda,
                    decoration: InputDecoration(
                      labelText: 'Buscar',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color.fromRGBO(250, 240, 228, 1)),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color.fromRGBO(250, 240, 228, 1)),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color.fromRGBO(250, 240, 228, 1)),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                Expanded(
                  child: _listaCarros(carrosFiltrados),
                ),
              ],
            );
          } else if (state is ErrorGetAllCarros) {
            return Center(child: Text('Error: ${state.mensajeError}'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mostrarModal(context, 'Nuevo Carro');
        },
        backgroundColor: const Color.fromRGBO(28, 29, 50, 1),
        child: const Icon(
          Icons.add,
          color: Color.fromRGBO(250, 240, 228, 1),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _listaCarros(List<Map<String, dynamic>>? carros) {
    if (carros != null && carros.isNotEmpty) {
      return ListView.builder(
        itemCount: carros.length,
        itemBuilder: (context, index) {
          final carro = carros[index];
          int carroID = carros[index]['idcarro'];
          int archivado = carros[index]['archivado'];
          int totalGasto = carro['totalgasto'] ?? 0;

          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0)),
              textColor: const Color.fromRGBO(250, 240, 228, 1),
              title: Text(carro['apodo'] ?? 'No Apodo'),
              subtitle: Text('Gasto Total: $totalGasto'),
              tileColor: archivado == 1
                  ? const Color.fromRGBO(28, 29, 50, 1)
                  : Colors.red,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      archivado == 1
                          ? _mostrarModalEditar(context, carro)
                          : null;
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color.fromRGBO(28, 29, 50, 1),
                      backgroundColor: const Color.fromRGBO(
                          250, 240, 228, 1), // Color del ícono
                    ),
                    child: const Icon(Icons.edit),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Center(
                              child: archivado == 1
                                  ? const Text('¿Archivar Carro?')
                                  : const Text('¿Volver a activar?'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () {
                                  context
                                      .read<CarroBloc>()
                                      .add(ArchivarCarro(idcarro: carroID));
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Archivar'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        foregroundColor: const Color.fromRGBO(28, 29, 50, 1),
                        backgroundColor: const Color.fromRGBO(
                            250, 240, 228, 1) // Color del ícono
                        ),
                    child: const Icon(Icons.archive),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      return const Center(child: Text('No hay carros disponibles'));
    }
  }

  void _mostrarModal(BuildContext context, String carros) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return const FractionallySizedBox(
          heightFactor: 1.2,
          child: AgregarCarro(),
        );
      },
    );
  }
}

class AgregarCarro extends StatefulWidget {
  const AgregarCarro({super.key});

  @override
  State<AgregarCarro> createState() => _AgregarCarroState();
}

class _AgregarCarroState extends State<AgregarCarro> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController apodoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CarroBloc, CarroEstado>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Nuevo Carro',
              style: TextStyle(color: Color.fromRGBO(250, 240, 228, 1)),
            ),
            backgroundColor: const Color.fromRGBO(28, 29, 50, 1),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: apodoController,
                      decoration: InputDecoration(
                        labelText: 'Apodo',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese un apodo';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10.0),
                    ElevatedButton(
                      onPressed: () {
                        _insertarCarro(context);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(28, 29, 50, 1),
                      ),
                      child: const Text(
                        'Insertar Carro',
                        style:
                            TextStyle(color: Color.fromRGBO(250, 240, 228, 1)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _insertarCarro(BuildContext context) {
    final miBloc = BlocProvider.of<CarroBloc>(context);

    if (_formKey.currentState?.validate() ?? false) {
      miBloc.add(
        InsertarCarro(
          apodo: apodoController.text,
        ),
      );
    }
  }
}

// Agrega un nuevo método para mostrar el modal de edición
void _mostrarModalEditar(BuildContext context, Map<String, dynamic> carro) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return FractionallySizedBox(
        heightFactor: 1.2,
        child: EditarCarro(carro: carro),
      );
    },
  );
}

// Crea un nuevo widget para la edición del carro
class EditarCarro extends StatefulWidget {
  final Map<String, dynamic> carro;

  const EditarCarro({super.key, required this.carro});

  @override
  State<EditarCarro> createState() => _EditarCarroState();
}

class _EditarCarroState extends State<EditarCarro> {
  late TextEditingController apodoController;

  @override
  void initState() {
    super.initState();
    apodoController = TextEditingController(text: widget.carro['apodo']);
    // Agrega inicializaciones de otros campos si es necesario
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar Carro',
          style: TextStyle(color: Color.fromRGBO(250, 240, 228, 1)),
        ),
        backgroundColor: const Color.fromRGBO(
            28, 29, 50, 1), // Color para identificar la edición
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: apodoController,
                decoration: InputDecoration(
                  labelText: 'Apodo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese un apodo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () {
                  _actualizarCarro(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(28, 29, 50, 1),
                ),
                child: const Text(
                  'Actualizar Carro',
                  style: TextStyle(color: Color.fromRGBO(250, 240, 228, 1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _actualizarCarro(BuildContext context) {
    final miBloc = BlocProvider.of<CarroBloc>(context);

    if (apodoController.text.isNotEmpty) {
      miBloc.add(
        UpdateCarro(
          apodo: apodoController.text,
          idcarro: widget.carro['idcarro'],
        ),
      );
      Navigator.of(context)
          .pop(); // Cierra el modal después de la actualización
    }
  }
}

class ListaCategorias extends StatefulWidget {
  const ListaCategorias({super.key});

  @override
  State<ListaCategorias> createState() => _ListaCategoriasState();
}

class _ListaCategoriasState extends State<ListaCategorias> {
  TextEditingController barraBusqueda = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<CategoriaBloc, CategoriaEstado>(
        builder: (context, state) {
          if (state is GetAllCategorias) {
            List<Map<String, dynamic>> categoriasFiltradas = state.categorias
                .where((categoria) => categoria['nombrecategoria']!
                    .toLowerCase()
                    .contains(barraBusqueda.text.toLowerCase()))
                .toList();
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: barraBusqueda,
                    decoration: InputDecoration(
                      labelText: 'Buscar',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color.fromRGBO(250, 240, 228, 1)),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color.fromRGBO(250, 240, 228, 1)),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color.fromRGBO(250, 240, 228, 1)),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                Expanded(
                  child: _listaCategorias(categoriasFiltradas),
                ),
              ],
            );
          } else if (state is ErrorGetAllCategorias) {
            return Center(child: Text('Error: ${state.mensajeError}'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mostrarModal(context, 'Nueva Categoria');
        },
        backgroundColor: const Color.fromRGBO(28, 29, 50, 1),
        child: const Icon(
          Icons.add,
          color: Color.fromRGBO(250, 240, 228, 1),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _listaCategorias(List<Map<String, dynamic>>? categorias) {
    if (categorias != null && categorias.isNotEmpty) {
      return ListView.builder(
        itemCount: categorias.length,
        itemBuilder: (context, index) {
          final categoria = categorias[index];
          int categoriaID = categorias[index]['idcategoria'];
          int archivado = categorias[index]['archivado'];
          int totalGasto = categoria['totalgasto'] ?? 0;
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0)),
              title: Text(categoria['nombrecategoria'] ?? 'No hay nombre'),
              subtitle: Text('Gasto Total: $totalGasto'),
              textColor: const Color.fromRGBO(250, 240, 228, 1),
              tileColor: archivado == 1
                  ? const Color.fromRGBO(28, 29, 50, 1)
                  : Colors.red,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      archivado == 1
                          ? _mostrarModalEditarCategoria(context, categoria)
                          : null;
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color.fromRGBO(28, 29, 50, 1),
                      backgroundColor: const Color.fromRGBO(
                          250, 240, 228, 1), // Color del ícono
                    ),
                    child: const Icon(Icons.edit),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Center(
                              child: archivado == 1
                                  ? const Text('¿Archivar Categoria?')
                                  : const Text('¿Volver a activar?'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.read<CategoriaBloc>().add(
                                      ArchivarCategoria(
                                          idcategoria: categoriaID));
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Archivar'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color.fromRGBO(28, 29, 50, 1),
                      backgroundColor: const Color.fromRGBO(
                          250, 240, 228, 1), // Color del ícono
                    ),
                    child: const Icon(Icons.archive),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      return const Center(child: Text('No hay categorias disponibles'));
    }
  }

  void _mostrarModal(BuildContext context, String categorias) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return const FractionallySizedBox(
          heightFactor: 1.2,
          child: AgregarCategoria(),
        );
      },
    );
  }
}

class AgregarCategoria extends StatefulWidget {
  const AgregarCategoria({super.key});

  @override
  State<AgregarCategoria> createState() => _AgregarCategoriaState();
}

class _AgregarCategoriaState extends State<AgregarCategoria> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nombreController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriaBloc, CategoriaEstado>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Nueva Categoria',
              style: TextStyle(color: Color.fromRGBO(250, 240, 228, 1)),
            ),
            backgroundColor: const Color.fromRGBO(28, 29, 50, 1),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: nombreController,
                      decoration: InputDecoration(
                        labelText: 'Nombre Categoria',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese un nombre para la categoria';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10.0),
                    ElevatedButton(
                      onPressed: () {
                        _insertarCategoria(context);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(28, 29, 50, 1),
                      ),
                      child: const Text(
                        'Insertar Categoria',
                        style:
                            TextStyle(color: Color.fromRGBO(250, 240, 228, 1)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _insertarCategoria(BuildContext context) {
    final miBloc = BlocProvider.of<CategoriaBloc>(context);

    if (_formKey.currentState?.validate() ?? false) {
      miBloc.add(
        InsertarCategoria(
          nombrecategoria: nombreController.text,
        ),
      );
    }
  }
}

// Agrega un nuevo método para mostrar el modal de edición
void _mostrarModalEditarCategoria(
    BuildContext context, Map<String, dynamic> categoria) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return FractionallySizedBox(
        heightFactor: 1.2,
        child: EditarCategoria(categoria: categoria),
      );
    },
  );
}

// Crea un nuevo widget para la edición de la categoria
class EditarCategoria extends StatefulWidget {
  final Map<String, dynamic> categoria;

  const EditarCategoria({super.key, required this.categoria});

  @override
  State<EditarCategoria> createState() => _EditarCategoriaState();
}

class _EditarCategoriaState extends State<EditarCategoria> {
  late TextEditingController nombreController;

  @override
  void initState() {
    super.initState();
    nombreController =
        TextEditingController(text: widget.categoria['nombrecategoria']);
    // Agrega inicializaciones de otros campos si es necesario
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar Categoria',
          style: TextStyle(color: Color.fromRGBO(250, 240, 228, 1)),
        ),
        backgroundColor: const Color.fromRGBO(
            28, 29, 50, 1), // Color para identificar la edición
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: nombreController,
                decoration: InputDecoration(
                  labelText: 'Apodo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese un nombre de categoria';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () {
                  _actualizarCategoria(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(28, 29, 50, 1),
                ),
                child: const Text(
                  'Actualizar Categoria',
                  style: TextStyle(color: Color.fromRGBO(250, 240, 228, 1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _actualizarCategoria(BuildContext context) {
    final miBloc = BlocProvider.of<CategoriaBloc>(context);

    if (nombreController.text.isNotEmpty) {
      miBloc.add(
        UpdateCategoria(
          nombrecategoria: nombreController.text,
          idcategoria: widget.categoria['idcategoria'],
        ),
      );
      Navigator.of(context)
          .pop(); // Cierra el modal después de la actualización
    }
  }
}

class ListaMovimientos extends StatefulWidget {
  const ListaMovimientos({super.key});

  @override
  State<ListaMovimientos> createState() => _ListaMovimientosState();
}

class _ListaMovimientosState extends State<ListaMovimientos> {
  TextEditingController barraBusqueda = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MovimientoBloc, MovimientoEstado>(
        builder: (context, state) {
          if (state is GetAllMovimientos) {
            List<Map<String, dynamic>> movimientosFiltrados = state.movimientos
                .where((movimiento) =>
                    movimiento['nombremovimiento']!
                        .toLowerCase()
                        .contains(barraBusqueda.text.toLowerCase()) ||
                    movimiento['apodo']!
                        .toLowerCase()
                        .contains(barraBusqueda.text.toLowerCase()) ||
                    movimiento['nombrecategoria']!
                        .toLowerCase()
                        .contains(barraBusqueda.text.toLowerCase()) ||
                    movimiento['fechagasto']!
                        .toLowerCase()
                        .contains(barraBusqueda.text.toLowerCase()))
                .toList();
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: barraBusqueda,
                    decoration: InputDecoration(
                      labelText: 'Buscar',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                Expanded(
                  child: _listaMovientos(movimientosFiltrados),
                ),
              ],
            );
          } else if (state is ErrorGetAllMovimientos) {
            return Center(child: Text('Error: ${state.mensajeError}'));
          } else {
            return Center(child: Text('${state.mensajeError}'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mostrarModal(context, 'Nuevo Movimiento');
        },
        backgroundColor: const Color.fromRGBO(28, 29, 50, 1),
        child: const Icon(
          Icons.add,
          color: Color.fromRGBO(250, 240, 228, 1),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _listaMovientos(List<Map<String, dynamic>>? movimientos) {
    if (movimientos != null && movimientos.isNotEmpty) {
      return ListView.builder(
        itemCount: movimientos.length,
        itemBuilder: (context, index) {
          final movimiento = movimientos[index];
          int movimientoID = movimientos[index]['idmovimiento'];
          final gastototal = movimiento['gastototal'].toString();
          final fechagasto = movimiento['fechagasto'];
          String idcarro = movimiento['apodo'];
          String idcategoria = movimiento['nombrecategoria'];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0)),
              textColor: const Color.fromRGBO(250, 240, 228, 1),
              tileColor: const Color.fromRGBO(28, 29, 50, 1),
              title: Text(movimiento['nombremovimiento'] ?? 'No hay nombre'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Asociado a: $idcarro'),
                  Text('Categoria: $idcategoria'),
                  Text('Cantidad: $gastototal'),
                  Text('Fecha: $fechagasto'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _mostrarModalEditarMovimiento(context, movimiento);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color.fromRGBO(28, 29, 50, 1),
                      backgroundColor: const Color.fromRGBO(
                          250, 240, 228, 1), // Color del ícono
                    ),
                    child: const Icon(Icons.edit),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Center(
                                child: Text('¿Eliminar Movimiento?')),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.read<MovimientoBloc>().add(
                                      EliminarMovimiento(
                                          idmovimiento: movimientoID));
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Eliminar'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color.fromRGBO(28, 29, 50, 1),
                      backgroundColor: const Color.fromRGBO(
                          250, 240, 228, 1), // Color del ícono
                    ),
                    child: const Icon(Icons.delete),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      return const Center(child: Text('No hay gastos disponibles'));
    }
  }

  void _mostrarModal(BuildContext context, String movimiento) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return const FractionallySizedBox(
          heightFactor: 1.2,
          child: AgregarMovimiento(),
        );
      },
    );
  }
}

class AgregarMovimiento extends StatefulWidget {
  const AgregarMovimiento({super.key});

  @override
  State<AgregarMovimiento> createState() => _AgregarMovimientoState();
}

class _AgregarMovimientoState extends State<AgregarMovimiento> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nombreController = TextEditingController();
  int carroSeleccionado = 0;
  int categoriaSeleccionada = 0;
  TextEditingController gastosController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDate: selectedDate,
      firstDate: DateTime.now()
          .subtract(const Duration(days: 365)), // Restringe un año hacia atrás
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nuevo Gasto',
          style: TextStyle(color: Color.fromRGBO(250, 240, 228, 1)),
        ),
        backgroundColor: const Color.fromRGBO(28, 29, 50, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    BlocBuilder<CarroBloc, CarroEstado>(
                      builder: (context, carroState) {
                        if (carroState is GetAllCarros) {
                          List<Map<String, dynamic>> carros = carroState
                              .carrosArchivados; // Usar carrosArchivados en lugar de carros

                          return DropdownButton<int>(
                            onChanged: (newValue) {
                              setState(() {
                                if (newValue != null && newValue != 0) {
                                  carroSeleccionado = newValue;
                                }
                              });
                            },
                            value: carroSeleccionado,
                            items: [
                              const DropdownMenuItem<int>(
                                value: 0,
                                child: Text('Carro'),
                              ),
                              ...carros.map((carro) {
                                return DropdownMenuItem<int>(
                                  value: carro['idcarro'],
                                  child: Text(carro['apodo'].toString()),
                                );
                              }).toList(),
                            ],
                          );
                        } else {
                          return const CircularProgressIndicator();
                        }
                      },
                    ),
                    BlocBuilder<CategoriaBloc, CategoriaEstado>(
                      builder: (context, categoriaState) {
                        if (categoriaState is GetAllCategorias) {
                          List<Map<String, dynamic>> categorias =
                              categoriaState.categoriasarchivadas;

                          return DropdownButton<int>(
                            value: categoriaSeleccionada,
                            onChanged: (newValue) {
                              setState(() {
                                categoriaSeleccionada = newValue!;
                              });
                            },
                            items: [
                              const DropdownMenuItem<int>(
                                value: 0,
                                child: Text('Categoria'),
                              ),
                              ...categorias.map((categoria) {
                                return DropdownMenuItem<int>(
                                  value: categoria['idcategoria'],
                                  child: Text(
                                    categoria['nombrecategoria'].toString(),
                                  ),
                                );
                              }).toList(),
                            ],
                          );
                        } else {
                          return const CircularProgressIndicator();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                TextFormField(
                  controller: nombreController,
                  decoration: InputDecoration(
                    labelText: 'Concepto',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese un nombre para el gasto';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10.0),
                TextFormField(
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  controller: gastosController,
                  decoration: InputDecoration(
                    labelText: 'Total del gasto',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese una cantidad';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(28, 29, 50, 1)),
                  onPressed: () => _selectDate(context),
                  child: Text(
                    'Seleccionar fecha: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
                    style: const TextStyle(
                        color: Color.fromRGBO(250, 240, 228, 1)),
                  ),
                ),
                const SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: carroSeleccionado != 0 &&
                          categoriaSeleccionada != 0
                      ? () {
                          _insertarMovimiento(context);
                          Navigator.of(context).pop();
                        }
                      : null, // Deshabilita el botón si carroSeleccionado o categoriaSeleccionada son 0
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(28, 29, 50, 1),
                  ),
                  child: Text(
                    'Insertar Gasto',
                    // Cambia el estilo del texto si carroSeleccionado o categoriaSeleccionada son 0
                    style: TextStyle(
                      color:
                          (carroSeleccionado != 0 && categoriaSeleccionada != 0)
                              ? const Color.fromRGBO(250, 240, 228, 1)
                              : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _insertarMovimiento(BuildContext context) {
    final miBloc = BlocProvider.of<MovimientoBloc>(context);
    int numeroIngresado = int.tryParse(gastosController.text)!;
    String fechaSeleccionada =
        DateFormat('yyyy-MM-dd').format(selectedDate).toString();

    if (_formKey.currentState?.validate() ?? false) {
      miBloc.add(
        InsertarMovimiento(
          nombremovimiento: nombreController.text,
          idcarro: carroSeleccionado,
          idcategoria: categoriaSeleccionada,
          gastototal: numeroIngresado,
          fechagasto: fechaSeleccionada,
        ),
      );
    }
  }
}

// Agrega un nuevo método para mostrar el modal de edición
void _mostrarModalEditarMovimiento(
    BuildContext context, Map<String, dynamic> movimiento) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return FractionallySizedBox(
        heightFactor: 1.2,
        child: EditarMovimiento(movimiento: movimiento),
      );
    },
  );
}

// Crea un nuevo widget para la edición del movimiento
class EditarMovimiento extends StatefulWidget {
  final Map<String, dynamic> movimiento;

  const EditarMovimiento({super.key, required this.movimiento});

  @override
  State<EditarMovimiento> createState() => _EditarMovimientoState();
}

class _EditarMovimientoState extends State<EditarMovimiento> {
  TextEditingController nombreController = TextEditingController();
  int carroSeleccionado = 1;
  int categoriaSeleccionada = 1;
  TextEditingController gastosController = TextEditingController();
  DateTime selectedFecha = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDate: selectedFecha,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedFecha) {
      setState(() {
        selectedFecha = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    nombreController.text = widget.movimiento['nombremovimiento'];
    carroSeleccionado = widget.movimiento['idcarro'];
    categoriaSeleccionada = widget.movimiento['idcategoria'];
    gastosController.text = widget.movimiento['gastototal'].toString();
    String fechaDB = widget.movimiento['fechagasto'];
    selectedFecha = DateTime.parse(
        fechaDB); // Asigna la fecha de la base de datos a selectedDate
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Gasto',
            style: TextStyle(color: Color.fromRGBO(250, 240, 228, 1))),
        backgroundColor: const Color.fromRGBO(28, 29, 50, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  BlocBuilder<CarroBloc, CarroEstado>(
                    builder: (context, carroState) {
                      if (carroState is GetAllCarros) {
                        List<Map<String, dynamic>> carros = carroState.carros;

                        return DropdownButton<int>(
                          onChanged: (newValue) {
                            setState(() {
                              carroSeleccionado = newValue!;
                            });
                          },
                          value: carroSeleccionado, // Valor seleccionado
                          items: carros.map((carro) {
                            return DropdownMenuItem<int>(
                              value: carro['idcarro'],
                              child: Text(carro['apodo'].toString()),
                            );
                          }).toList(),
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
                  ),
                  const SizedBox(height: 10.0),
                  BlocBuilder<CategoriaBloc, CategoriaEstado>(
                    builder: (context, categoriaState) {
                      if (categoriaState is GetAllCategorias) {
                        List<Map<String, dynamic>> categorias =
                            categoriaState.categorias;

                        return DropdownButton<int>(
                          value: categoriaSeleccionada,
                          onChanged: (newValue) {
                            setState(() {
                              categoriaSeleccionada = newValue!;
                            });
                          },
                          items: categorias.map((categoria) {
                            return DropdownMenuItem<int>(
                              value: categoria['idcategoria'],
                              child:
                                  Text(categoria['nombrecategoria'].toString()),
                            );
                          }).toList(),
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre Gasto',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese un nombre para el gasto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                controller: gastosController,
                decoration: InputDecoration(
                  labelText: 'Total del gasto',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese una cantidad';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(28, 29, 50, 1)),
                onPressed: () => _selectDate(context),
                child: Text(
                  'Seleccionar fecha: ${DateFormat('yyyy-MM-dd').format(selectedFecha)}',
                  style:
                      const TextStyle(color: Color.fromRGBO(250, 240, 228, 1)),
                ),
              ),
              const SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () {
                  _actualizarMovimiento(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(28, 29, 50, 1),
                ),
                child: const Text(
                  'Actualizar Gasto',
                  style: TextStyle(color: Color.fromRGBO(250, 240, 228, 1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _actualizarMovimiento(BuildContext context) {
    final miBloc = BlocProvider.of<MovimientoBloc>(context);
    int numeroIngresado = int.tryParse(gastosController.text)!;
    String fechaSeleccionada =
        DateFormat('yyyy-MM-dd').format(selectedFecha).toString();

    if (nombreController.text.isNotEmpty) {
      miBloc.add(
        UpdateMovimiento(
          nombremovimiento: nombreController.text,
          idcarro: carroSeleccionado,
          idcategoria: categoriaSeleccionada,
          gastototal: numeroIngresado,
          fechagasto: fechaSeleccionada,
          idmovimiento: widget.movimiento['idmovimiento'],
        ),
      );
      Navigator.of(context)
          .pop(); // Cierra el modal después de la actualización
    }
  }
}
