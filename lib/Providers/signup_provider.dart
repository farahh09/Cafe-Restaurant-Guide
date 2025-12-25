import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final nameControllerProvider = Provider.autoDispose((ref) => TextEditingController());
final emailControllerProvider = Provider.autoDispose((ref) => TextEditingController());
final studentIdControllerProvider = Provider.autoDispose((ref) => TextEditingController());
final passwordControllerProvider = Provider.autoDispose((ref) => TextEditingController());
final confirmPasswordControllerProvider = Provider.autoDispose((ref) => TextEditingController());

final selectedLevelProvider = StateProvider<String?>((ref) => null);
final selectedGenderProvider = StateProvider<String?>((ref) => null);
