@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help for Sales Order (Incomplete GR)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #A,
  sizeCategory: #M,
  dataClass: #TRANSACTIONAL
}
@Search.searchable: true
define view entity ZI_SD_ZSDCDP_VH
  as select from I_SalesOrder
{
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.8
  @EndUserText.label: 'Sales Order'
  key SalesOrder,

  @EndUserText.label: 'Order Type'
  SalesOrderType,

  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.8
  @EndUserText.label: 'Customer'
  SoldToParty,

  @EndUserText.label: 'Delivery Status'
  OverallDeliveryStatus
}
where OverallDeliveryStatus <> 'C'
