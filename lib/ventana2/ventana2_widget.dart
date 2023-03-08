import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';

import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_place_picker.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/place.dart';
import '/flutter_flow/upload_media.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:geocoding/geocoding.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'ventana2_model.dart';
export 'ventana2_model.dart';


class Ventana2Widget extends StatefulWidget {
  const Ventana2Widget({
    Key? key,
    this.img,
  }) : super(key: key);

  final String? img;

  @override
  _Ventana2WidgetState createState() => _Ventana2WidgetState();
}

class _Ventana2WidgetState extends State<Ventana2Widget>
    with TickerProviderStateMixin {
  late Ventana2Model _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  String address = "";
  XFile? _imageFile;

  Future<void> _obtenerUbicacion() async {
    // Obtener la ubicación actual del dispositivo
    Position position = await Geolocator.getCurrentPosition();

    // Obtener la latitud y longitud
    double latitude = position.latitude;
    double longitude = position.longitude;

    // Obtener la dirección a partir de la latitud y longitud
    List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
    Placemark place = placemarks[0];

    // Obtener la dirección completa

    setState(() {
      address = '${place.street}, ${place.postalCode}, ${place.locality}, ${place.country}';
    });

    // Imprimir la ubicación
    print('Latitud: $latitude, Longitud: $longitude');
    print('Direccion: $address');

  }
  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => Ventana2Model());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _obtenerUbicacion();
    });
  }

  Future<void> _tomarFoto() async {
    _imageFile = (await ImagePicker().pickImage(source: ImageSource.camera));
    setState(() {
    });
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        automaticallyImplyLeading: false,
        actions: [],
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Align(
            alignment: AlignmentDirectional(0, 0),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(20, 50, 20, 50),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  FFButtonWidget(
                    onPressed: () {
                    },
                    text: address == "" ? 'Getting ubication ...' : address,
                    icon: Icon(
                      Icons.location_on,
                      color: Color(0xFF4B39EF),
                      size: 30,
                    ),
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 40,
                      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                      iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                      color: Colors.white,
                      textStyle:
                      FlutterFlowTheme.of(context).subtitle2.override(
                        fontFamily: 'Poppins',
                        color: Colors.black,
                      ),
                      elevation: 2,
                      borderSide: BorderSide(
                        color: Colors.transparent,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    showLoadingIndicator: false,
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
                    child: InkWell(
                      onTap: () => _tomarFoto(),
                      child: Container(
                        width: 400,
                        height: 400,
                        child: _imageFile != null
                        ? Image.file(File(_imageFile!.path),
                          fit: BoxFit.cover, // ajuste la imagen para cubrir el widget
                          width: double.infinity, // ancho máximo disponible
                          height: double.infinity,)
                        : Image.asset('assets/images/emptyState@2x.png',
                          fit: BoxFit.cover, // ajuste la imagen para cubrir el widget
                          width: double.infinity, // ancho máximo disponible
                          height: double.infinity,), // ICONO DE AÑADIR IMAGEN
                      ),
                  )),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
                    child: FlutterFlowDropDown<String>(
                      options: ['Curb', 'Streetlight', 'Tree'],
                      onChanged: (val) => setState(() => _model.obsValue = val),
                      width: double.infinity,
                      height: 60,
                      textStyle: FlutterFlowTheme.of(context).bodyText1,
                      hintText: 'Type of obstacle',
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: FlutterFlowTheme.of(context).secondaryText,
                        size: 15,
                      ),
                      fillColor:
                      FlutterFlowTheme.of(context).secondaryBackground,
                      elevation: 2,
                      borderColor:
                      FlutterFlowTheme.of(context).primaryBackground,
                      borderWidth: 2,
                      borderRadius: 8,
                      margin: EdgeInsetsDirectional.fromSTEB(20, 20, 12, 20),
                      hidesUnderline: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          FFButtonWidget(
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (alertDialogContext) {
                  return AlertDialog(
                    content: Text('Ticket created successfully'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(alertDialogContext),
                        child: Text('Ok'),
                      ),
                    ],
                  );
                },
              );
            },
            text: 'Create issue',
            options: FFButtonOptions(
              width: 270,
              height: 50,
              padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
              iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
              color: FlutterFlowTheme.of(context).primaryColor,
              textStyle: FlutterFlowTheme.of(context).subtitle2.override(
                fontFamily: 'Lexend Deca',
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              elevation: 3,
              borderSide: BorderSide(
                color: Colors.transparent,
                width: 1,
              ),
            ),
            showLoadingIndicator: false,
          ),
        ],
      ),
    );
  }
}
