import 'dart:convert';
import 'dart:ui' as ui;
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
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
export 'ventana2_model.dart';
import 'package:webdriver/async_core.dart';
import 'package:html/parser.dart' as htmlParser;
import 'package:html/dom.dart' as htmlDom;
import 'package:future_progress_dialog/future_progress_dialog.dart';

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

  List<String> _selectedOptions = [];
  final List<String> _options = [
    'suelo inestable',
    'obstáculos',
    'rampa peligrosa',
    'ausencia de rampa',
    'inaccesible por obras',
  ];

  bool showProgressIndicator = false;

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

  Future<String> infer(File imageFile) async {
    var imageBytes = await imageFile.readAsBytes();
    var imageFormated = base64.encode(imageBytes);

    final apiKey = '1rlted2kCU2CcgeOrHwe'; // Your API Key
    final modelEndpoint = 'accesibility-street/11'; // Set model endpoint (Found in Dataset URL)

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
    return await utf8.decodeStream(responseBody);
  }

  Future<ui.Image> loadImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  Future<void> _tomarFoto() async {

    //Reset icons
    setState(() {
      _selectedOptions.clear();
    });

    //Take photo
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);

      //Image
      setState(() {
        _image = imageFile;
        showProgressIndicator = true;
      });

      //Predictions
      final res = await infer(imageFile);
      updateIcons((res));

      //Carga
      setState(() {
        showProgressIndicator = false;
      });

    }

  }

  void updateIcons(String res) {

    //Parsea el json
    Map<String, dynamic> json = jsonDecode(res);
    List<dynamic> predictions = json['predictions'];
    Set<String> uniqueClasses = Set();
    for (dynamic prediction in predictions) {
      String classValue = prediction['class'];
      uniqueClasses.add(classValue);
    }
    print(uniqueClasses);

    // Actualizar el estado de los iconos correspondientes
    setState(() {
     _selectedOptions = uniqueClasses.toList();
    });
  }

  Future<void> _sendRequest() async {

    setState(() {
      showProgressIndicator = true;
    });

    //Datos direccion
    List<String> partes = address.split(',');
    partes = partes.map((parte) => parte.trim()).toList();
    String calle = partes[0];
    String cp = partes[1];
    String ciudad = partes[2];

    //Datos etiquetas
    String opciones = _selectedOptions.toString();

    String url = 'https://wicked-dogs-change.loca.lt/?calle=${Uri.encodeComponent(calle)}'
        '&cp=${Uri.encodeComponent(cp)}'
        '&ciudad=${Uri.encodeComponent(ciudad)}'
        '&opciones=${Uri.encodeComponent(opciones)}';

    print(url);

    http.get(Uri.parse(url)).then((response) {

      setState(() {
        showProgressIndicator = false;
      });

      if (response.statusCode == 200) {
        final document = htmlParser.parse(response.body);
        var text = extractTextFromBody(document);
        print('Texto extraído:');
        print(text);
        _showAlertDialog(context,text);
      } else {
        print('Error en la solicitud. Código de estado: ${response.statusCode}');
        _showAlertDialog(context,"text");
      }
    }).catchError((error) {
      print('Error en la solicitud: $error');
    });

  }

  String extractTextFromBody(htmlDom.Document document) {
    final bodyElement = document.querySelector('body');
    if (bodyElement != null) {
      return bodyElement.text.trim();
    } else {
      return 'No se encontró el elemento <body>';
    }
  }

  void _showAlertDialog(BuildContext context, String text) {
    String dialogText;
    if (text == 'Your data has been submitted.') {
      dialogText = 'Incidencia creada correctamente';
    } else {
      dialogText = 'Error al crear incidencia. Inténtelo de nuevo más tarde';
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Respuesta del servidor'),
          content: Text(dialogText),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:  Text(
                'Cerrar',
                style: TextStyle(
                  color:  Color(0xFF4B39EF),
                ),
              ),
            ),
          ],
        );
      });}


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
        backgroundColor: Color(0xFF4B39EF),
        automaticallyImplyLeading: false,
        title: Text(
          'EASY ON WAY',
          style:TextStyle(
            fontFamily: 'Lexend Deca',
            color: Colors.white,
            fontSize: 35,
          ),
        ),
        actions: [],
        centerTitle: true,
        elevation: 4,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Visibility(
            visible: showProgressIndicator,
            child: LinearProgressIndicator(color: Color(0xFF4B39EF), backgroundColor: Colors.white, minHeight: 5.0,),
          ),
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
                    text: address == "" ? 'Obteniendo ubicación ...' : address,
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
                        fontFamily: 'Lexend Deca',
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

                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8.0,
                    children: _options.map((option) {
                      return ChoiceChip(
                        elevation: 4,
                        label: Text(
                          option,
                          style: TextStyle(
                          fontFamily: 'Lexend Deca',
                          fontSize: 13.0,
                          color: _selectedOptions.contains(option)
                          ? Colors.white
                          : Colors.black,
                      )),
                        backgroundColor:
                        _selectedOptions.contains(option) ? Color(0xFF4B39EF) : null,
                        selectedColor: Color(0xFF4B39EF),
                        selected: _selectedOptions.contains(option),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedOptions.add(option);
                            } else {
                              _selectedOptions.remove(option);
                            }
                          });
                        },
                      );
                    }).toList(),
                  )
                ], // Children
              ),
            ),
          ),
          FFButtonWidget(
            onPressed: _sendRequest ,
            text: 'Crear incidencia',
            options: FFButtonOptions(
              width: 270,
              height: 50,
              padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
              iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
              color: FlutterFlowTheme.of(context).primaryColor,
              textStyle: FlutterFlowTheme.of(context).subtitle2.override(
                fontFamily: 'Lexend Deca',
                color: Colors.white,
                fontSize: 20,
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
