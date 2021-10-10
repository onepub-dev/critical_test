// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit_test.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnitTest _$UnitTestFromJson(Map<String, dynamic> json) => UnitTest(
      pathTo: json['pathToUnitTest'] as String,
      testName: json['testName'] as String?,
    );

Map<String, dynamic> _$UnitTestToJson(UnitTest instance) => <String, dynamic>{
      'pathToUnitTest': instance.pathTo,
      'testName': instance.testName,
    };
