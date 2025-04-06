import 'package:ebroker/data/cubits/agents/fetch_project_by_agents_cubit.dart';
import 'package:ebroker/data/cubits/agents/fetch_property_by_agent_cubit.dart';
import 'package:ebroker/data/cubits/agents/fetch_property_cubit.dart';
import 'package:ebroker/data/model/agent/agents_properties_models/customer_data.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/agents/agent_properties.dart';
import 'package:ebroker/ui/screens/agents/cards/agents_project_card.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AgentDetailsScreen extends StatefulWidget {
  const AgentDetailsScreen({
    required this.agent,
    required this.isAdmin,
    super.key,
  });
  final bool isAdmin;
  final CustomerData agent;

  static Route route(RouteSettings routeSettings) {
    final argument = routeSettings.arguments! as Map;

    return BlurredRouter(
      builder: (_) => AgentDetailsScreen(
        agent: argument['agent'] as CustomerData,
        isAdmin: argument['isAdmin'] as bool,
      ),
    );
  }

  @override
  State<AgentDetailsScreen> createState() => _AgentDetailsScreenState();
}

class _AgentDetailsScreenState extends State<AgentDetailsScreen> {
  bool isPremiumProperty = true;
  bool isPremiumUser = false;

  @override
  void initState() {
    super.initState();
    context.read<FetchAgentsPropertyCubit>().fetchAgentsProperty(
          agentId: widget.agent.id,
          forceRefresh: true,
          isAdmin: widget.isAdmin,
        );
  }

  @override
  Widget build(BuildContext context) {
    return buildAgentDetails(
      context,
      widget.agent,
    );
  }

