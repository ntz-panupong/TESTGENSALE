@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help for Condition Price Code'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #A,
  sizeCategory: #S,
  dataClass: #MASTER
}
@Search.searchable: true
define view entity ZI_SD_ZSDCDPRSN_VH
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZDM_SD_ZSDCDPRSN' )
{
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.8
  @EndUserText.label: 'Condition Price Code'
  @UI.textArrangement: #TEXT_FIRST
  @ObjectModel.text.element: ['Description']
  key value_low as ConditionCode,

  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.8
  @EndUserText.label: 'Description'
  @Semantics.text: true
  text      as Description
}
