import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import '../my_flutter_app_icons.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'ventana2_model.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
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
  File? _image;
  bool b_construction = false;
  bool b_obstacles = false;
  bool b_pavement = false;
  bool b_ramp = false;
  bool b_stairs = false;

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

  Future<void> infer(File imageFile) async {
    var imageBytes = await imageFile.readAsBytes();
    var imageFormated = base64.encode(imageBytes);

    final apiKey = 'eUgAAYZBwsHc4IlF7ui2'; // Your API Key
    final modelEndpoint = 'sidewalk-accesibility/2'; // Set model endpoint (Found in Dataset URL)

    // Construct the URL
    final uploadURL =
        'https://detect.roboflow.com/$modelEndpoint?api_key=$apiKey&name=YOUR_IMAGE.jpg';

    // Http Request
    final response = await HttpClient().postUrl(Uri.parse(uploadURL))
      ..headers.contentType = ContentType.parse('application/x-www-form-urlencoded')
      ..headers.contentLength = imageFormated.length
      ..write(imageFormated);

    // Get Response
    final responseBody = await response.close();
    await utf8.decodeStream(responseBody).then(print);
  }


  Future<void> _tomarFoto() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {

      File imageFile = File(pickedImage.path);

      String upload_url = [
        "https://detect.roboflow.com/",
        "sidewalk-accesibility",
        "/",
        "2",
        "?api_key=",
        "eUgAAYZBwsHc4IlF7ui2",
        "&format=image",
        "&stroke=2"
      ].join();

      infer(imageFile);

      setState(() {
        _image = imageFile;
      });

    }
  }

  void _sendRequest() {
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
                    padding: EdgeInsetsDirectional.fromSTEB(0, 15, 0, 15),
                    child: InkWell(
                      onTap: () => _tomarFoto(),
                      child: Container(
                        width: 400,
                        height: 400,
                        child: _image != null
                            ? Image.file(
                          _image!,
                          fit: BoxFit.cover,
                        )
                            : Image.asset('assets/images/emptyState@2x.png',
                          fit: BoxFit.cover, // ajuste la imagen para cubrir el widget
                          width: double.infinity, // ancho máximo disponible
                          height: double.infinity,)
                      ),
                  )),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        iconSize: 30.0,
                        color:  b_construction ? Color(0xFF4B39EF) : Colors.black,
                        icon: Icon(CustomIcons.construction),
                        onPressed: () {
                          setState(() {
                            b_construction = !b_construction;
                          });
                        },
                      ),
                      IconButton(
                        iconSize: 30.0,
                        color:  b_obstacles ? Color(0xFF4B39EF) : Colors.black,
                        icon: Icon(CustomIcons.obstacles),
                        onPressed: () {
                          setState(() {
                            b_obstacles = !b_obstacles;
                          });
                        },
                      ),
                      IconButton(
                        iconSize: 30.0,
                        color:  b_pavement ? Color(0xFF4B39EF) : Colors.black,
                        icon: Icon(CustomIcons.pavement),
                        onPressed: () {
                          setState(() {
                            b_pavement = !b_pavement;
                          });
                        },
                      ),
                      IconButton(
                        iconSize: 30.0,
                        color:  b_ramp ? Color(0xFF4B39EF) : Colors.black,
                        icon: Icon(CustomIcons.ramp),
                        onPressed: () {
                          setState(() {
                            b_ramp = !b_ramp;
                          });
                        },
                      ),
                      IconButton(
                        iconSize: 30.0,
                        color:  b_stairs ? Color(0xFF4B39EF) : Colors.black,
                        icon: Icon(CustomIcons.stairs),
                        onPressed: () {
                          setState(() {
                            b_stairs = !b_stairs;
                          });
                        },
                      ),
                    ]
                  )
                ], // Children
              ),
            ),
          ),
          FFButtonWidget(
            onPressed: _sendRequest ,
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
