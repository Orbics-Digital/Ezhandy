import 'package:ezhandy_user/module/core/all_services/model/provider_service_model.dart';

class ServiceRoutingArgument {
  String? serviceName;
  String? serviceTypeId;
  String? type;
  ProviderServiceModel? service;

  ServiceRoutingArgument({
    this.serviceName,
    this.serviceTypeId,
    this.type,
    this.service,
  });
}
