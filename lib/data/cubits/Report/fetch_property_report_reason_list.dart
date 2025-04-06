import 'dart:developer';

import 'package:ebroker/data/model/report_property/reason_model.dart';
import 'package:ebroker/data/repositories/report_property_repository.dart';
import 'package:ebroker/settings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchPropertyReportReasonsListState {}

class FetchPropertyReportReasonsInitial
    extends FetchPropertyReportReasonsListState {}

class FetchPropertyReportReasonsInProgress
    extends FetchPropertyReportReasonsListState {}

class FetchPropertyReportReasonsSuccess
    extends FetchPropertyReportReasonsListState {
  FetchPropertyReportReasonsSuccess({
    required this.total,
    required this.reasons,
  });

  final int total;
  final List<ReportReason> reasons;
}

class FetchPropertyReportReasonsFailure
    extends FetchPropertyReportReasonsListState {
  FetchPropertyReportReasonsFailure(this.error);
  final dynamic error;
}

class FetchPropertyReportReasonsListCubit
    extends Cubit<FetchPropertyReportReasonsListState> {
  FetchPropertyReportReasonsListCubit()
      : super(FetchPropertyReportReasonsInitial());
  final ReportPropertyRepository _repository = ReportPropertyRepository();
  Future<void> fetch({bool? forceRefresh}) async {
    try {
      if (forceRefresh != true) {
        if (state is FetchPropertyReportReasonsSuccess) {
          // WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
          await Future.delayed(
            const Duration(seconds: AppSettings.hiddenAPIProcessDelay),
          );
          // });
        } else {
          emit(FetchPropertyReportReasonsInProgress());
        }
      } else {
        emit(FetchPropertyReportReasonsInProgress());
      }

      if (forceRefresh == true) {
        final result = await _repository.fetchReportReasonsList();

        result.modelList.add(ReportReason(id: -10, reason: 'Other'));

        emit(
          FetchPropertyReportReasonsSuccess(
            reasons: result.modelList,
            total: result.total,
          ),
        );
      } else {
        if (state is! FetchPropertyReportReasonsSuccess) {
          final result = await _repository.fetchReportReasonsList();

          result.modelList.add(ReportReason(id: -10, reason: 'Other'));

          emit(
            FetchPropertyReportReasonsSuccess(
              reasons: result.modelList,
              total: result.total,
            ),
          );
        }
      }

      // emit(FetchPropertyReportReasonsInProgress());
    } catch (e) {
      log('REPORT REASON ERROR IS $e');
      emit(FetchPropertyReportReasonsFailure(e));
    }
  }

  List<ReportReason>? getList() {
    if (state is FetchPropertyReportReasonsSuccess) {
      return (state as FetchPropertyReportReasonsSuccess).reasons;
    }
    return null;
  }
}
