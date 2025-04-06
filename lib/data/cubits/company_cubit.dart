import 'package:ebroker/data/helper/custom_exception.dart';
import 'package:ebroker/data/model/company.dart';
import 'package:ebroker/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CompanyState {}

class CompanyInitial extends CompanyState {}

class CompanyFetchProgress extends CompanyState {}

class CompanyFetchSuccess extends CompanyState {
  CompanyFetchSuccess(this.companyData);
  Company companyData;
}

class CompanyFetchFailure extends CompanyState {
  CompanyFetchFailure(this.errmsg);
  final dynamic errmsg;
}

class CompanyCubit extends Cubit<CompanyState> {
  CompanyCubit() : super(CompanyInitial());

  void fetchCompany(BuildContext context) {
    emit(CompanyFetchProgress());
    fetchCompanyFromDb(context)
        .then((value) => emit(CompanyFetchSuccess(value)))
        .catchError((e) => emit(CompanyFetchFailure(e)));
  }

  Future<Company> fetchCompanyFromDb(BuildContext context) async {
    try {
      var companyData = Company();

      final body = <String, String>{
        Api.type: Api.company,
      };

      final response = await Api.get(
        url: Api.apiGetAppSettings,
        queryParameters: body,
      );

      // var getdata = json.decode(response);

      if (!response[Api.error]) {
        final Map list = response['data'];
        // companyData = list.map((model) => Company.fromJson(model)).toList();

        companyData = Company.fromJson(Map.from(list));

        //set company mobile/contact number for Call @ Property details
        // Constant.session
        //     .setData(Session.keyCompMobNo, contactNumber.data.toString());
      } else {
        throw CustomException(response[Api.message]);
      }

      return companyData;
    } catch (e) {
      rethrow;
    }
  }
}
