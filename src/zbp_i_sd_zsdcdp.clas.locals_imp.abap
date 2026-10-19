CLASS lhc_Coverage DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Coverage RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Coverage RESULT result.

    METHODS setInitialStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Coverage~setInitialStatus.

    METHODS setDocumentNumber FOR DETERMINE ON SAVE
      IMPORTING keys FOR Coverage~setDocumentNumber.

    METHODS validateSalesOrder FOR VALIDATE ON SAVE
      IMPORTING keys FOR Coverage~validateSalesOrder.

    METHODS validateCondition FOR VALIDATE ON SAVE
      IMPORTING keys FOR Coverage~validateCondition.

    METHODS createPriceConditionAndUpdate FOR MODIFY
      IMPORTING keys FOR ACTION Coverage~createPriceConditionAndUpdate RESULT result.

ENDCLASS.

CLASS lhc_Coverage IMPLEMENTATION.

  METHOD get_global_authorizations.
    result-%create = if_abap_behv=>auth-allowed.
    result-%update = if_abap_behv=>auth-allowed.
    result-%delete = if_abap_behv=>auth-allowed.
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF zi_sd_zsdcdp IN LOCAL MODE
      ENTITY Coverage
      FIELDS ( OverallStatus ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_coverage).

    result = VALUE #( FOR ls_cov IN lt_coverage
      ( %tky = ls_cov-%tky
        %update = COND #( WHEN ls_cov-OverallStatus = zcl_sd_zsdcdp_action=>gc_status_completed
                          THEN if_abap_behv=>fc-o-disabled
                          ELSE if_abap_behv=>fc-o-enabled )
        %delete = COND #( WHEN ls_cov-OverallStatus = zcl_sd_zsdcdp_action=>gc_status_completed
                          THEN if_abap_behv=>fc-o-disabled
                          ELSE if_abap_behv=>fc-o-enabled )
        %action-createPriceConditionAndUpdate = COND #( WHEN ls_cov-OverallStatus = zcl_sd_zsdcdp_action=>gc_status_completed
                                                       THEN if_abap_behv=>fc-o-disabled
                                                       ELSE if_abap_behv=>fc-o-enabled ) ) ).
  ENDMETHOD.

  METHOD setInitialStatus.
    READ ENTITIES OF zi_sd_zsdcdp IN LOCAL MODE
      ENTITY Coverage
      FIELDS ( OverallStatus StatusCriticality CustomerName SalesOrder ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_coverage).

    DATA lt_update TYPE TABLE FOR UPDATE zi_sd_zsdcdp.

    LOOP AT lt_coverage INTO DATA(ls_cov).
      IF ls_cov-OverallStatus IS INITIAL.
        DATA(lv_cust) = zcl_sd_zsdcdp_action=>get_customer_name( ls_cov-SalesOrder ).
        APPEND VALUE #( %tky = ls_cov-%tky
                        OverallStatus = zcl_sd_zsdcdp_action=>gc_status_incomplete
                        StatusCriticality = zcl_sd_zsdcdp_action=>gc_crit_warning
                        CustomerName = lv_cust
                        %control-OverallStatus = if_abap_behv=>mk-on
                        %control-StatusCriticality = if_abap_behv=>mk-on
                        %control-CustomerName = if_abap_behv=>mk-on ) TO lt_update.
      ENDIF.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_sd_zsdcdp IN LOCAL MODE
        ENTITY Coverage
        UPDATE FROM lt_update.
    ENDIF.
  ENDMETHOD.

  METHOD setDocumentNumber.
    READ ENTITIES OF zi_sd_zsdcdp IN LOCAL MODE
      ENTITY Coverage
      FIELDS ( CoverageID ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_coverage).

    DATA lt_update TYPE TABLE FOR UPDATE zi_sd_zsdcdp.

    LOOP AT lt_coverage INTO DATA(ls_cov).
      IF ls_cov-CoverageID IS INITIAL.
        DATA(lv_next_id) = zcl_sd_zsdcdp_action=>get_next_coverage_id( ).
        APPEND VALUE #( %tky = ls_cov-%tky
                        CoverageID = lv_next_id
                        %control-CoverageID = if_abap_behv=>mk-on ) TO lt_update.
      ENDIF.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_sd_zsdcdp IN LOCAL MODE
        ENTITY Coverage
        UPDATE FROM lt_update.
    ENDIF.
  ENDMETHOD.

  METHOD validateSalesOrder.
    READ ENTITIES OF zi_sd_zsdcdp IN LOCAL MODE
      ENTITY Coverage
      FIELDS ( SalesOrder SalesOrderItem ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_coverage).

    LOOP AT lt_coverage INTO DATA(ls_cov).
      IF ls_cov-SalesOrder IS INITIAL.
        APPEND VALUE #( %tky = ls_cov-%tky ) TO failed-coverage.
        APPEND VALUE #( %tky = ls_cov-%tky
                        %msg = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text     = |กรุณาตรวจสอบข้อมูล Sale Order : { ls_cov-SalesOrder } Item : { ls_cov-SalesOrderItem }| )
                        %element-SalesOrder = if_abap_behv=>mk-on ) TO reported-coverage.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateCondition.
    READ ENTITIES OF zi_sd_zsdcdp IN LOCAL MODE
      ENTITY Coverage
      FIELDS ( SalesOrder SalesOrderItem ConditionCode ConditionPriceValue ConditionPriceCurrency ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_coverage).

    LOOP AT lt_coverage INTO DATA(ls_cov).
      IF ls_cov-ConditionCode IS INITIAL OR
         ls_cov-ConditionPriceValue <= 0 OR
         ls_cov-ConditionPriceCurrency IS INITIAL.
        APPEND VALUE #( %tky = ls_cov-%tky ) TO failed-coverage.
        APPEND VALUE #( %tky = ls_cov-%tky
                        %msg = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text     = |กรุณาตรวจสอบข้อมูล Sale Order : { ls_cov-SalesOrder } Item : { ls_cov-SalesOrderItem }| )
                        %element-ConditionPriceValue = if_abap_behv=>mk-on ) TO reported-coverage.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD createPriceConditionAndUpdate.
    READ ENTITIES OF zi_sd_zsdcdp IN LOCAL MODE
      ENTITY Coverage
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_coverage).

    LOOP AT lt_coverage INTO DATA(ls_cov).
      zcl_sd_zsdcdp_action=>update_sales_order_price(
        EXPORTING
          iv_sales_order = ls_cov-SalesOrder
          iv_item        = ls_cov-SalesOrderItem
          iv_cond_code   = ls_cov-ConditionCode
          iv_cond_value  = ls_cov-ConditionPriceValue
          iv_cond_curr   = ls_cov-ConditionPriceCurrency
        IMPORTING
          ev_success     = DATA(lv_ok)
          ev_message     = DATA(lv_msg)
      ).

      MODIFY ENTITIES OF zi_sd_zsdcdp IN LOCAL MODE
        ENTITY Coverage
        UPDATE FIELDS ( OverallStatus StatusCriticality )
        WITH VALUE #( ( %tky = ls_cov-%tky
                        OverallStatus = zcl_sd_zsdcdp_action=>gc_status_completed
                        StatusCriticality = zcl_sd_zsdcdp_action=>gc_crit_success ) ).

      APPEND VALUE #( %tky = ls_cov-%tky
                      %msg = new_message_with_text(
                        severity = if_abap_behv_message=>severity-success
                        text     = lv_msg ) ) TO reported-coverage.
    ENDLOOP.

    READ ENTITIES OF zi_sd_zsdcdp IN LOCAL MODE
      ENTITY Coverage
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_updated).

    result = VALUE #( FOR ls_updated IN lt_updated ( %tky = ls_updated-%tky %param = ls_updated ) ).
  ENDMETHOD.

ENDCLASS.
