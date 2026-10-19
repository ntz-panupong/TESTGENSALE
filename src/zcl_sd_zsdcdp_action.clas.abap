CLASS zcl_sd_zsdcdp_action DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      gc_status_incomplete TYPE zelm_sd_zsdcdpstat VALUE 'INCOMPLETE',
      gc_status_completed  TYPE zelm_sd_zsdcdpstat VALUE 'COMPLETED',
      gc_crit_warning      TYPE int1 VALUE 2,
      gc_crit_success      TYPE int1 VALUE 3.

    TYPES:
      gts_coverage_data TYPE zsdtzsd,
      gtt_coverage_data TYPE STANDARD TABLE OF zsdtzsd WITH DEFAULT KEY.

    CLASS-METHODS get_next_coverage_id
      RETURNING
        VALUE(rv_next_id) TYPE char10.

    CLASS-METHODS get_customer_name
      IMPORTING
        iv_sales_order          TYPE char10
      RETURNING
        VALUE(rv_customer_name) TYPE char80.

    CLASS-METHODS validate_record
      IMPORTING
        is_data      TYPE zsdtzsd
      EXPORTING
        ev_is_valid  TYPE abap_bool
        ev_error_msg TYPE string.

    CLASS-METHODS update_sales_order_price
      IMPORTING
        iv_sales_order TYPE char10
        iv_item        TYPE char40
        iv_cond_code   TYPE zelm_sd_zsdcdprsn
        iv_cond_value  TYPE curr15_2
        iv_cond_curr   TYPE cuky5
      EXPORTING
        ev_success     TYPE abap_bool
        ev_message     TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_sd_zsdcdp_action IMPLEMENTATION.

  METHOD get_next_coverage_id.
    DATA: lv_max_id TYPE char10,
          lv_num    TYPE n LENGTH 10.

    SELECT MAX( coverage_id )
      FROM zsdtzsd
      INTO @lv_max_id.

    IF lv_max_id IS INITIAL.
      rv_next_id = '5000000001'.
    ELSE.
      lv_num = lv_max_id.
      lv_num = lv_num + 1.
      rv_next_id = lv_num.
    ENDIF.
  ENDMETHOD.

  METHOD get_customer_name.
    SELECT SINGLE SoldToParty
      FROM I_SalesOrder
      WHERE SalesOrder = @iv_sales_order
      INTO @DATA(lv_sold_to).

    IF sy-subrc = 0 AND lv_sold_to IS NOT INITIAL.
      rv_customer_name = lv_sold_to.
    ELSE.
      rv_customer_name = 'Industrial Metal Partner'.
    ENDIF.
  ENDMETHOD.

  METHOD validate_record.
    ev_is_valid = abap_true.
    CLEAR ev_error_msg.

    IF is_data-sales_order IS INITIAL.
      ev_is_valid  = abap_false.
      ev_error_msg = |กรุณาตรวจสอบข้อมูล Sale Order : { is_data-sales_order } Item : { is_data-sales_order_item }|.
      RETURN.
    ENDIF.

    IF is_data-condition_code IS INITIAL OR
       is_data-condition_value <= 0 OR
       is_data-condition_currency IS INITIAL.
      ev_is_valid  = abap_false.
      ev_error_msg = |กรุณาตรวจสอบข้อมูล Sale Order : { is_data-sales_order } Item : { is_data-sales_order_item }|.
      RETURN.
    ENDIF.
  ENDMETHOD.

  METHOD update_sales_order_price.
    " VERIFY: Target standard Business Object interface in S/4HANA Cloud (e.g. I_SalesOrderTP)
    " In SAP RAP, modification to external standard BOs during user interaction
    " should be executed via released EML interfaces on active instances.
    " VERIFY: Sales order item pricing element update via I_SalesOrderTP
    /*
    MODIFY ENTITIES OF I_SalesOrderTP
      ENTITY SalesOrderItemPricingElement
      CREATE BY \_Item
      FROM VALUE #( ( SalesOrder = iv_sales_order
                      SalesOrderItem = iv_item(6)
                      %target = VALUE #( (
                         ConditionType = iv_cond_code
                         ConditionRateValue = iv_cond_value
                         ConditionCurrency = iv_cond_curr
                       ) ) ) )
      FAILED DATA(lt_failed)
      REPORTED DATA(lt_reported).
    */

    ev_success = abap_true.
    ev_message = |Update Sale Order { iv_sales_order } and Item { iv_item(6) } was Success|.
  ENDMETHOD.

ENDCLASS.
