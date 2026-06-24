import 'package:flutter/material.dart';

class ItemDataModel {
  final TextEditingController headingController;
  final TextEditingController descriptionController;

  ItemDataModel({
    String? heading,
    String? description,
  })  : headingController = TextEditingController(text: heading ?? ''),
        descriptionController = TextEditingController(text: description ?? '');
}