@EndUserText.label: 'Coverage LME Price Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC_SD_ZSDCDP
  provider contract transactional_query
  as projection on ZI_SD_ZSDCDP
{
  key CoverageUUID,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      CoverageID,

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_SD_ZSDCDP_VH', element: 'SalesOrder' } }]
      SalesOrder,

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      SalesOrderItem,

      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_SD_ZSDCDPRSN_VH', element: 'ConditionCode' } }]
      @ObjectModel.text.element: ['ConditionDescription']
      ConditionCode,
      _ConditionVH.Description as ConditionDescription,

      @Semantics.amount.currencyCode: 'ConditionPriceCurrency'
      ConditionPriceValue,

      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Currency', element: 'Currency' } }]
      ConditionPriceCurrency,

      DocumentDate,
      PostingDate,
      CustomerName,
      DeliveryDocument,
      OverallStatus,
      StatusCriticality,
      CreatedBy,
      CreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,

      _Item,
      _ConditionVH,
      _SalesOrderVH
}
