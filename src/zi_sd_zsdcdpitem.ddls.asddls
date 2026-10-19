@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Condition Items (Read-Only) from Sales Order'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #A,
  sizeCategory: #M,
  dataClass: #TRANSACTIONAL
}
define view entity ZI_SD_ZSDCDPITEM
  as select from I_SalesOrderItemPricingElement as Pricing
  association [1..1] to I_SalesOrderItem as _SalesOrderItem
    on  _SalesOrderItem.SalesOrder     = Pricing.SalesOrder
    and _SalesOrderItem.SalesOrderItem = Pricing.SalesOrderItem
{
  @EndUserText.label: 'Sales Order'
  key Pricing.SalesOrder,

  @EndUserText.label: 'Sales Order Item'
  key Pricing.SalesOrderItem,

  @EndUserText.label: 'Condition Step'
  key Pricing.PricingProcedureStep,

  @EndUserText.label: 'Condition Counter'
  key Pricing.PricingProcedureCounter,

  @EndUserText.label: 'Condition Price Code'
  Pricing.ConditionType                      as ConditionCode,

  @EndUserText.label: 'Condition Price Value'
  @Semantics.amount.currencyCode: 'ConditionCurrency'
  Pricing.ConditionRateValue                 as ConditionValue,

  @EndUserText.label: 'Condition Currency'
  @Semantics.currencyCode: true
  Pricing.TransactionCurrency                as ConditionCurrency,

  @EndUserText.label: 'Material'
  _SalesOrderItem.Material                   as Material,

  @EndUserText.label: 'Material Description'
  _SalesOrderItem.SalesOrderItemText         as MaterialDescription,

  @EndUserText.label: 'Status in Sale Order'
  cast( 'Existing in SO' as abap.char(20) ) as ConditionStatus,

  @EndUserText.label: 'Status Criticality'
  cast( 3 as abap.int1 )                    as StatusCriticality,

  _SalesOrderItem
}
