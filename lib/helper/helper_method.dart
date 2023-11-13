// return a formattted data as string

import 'package:cloud_firestore/cloud_firestore.dart';

String formatDate(Timestamp timestamp){

  DateTime dateTime = timestamp.toDate();
  // get year
  String year = dateTime.year.toString();
  // get month
  String month = dateTime.month.toString();
  // get day
  String day = dateTime.day.toString();

  //final formatted date 
  String formatData = '$day/$month/$year';

  return formatData;
}