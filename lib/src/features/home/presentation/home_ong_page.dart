import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hackathon/src/core/colors.dart';
import 'package:hackathon/src/core/routes.dart';
import 'package:hackathon/src/features/home/domain/entities/doacao.dart';

class HomeOngPage extends StatefulWidget {
  const HomeOngPage({super.key});

  @override
  State<HomeOngPage> createState() => _HomeOngPageState();
}

class _HomeOngPageState extends State<HomeOngPage>
    with SingleTickerProviderStateMixin {
  late final GoogleMapController _mapController;

  Position? myLocation;
  bool isLoadingMap = true;
  int perfil = 0;
  int currentIndex = 0;

  BitmapDescriptor? cartBitmap;

  final GlobalKey<ScaffoldState> _key = GlobalKey();

  List<Doacao> doacoes = [
    const Doacao(
      nomeEstabelecimento: 'Favorito Supermercados',
      tipo: 'Roupas',
      distancia: '1 km',
      endereco: 'Avenida dos Mockups',
      latitude: -5.7580053,
      longitude: -35.3199117,
    ),
    const Doacao(
      nomeEstabelecimento: 'Nordestão Ponta Negra',
      tipo: 'Alimentos',
      distancia: '1 km',
      endereco: 'Avenida dos Mockups',
      latitude: -5.8537113,
      longitude: -35.2044758,
    ),
    const Doacao(
      nomeEstabelecimento: 'Nordestão Cidade Jardim',
      tipo: 'Roupas',
      distancia: '1 km',
      endereco: 'Avenida dos Mockups',
      latitude: -5.849786,
      longitude: -35.2082365,
    ),
  ];

  @override
  void initState() {
    _getLocation();
    super.initState();
  }

  Future<void> _getLocation() async {
    final bitmap = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(128, 128)),
      'assets/images/pin.png',
    );

    final position = await _determinePosition();

    setState(() {
      cartBitmap = bitmap;
      myLocation = position;
      isLoadingMap = false;
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  CameraPosition _actualCameraPosition() {
    _determinePosition();
    if (myLocation == null) return _kGooglePlex;

    return CameraPosition(
        target: LatLng(myLocation!.latitude, myLocation!.longitude), zoom: 15);
  }

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Future<void> _changeCamera(LatLng latLng) async {
    final position = CameraPosition(target: latLng, zoom: 18);
    await _mapController
        .animateCamera(CameraUpdate.newCameraPosition(position));
  }

  LatLng _actualPosition() {
    if (myLocation == null) {
      return const LatLng(37.42796133580664, -122.085749655962);
    }

    return LatLng(myLocation!.latitude, myLocation!.longitude);
  }

  Set<Marker> _getMarkers() {
    final doacoesMarkers = doacoes
        .map(
          (e) => Marker(
            markerId: MarkerId(e.nomeEstabelecimento),
            position: LatLng(e.latitude, e.longitude),
            icon: cartBitmap!,
          ),
        )
        .toSet();

    doacoesMarkers.add(
      Marker(
        markerId: const MarkerId('user'),
        position: _actualPosition(),
      ),
    );

    return doacoesMarkers;
  }

  List<Doacao> get doacoesFiltradas {
    return doacoes
        .where((element) =>
            element.isRetirando == false && element.isRetirado == false)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        backgroundColor: AppColors.green,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Solidarius',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.home);
                },
                child: const Text('Perfil Usuário'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Perfil ONG'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    perfil = 2;
                  });
                },
                child: const Text('Perfil Estabelecimento'),
              ),
            ],
          ),
        ),
      ),
      key: _key,
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        backgroundColor: AppColors.green,
        indicatorColor: Colors.white,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '',
          ),
          const NavigationDestination(
            icon: Icon(Icons.local_shipping_outlined),
            selectedIcon: Icon(Icons.local_shipping),
            label: '',
          ),
          const NavigationDestination(
            icon: Icon(Icons.check_outlined),
            selectedIcon: Icon(Icons.check),
            label: '',
          ),
        ],
      ),
      body: isLoadingMap
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: _actualCameraPosition(),
                  onMapCreated: (GoogleMapController controller) async {
                    setState(() {
                      _mapController = controller;
                    });
                  },
                  markers: _getMarkers(),
                ),
                Positioned(
                  top: 60,
                  left: 20,
                  child: Container(
                    width: 220,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, 4),
                          blurRadius: 6,
                          spreadRadius: -1,
                          color: Colors.black.withOpacity(0.1),
                        ),
                        BoxShadow(
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                          spreadRadius: -2,
                          color: Colors.black.withOpacity(0.1),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Doações Disponíveis',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 60,
                  right: 20,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, 4),
                          blurRadius: 6,
                          spreadRadius: -1,
                          color: Colors.black.withOpacity(0.1),
                        ),
                        BoxShadow(
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                          spreadRadius: -2,
                          color: Colors.black.withOpacity(0.1),
                        ),
                      ],
                    ),
                    child: IconButton(
                        onPressed: () {
                          _key.currentState!.openDrawer();
                        },
                        icon: const Icon(Icons.person)),
                  ),
                ),
                DraggableScrollableSheet(
                  initialChildSize: 0.3,
                  minChildSize: 0.1,
                  maxChildSize: 0.3,
                  snapSizes: [0.1, 0.3],
                  snap: true,
                  builder: (context, scrollController) => Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                width: 60,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                            ),
                          ),
                          ListView.separated(
                            controller: scrollController,
                            itemCount: doacoes
                                .where((element) =>
                                    element.isRetirando == false &&
                                    element.isRetirado == false)
                                .length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(
                              height: 12,
                            ),
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: InkWell(
                                  onTap: () async {
                                    final latLng = LatLng(
                                        doacoesFiltradas[index].latitude,
                                        doacoesFiltradas[index].longitude);

                                    await _changeCamera(latLng);
                                  },
                                  child: Ink(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    width: double.infinity,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(25),
                                      boxShadow: [
                                        BoxShadow(
                                          offset: const Offset(0, 4),
                                          blurRadius: 6,
                                          spreadRadius: -1,
                                          color: Colors.black.withOpacity(0.1),
                                        ),
                                        BoxShadow(
                                          offset: const Offset(0, 2),
                                          blurRadius: 4,
                                          spreadRadius: -2,
                                          color: Colors.black.withOpacity(0.1),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          margin:
                                              const EdgeInsets.only(right: 18),
                                          height: 80,
                                          width: 80,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            boxShadow: [
                                              BoxShadow(
                                                offset: const Offset(0, 4),
                                                blurRadius: 6,
                                                spreadRadius: -1,
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                              ),
                                              BoxShadow(
                                                offset: const Offset(0, 2),
                                                blurRadius: 4,
                                                spreadRadius: -2,
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                              Icons.shopping_cart_outlined),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(doacoesFiltradas[index]
                                                  .nomeEstabelecimento),
                                              Text(
                                                  'Tipo de Doação: ${doacoesFiltradas[index].tipo}'),
                                              Text(
                                                  '${doacoesFiltradas[index].distancia} distância'),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () => showDialog<String>(
                                            context: context,
                                            builder: (BuildContext context) =>
                                                Dialog(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      doacoesFiltradas[index]
                                                          .nomeEstabelecimento,
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                        'Tipo de doação: ${doacoesFiltradas[index].tipo}'),
                                                    Text(
                                                        '${doacoesFiltradas[index].distancia} de distância.'),
                                                    Text(
                                                      'Endereço: ${doacoesFiltradas[index].endereco}',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 15),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: ElevatedButton(
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              backgroundColor:
                                                                  Colors.red,
                                                              foregroundColor:
                                                                  Colors.white,
                                                            ),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: Text(
                                                                'Cancelar'),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Expanded(
                                                          child: ElevatedButton(
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              backgroundColor:
                                                                  AppColors
                                                                      .green,
                                                              foregroundColor:
                                                                  Colors.white,
                                                            ),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: Text(
                                                                'Confirmar para retirada'),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          icon: const Icon(
                                              Icons.chevron_right_outlined),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
