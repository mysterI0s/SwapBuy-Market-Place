import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Constant/url.dart';
import 'package:swapbuy/Model/Address.dart';
import 'package:swapbuy/Services/CustomDialog.dart';
import 'package:swapbuy/Services/Failure.dart';
import 'package:swapbuy/Services/NetworkClient.dart';
import 'package:swapbuy/Services/ServicesProvider.dart';
import 'package:http/http.dart' as http;
import 'package:video_thumbnail/video_thumbnail.dart';

class AddProductController with ChangeNotifier {
  List<String> conditionlist = [];
  List<String> statuslist = [];
  List<Address> adresses = [];

  Future<Either<Failure, bool>> AllAddress(BuildContext context) async {
    adresses.clear();
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.Address(
          Provider.of<ServicesProvider>(context, listen: false).userid,
        ),
        requestType: RequestType.GET,
      );

      log(response.statusCode.toString());
      log(response.body);
      var json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        json.forEach((v) {
          adresses.add(new Address.fromJson(v));
        });
        notifyListeners();
        // CustomDialog.DialogSuccess(context, title: json['message']);
        return Right(true);
      } else if (response.statusCode == 404) {
        if (json.containsKey('error')) {
          CustomDialog.DialogError(context, title: json['error']);
        }

        return Right(false);
      } else if (response.statusCode == 401) {
        if (json.containsKey('error')) {
          CustomDialog.DialogError(context, title: json['error']);
        }

        return Right(false);
      } else {
        CustomDialog.DialogError(context, title: json['error']);
        return Right(false);
      }
    } catch (e) {
      log(e.toString());
      return Left(GlobalFailure());
    }
  }

  Future<Either<Failure, bool>> STATUSOPTIONS(BuildContext context) async {
    statuslist.clear();
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.STATUSOPTIONS,
        requestType: RequestType.GET,
      );

      log(response.statusCode.toString());
      log(response.body);
      var json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        json.forEach((v) {
          statuslist.add(v);
        });
        notifyListeners();
        return Right(true);
      } else if (response.statusCode == 404) {
        if (json.containsKey('error')) {
          CustomDialog.DialogError(context, title: json['error']);
        }

        return Right(false);
      } else if (response.statusCode == 401) {
        if (json.containsKey('error')) {
          CustomDialog.DialogError(context, title: json['error']);
        }

        return Right(false);
      } else {
        CustomDialog.DialogError(context, title: json['error']);
        return Right(false);
      }
    } catch (e) {
      log(e.toString());
      return Left(GlobalFailure());
    }
  }

  Future<Either<Failure, bool>> CONDITIONOPTIONS(BuildContext context) async {
    conditionlist.clear();
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.CONDITIONOPTIONS,
        requestType: RequestType.GET,
      );

      log(response.statusCode.toString());
      log(response.body);
      var json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        json.forEach((v) {
          conditionlist.add(v);
        });
        notifyListeners();
        return Right(true);
      } else if (response.statusCode == 404) {
        if (json.containsKey('error')) {
          CustomDialog.DialogError(context, title: json['error']);
        }

        return Right(false);
      } else if (response.statusCode == 401) {
        if (json.containsKey('error')) {
          CustomDialog.DialogError(context, title: json['error']);
        }

        return Right(false);
      } else {
        CustomDialog.DialogError(context, title: json['error']);
        return Right(false);
      }
    } catch (e) {
      log(e.toString());
      return Left(GlobalFailure());
    }
  }

  TextEditingController productname = TextEditingController();
  TextEditingController productdescription = TextEditingController();
  TextEditingController productprice = TextEditingController();
  TextEditingController productquantity = TextEditingController();
  String? condition;
  String? status;
  Address? address;
  XFile? productpicture;
  ImagePicker picker = ImagePicker();
  File? videofile;

  CleanData() {
    productname.clear();
    productdescription.clear();
    productprice.clear();
    productquantity.clear();
    condition = null;
    status = null;
    address = null;
    productpicture = null;
    videofile = null;
    notifyListeners();
  }

  Selectcondition(value) {
    condition = value;
    notifyListeners();
  }

  Selectstatus(value) {
    status = value;
    notifyListeners();
  }

  Selectaddress(value) {
    address = value;
    notifyListeners();
  }

  String? thumbnailPath;
  PickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      videofile = File(result.files.single.path!);
      thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videofile!.path,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.PNG,
        maxWidth: 128,
        quality: 25,
      );
      notifyListeners();
    }
  }

  PickImage() async {
    productpicture = await picker.pickImage(source: ImageSource.gallery);
    notifyListeners();
  }

  Future<Either<Failure, bool>> AddProduct(BuildContext context) async {
    final client = Provider.of<NetworkClient>(context, listen: false);

    try {
      List<http.MultipartFile> files = [];

      if (productpicture != null) {
        files.add(
          await http.MultipartFile.fromPath('image', productpicture!.path),
        );
      }
      if (videofile != null) {
        files.add(
          await http.MultipartFile.fromPath('video_file', videofile!.path),
        );
      }
      var response = await client.requestwithmultifile(
        path: AppApi.AddProduct(
          Provider.of<ServicesProvider>(context, listen: false).userid,
        ),
        files: files,
        requestType: RequestType.POST,
        body: {
          "name": productname.text,
          "description": productdescription.text,
          "price": productprice.text,
          "quantity_available": productquantity.text,
          "condition": condition!,
          "status": status!,
          "id_address": address!.id!.toString(),
        },
      );
      var responseBody = await response.stream.bytesToString();

      log(response.statusCode.toString());
      log(responseBody);
      var json = jsonDecode(responseBody);

      if (response.statusCode == 201) {
        CustomDialog.DialogSuccess(context, title: json['message']);
        CleanData();
        return Right(true);
      } else if (response.statusCode == 400) {
        if (json.containsKey('error')) {
          CustomDialog.DialogError(context, title: json['error']);
        }
        return Right(false);
      } else if (response.statusCode == 401) {
        if (json.containsKey('error')) {
          CustomDialog.DialogError(context, title: json['error']);
        }

        return Right(false);
      } else {
        CustomDialog.DialogError(context, title: json['error']);
        return Right(false);
      }
    } catch (e) {
      log(e.toString());
      return Left(GlobalFailure());
    }
  }
}
