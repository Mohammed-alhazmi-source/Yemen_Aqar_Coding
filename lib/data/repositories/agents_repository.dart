import 'package:ebroker/data/model/agent/agent_model.dart';
import 'package:ebroker/data/model/agent/agent_verification_form_fields_model.dart';
import 'package:ebroker/data/model/agent/agent_verification_form_values_model.dart';
import 'package:ebroker/data/model/agent/agents_property_model.dart';
import 'package:ebroker/data/model/data_output.dart';
import 'package:ebroker/utils/api.dart';
import 'package:ebroker/utils/constant.dart';

class AgentsRepository {
  Future<DataOutput<AgentModel>> fetchAllAgents({
    required int offset,
  }) async {
    final response = await Api.get(
      url: Api.getAgents,
      queryParameters: {
        Api.limit: Constant.loadLimit,
        Api.offset: offset,
      },
    );
    final modelList = (response['data'] as List)
        .map<AgentModel>(
          (e) => AgentModel.fromJson(Map.from(e)),
        )
        .toList();
    return DataOutput(total: response['total'] ?? 0, modelList: modelList);
  }

  Future<({int total, AgentsProperty agentsProperty})> fetchAgentProperties({
    required int offset,
    required int agentId,
    required bool isAdmin,
  }) async {
    final parameters = <String, dynamic>{
      Api.offset: offset,
      Api.limit: Constant.loadLimit,
      Api.id: agentId,
      if (isAdmin) 'is_admin': '1',
    };

    final result = await Api.get(
      url: Api.getAgentProperties,
      queryParameters: parameters,
    );
    final data = result['data'] as Map<String, dynamic>;

    final agentsProperty = AgentsProperty.fromJson(data);
    final total = result['total'] as int? ?? 0;

    return (
      total: total,
      agentsProperty: agentsProperty,
    );
  }

  Future<({int total, AgentsProperty agentsProperty})> fetchAgentProjects({
    required int agentId,
    required int offset,
    required int isProjects,
    required bool isAdmin,
  }) async {
    final parameters = <String, dynamic>{
      Api.offset: offset,
      Api.limit: Constant.loadLimit,
      Api.isProjects: isProjects,
      Api.id: agentId,
      if (isAdmin) 'is_admin': '1',
    };

    final result = await Api.get(
      url: Api.getAgentProperties,
      queryParameters: parameters,
    );
    final data = result['data'] as Map<String, dynamic>;
    final total = result['total'] as int;

    return (
      total: total,
      agentsProperty: AgentsProperty.fromJson(data),
    );
  }

  Future<List<AgentVerificationFormFieldsModel>>
      getAgentVerificationFormFields() async {
    try {
      final result = await Api.get(
        url: Api.getAgentVerificationFormFields,
        useAuthToken: true,
      );

      final modelList = (result['data'] as List)
          .cast<Map<String, dynamic>>()
          .map<AgentVerificationFormFieldsModel>(
            AgentVerificationFormFieldsModel.fromJson,
          )
          .toList();
      return modelList;
    } catch (e) {
      throw Exception('Error fetching agent verification form fields: $e');
    }
  }

  Future<List<AgentVerificationFormValueModel>>
      getAgentVerificationFormValues() async {
    try {
      final result = await Api.get(
        url: Api.apiGetAgentVerificationFormValues,
        useAuthToken: true,
      );

      if (result['data'] is Map<String, dynamic>) {
        final singleModel = AgentVerificationFormValueModel.fromJson(
          result['data'] as Map<String, dynamic>,
        );
        return [singleModel];
      } else if (result['data'] is List) {
        final modelList = (result['data'] as List)
            .cast<Map<String, dynamic>>()
            .map<AgentVerificationFormValueModel>(
              AgentVerificationFormValueModel.fromJson,
            )
            .toList();
        return modelList;
      } else {
        throw Exception('Unexpected data format in API response');
      }
    } catch (e) {
      throw Exception('Error fetching agent verification form values: $e');
    }
  }

  Future createAgentVerification({
    required Map<String, dynamic> parameters,
  }) async {
    final api = Api.apiGetApplyAgentVerification;

    print(parameters);

    return Api.post(url: api, parameter: parameters, useAuthToken: true);
  }
}