  Widget buildAgentDetails(
    BuildContext context,
    CustomerData agent,
  ) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(
        bottomHeight: -4,
        context,
        title: UiUtils.translate(context, 'agentDetails'),
        showBackButton: true,
      ),
      body: BlocConsumer<FetchProjectByAgentCubit, FetchProjectByAgentState>(
        listener: (context, state) {
          if (state is FetchProjectByAgentSuccess) {
            HelperUtils.goToNextPage(
              Routes.projectDetailsScreen,
              context,
              false,
              args: {
                'project': state.project,
              },
            );
          }
        },
        builder: (context, state) {
          return BlocConsumer<FetchPropertyByAgentCubit,
              FetchPropertyByAgentState>(
            listener: (context, state) {
              if (state is FetchPropertyByAgentSuccess) {
                HelperUtils.goToNextPage(
                  Routes.propertyDetails,
                  context,
                  false,
                  args: {
                    'propertyData': state.property,
                  },
                );
              }
            },
            builder: (context, state) {
              return Stack(
                children: [
                  Column(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.15,
                        margin: const EdgeInsets.only(
                          left: 18,
                          right: 18,
                          top: 18,
                        ),
                        decoration: BoxDecoration(
                          color: context.color.secondaryColor,
                          border: Border.all(
                            color: context.color.borderColor,
                            width: 1.5,
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: UiUtils.getImage(
                                  width:
                                      MediaQuery.of(context).size.width * 0.30,
                                  height: double.infinity,
                                  agent.profile,
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    children: [
                                      Flexible(
                                          child: CustomText(
                                        agent.name.firstUpperCase(),
                                        maxLines: 2,
                                        fontWeight: FontWeight.w600,
                                        fontSize: context.font.normal,
                                      )),
                                      const SizedBox(
                                        width: 2,
                                      ),
                                      if (agent.isVerified ?? false)
                                        UiUtils.getSvg(
                                          AppIcons.agentBadge,
                                          height: 24,
                                          width: 24,
                                          color: context.color.tertiaryColor,
                                        ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  CustomText(
                                    agent.email,
                                    fontSize: context.font.small,
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        callButton(context),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        emailButton(context),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      BlocBuilder<FetchAgentsPropertyCubit,
                          FetchAgentsPropertyState>(
                        builder: (context, state) {
                          if (state is FetchAgentsPropertyFailure) {
                            return Container(
                              margin: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * 0.1,
                              ),
                              child: const SomethingWentWrong(),
                            );
                          }
                          if (state is FetchAgentsPropertyLoading) {
                            Center(child: UiUtils.progress());
                          }
                          if (state is FetchAgentsPropertySuccess) {
                            return Container(
                              color: Colors.transparent,
                              height: MediaQuery.of(context).size.height * 0.71,
                              width: MediaQuery.of(context).size.width,
                              child: DefaultTabController(
                                length: 3,
                                child: Column(
                                  children: [
                                    Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.05,
                                      width: double.infinity,
                                      margin: const EdgeInsets.only(
                                        left: 18,
                                        right: 18,
                                        top: 15,
                                      ),
                                      decoration: BoxDecoration(
                                        color: context.color.secondaryColor,
                                        border: Border.all(
                                          color: context.color.borderColor,
                                          width: 1.5,
                                        ),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(8),
                                        ),
                                      ),
                                      child: TabBar(
                                        indicatorPadding: const EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                        ),
                                        indicatorColor:
                                            context.color.tertiaryColor,
                                        labelColor: context.color.tertiaryColor,
                                        unselectedLabelColor:
                                            context.color.inverseSurface,
                                        tabs: [
                                          Tab(
                                            text: UiUtils.translate(
                                              context,
                                              'details',
                                            ),
                                          ),
                                          Tab(
                                            text: UiUtils.translate(
                                              context,
                                              'properties',
                                            ),
                                          ),
                                          Tab(
                                            text: UiUtils.translate(
                                              context,
                                              'projects',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: TabBarView(
                                        physics: AlwaysScrollableScrollPhysics(
                                          parent: BouncingScrollPhysics(),
                                        ),
                                        children: [
                                          detailsTab(
                                            context,
                                            state.agentsProperty.customerData,
                                          ),
                                          AgentProperties(
                                            agentId: state
                                                .agentsProperty.customerData.id,
                                            isAdmin: widget.isAdmin,
                                          ),
                                          AgentProjects(
                                            agentId: state
                                                .agentsProperty.customerData.id,
                                            isAdmin: widget.isAdmin,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                  if (state is FetchPropertyByAgentInProgress)
                    Center(child: UiUtils.progress()),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget detailsTab(BuildContext context, CustomerData customerData) {
    return Container(
      margin: const EdgeInsets.only(
        top: 15,
        left: 18,
        right: 18,
        bottom: 30,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: context.color.secondaryColor,
        border: Border.all(
          color: context.color.borderColor,
          width: 1.5,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(8),
        ),
      ),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              customerData.aboutMe ?? '',
            ),
            const SizedBox(height: 14),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  color: context.color.inverseSurface,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: '${'number'.translate(context)}: ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: customerData.mobile),
                ],
              ),
            ),
            if (locationName(context: context, customerData: customerData)
                .isNotEmpty) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Flexible(
                    child: CustomText('${'location'.translate(context)}: ',
                        fontWeight: FontWeight.w600),
                  ),
                  CustomText(
                      locationName(context: context, customerData: customerData)
                          .join(''),
                      fontWeight: FontWeight.w500),
                ],
              )
            ],
            if (customerData.address!.isNotEmpty &&
                customerData.address != null &&
                customerData.address != 'null') ...[
              const SizedBox(height: 14),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: context.color.inverseSurface,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: '${'operationalArea'.translate(context)}: ',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: customerData.address ?? ''),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  List<String> locationName({
    required BuildContext context,
    required CustomerData customerData,
  }) {
    List<String> location = [
      if (customerData.city!.isNotEmpty) '${customerData.city}',
      if (customerData.state!.isNotEmpty) ...[
        if (customerData.city!.isNotEmpty) ', ',
        '${customerData.state}'
      ],
      if (customerData.country!.isNotEmpty) ...[
        if (customerData.state!.isNotEmpty || customerData.city!.isNotEmpty)
          ',',
        '${customerData.country}',
      ],
    ];

    if (location.isEmpty) {
      return [];
    } else {
      return location;
    }
  }

  Widget callButton(BuildContext context) {
    return UiUtils.buildButton(
      context,
      fontSize: context.font.normal,
      buttonTitle: UiUtils.translate(context, 'call'),
      radius: 5,
      width: MediaQuery.of(context).size.width * 0.25,
      height: MediaQuery.of(context).size.height * 0.038,
      onPressed: _onTapCall,
      prefixWidget: Padding(
        padding: const EdgeInsetsDirectional.only(end: 3),
        child: SizedBox(
          width: 16,
          height: 16,
          child: UiUtils.getSvg(AppIcons.call, color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _onTapCall() async {
    final contactNumber = widget.agent.mobile;
    final url = Uri.parse('tel: +$contactNumber'); //{contactNumber.data}
    try {
      await launchUrl(url);
    } catch (e) {
      throw Exception('Error calling $e');
    }
  }

  Widget emailButton(BuildContext context) {
    return UiUtils.buildButton(
      context,
      fontSize: context.font.normal,
      textColor: context.color.tertiaryColor,
      buttonTitle: UiUtils.translate(context, 'Email'),
      buttonColor: context.color.backgroundColor,
      border: BorderSide(width: 1.5, color: context.color.tertiaryColor),
      radius: 5,
      width: MediaQuery.of(context).size.width * 0.25,
      height: MediaQuery.of(context).size.height * 0.038,
      onPressed: _onTapEmail,
      prefixWidget: Container(
        height: 16,
        width: 16,
        margin: const EdgeInsetsDirectional.only(bottom: 8, end: 12),
        child: Icon(
          Icons.mail_outline,
          color: context.color.tertiaryColor,
        ),
      ),
    );
  }

  Future<void> _onTapEmail() async {
    final email = widget.agent.email;
    final url = Uri.parse('mailto: +$email');
    try {
      await launchUrl(url);
    } catch (e) {
      throw Exception('Error mail $e');
    }
  }
}
