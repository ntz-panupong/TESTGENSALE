@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Coverage LME Price Root Interface View'
define root view entity ZI_SD_ZSDCDP
  as select from zsdtzsd
  association [0..*] to ZI_SD_ZSDCDPITEM   as _Item         on $projection.SalesOrder = _Item.SalesOrder
  association [0..1] to ZI_SD_ZSDCDPRSN_VH as _ConditionVH  on $projection.ConditionCode = _ConditionVH.ConditionCode
  association [0..1] to ZI_SD_ZSDCDP_VH    as _SalesOrderVH on $projection.SalesOrder = _SalesOrderVH.SalesOrder
{
  key coverage_uuid         as CoverageUUID,
      coverage_id           as CoverageID,
      sales_order           as SalesOrder,
      sales_order_item      as SalesOrderItem,
      condition_code        as ConditionCode,
      @Semantics.amount.currencyCode: 'ConditionPriceCurrency'
      condition_value       as ConditionPriceValue,
      condition_currency    as ConditionPriceCurrency,
      document_date         as DocumentDate,
      posting_date          as PostingDate,
      customer_name         as CustomerName,
      delivery_document     as DeliveryDocument,
      overall_status        as OverallStatus,
      status_criticality    as StatusCriticality,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,

      _Item,
      _ConditionVH,
      _SalesOrderVH
}
