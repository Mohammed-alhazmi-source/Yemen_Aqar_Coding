// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:ebroker/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeleteMessageState {}

class DeleteMessageInitial extends DeleteMessageState {}

class DeleteMessageInProgress extends DeleteMessageState {}

class DeleteMessageSuccess extends DeleteMessageState {
  final String id;
  DeleteMessageSuccess({
    required this.id,
  });
}

class DeleteMessageFail extends DeleteMessageState {
  dynamic error;
  DeleteMessageFail({
    required this.error,
  });
}

class DeleteMessageCubit extends Cubit<DeleteMessageState> {
  DeleteMessageCubit() : super(DeleteMessageInitial());

  Future<void> delete({
    required String messageId,
    required String receiverId,
    required String senderId,
    required String propertyId,
  }) async {
    try {
      emit(DeleteMessageInProgress());
      final parameters = {
        'message_id': messageId,
        'receiver_id': receiverId,
        'sender_id': senderId,
        'property_id': propertyId,
      };
      parameters.removeWhere((key, value) => value == '');
      await Api.post(
        url: Api.deleteChatMessage,
        parameter: parameters,
      );

      emit(DeleteMessageSuccess(id: messageId));
    } catch (e) {
      emit(DeleteMessageFail(error: e.toString()));
    }
  }
}
