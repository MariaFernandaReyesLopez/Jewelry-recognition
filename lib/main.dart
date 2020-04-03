import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

void main() => runApp(MaterialApp(
  home: MyApp(),
));

class MyApp extends StatefulWidget{
  @override
  _AppState createState()=>_AppState();
}
class _AppState extends State<MyApp>{
  //Variables de control
  List _salidas;
  File _Imagen;
  bool _isLoading = false;

  @override
  void initState(){
    super.initState();
    _isLoading = true;
    loadModel().then((value){
      setState(() {
        _isLoading = false;
      });
    });

  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Jewelry recognition"),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading ? Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ):Container(
        width: MediaQuery.of(context).size.width, //Ancho de pantalla
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _Imagen == null ? Container():Image.file(_Imagen),
            SizedBox(
              height: 20,
            ),
            _salidas != null ? Text("${_salidas[0]["label"]}",
              style: TextStyle(
                color: Colors.teal,
                fontSize: 20.0,
                background: Paint()..color = Colors.white,
              ),
            )
                : Container()
          ],
        ),
      ),

      floatingActionButton: SpeedDial(
        backgroundColor: Colors.teal,
        animatedIcon: AnimatedIcons.menu_close,
        children: [
          SpeedDialChild(
              backgroundColor: Colors.teal,
              child: Icon(Icons.camera_alt),
              label: "Camera",
              onTap: tomarImagenCamara
          ),
          SpeedDialChild(
              backgroundColor: Colors.teal,
              child: Icon(Icons.image),
              label: "Gallery",
              onTap: pickImage
          )
        ],
      ),

    );
  }
  //Cargar imagen desde galeria
  pickImage() async {
    var imagen = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (imagen == null) return null;
    setState(() {
      _isLoading = true;
      _Imagen = imagen;
    });
    clasificar(imagen);
  }

  tomarImagenCamara() async{
    var imagen = await ImagePicker.pickImage(source: ImageSource.camera);
    if (imagen == null) return null;
    setState(() {
      _isLoading = true;
      _Imagen = imagen;
    });
    clasificar(imagen);
  }


  clasificar(File image) async{
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 5,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _isLoading = false;
      _salidas = output;
    });
  }

//Cargar modelo
  loadModel() async{
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",);
  }
  @override
  void dispose(){
    Tflite.close();
    super.dispose();
  }

}