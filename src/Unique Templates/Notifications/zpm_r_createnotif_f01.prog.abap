*&---------------------------------------------------------------------*
*&  Include           ZPM_R_CREATENOTIF_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  FETCH_FILEADD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fetch_fileadd .

  "function to provide file path in GUI when value help is requested for the field

  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = sy-repid        " calling program name
      dynpro_number = sy-dynnr        " callign screen number
*     FIELD_NAME    = ' '
    IMPORTING
      file_name     = p_upfile.       " path of the selected file




ENDFORM.                    " FETCH_FILEADD
*&---------------------------------------------------------------------*
*&      Form  FETCH_FILEDATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fetch_filedata .


  "local variable to hold path of file in appropriate format
  lv_upfile = p_upfile.

  "function module to fetch data from text file into internal table
  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                      = lv_upfile            " path of selected file
     filetype                       = 'ASC'                " type of file (ASC means ASCII)
     has_field_separator            = c_x                  " to indicate if field separator has been used (in this case tabstops)
*     HEADER_LENGTH                 = 0
*     READ_BY_LINE                  = 'X'
*     DAT_MODE                      = ' '
*     CODEPAGE                      = ' '
*     IGNORE_CERR                   = ABAP_TRUE
*     REPLACEMENT                   = '#'
*     CHECK_BOM                     = ' '
*     VIRUS_SCAN_PROFILE            =
*     NO_AUTH_CHECK                 = ' '
*     ISDOWNLOAD                    = ' '
*   IMPORTING
*     FILELENGTH                    =
*     HEADER                        =
    TABLES
      data_tab                      = lit_uptab           " internal table to hold data from text file
*   CHANGING
*     ISSCANPERFORMED               = ' '
   EXCEPTIONS
     file_open_error               = 1
     file_read_error               = 2
     no_batch                      = 3
     gui_refuse_filetransfer       = 4
     invalid_type                  = 5
     no_authority                  = 6
     unknown_error                 = 7
     bad_data_format               = 8
     header_not_allowed            = 9
     separator_not_allowed         = 10
     header_too_long               = 11
     unknown_dp_error              = 12
     access_denied                 = 13
     dp_out_of_memory              = 14
     disk_full                     = 15
     dp_timeout                    = 16
     OTHERS                        = 17
            .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  " to delete the headers from the internal table as they are not required

  DELETE lit_uptab INDEX lv_firstrow.  " deleting the header located in the first row from the table


  LOOP AT lit_uptab INTO lwa_uptab.

    " getting data inside lwa_notif_type table from appropiate fields
    SHIFT lwa_uptab-l_notif_typ LEFT DELETING LEADING ' '.  " to delete excess spaces from the field to fit inside the i/p field
    lwa_notif_type-l_notif_type = lwa_uptab-l_notif_typ.
    APPEND lwa_notif_type TO lit_notif_type.         " appending notif_type work area to table

    " getting data inside input notification header from appropriate fields
    lwa_notif_header_in-short_text = lwa_uptab-l_notif_desc.
    lwa_notif_header_in-priority = lwa_uptab-l_priority.
    APPEND lwa_notif_header_in TO lit_notif_header_in.                                " appending modified work area to table

    " getting data inside long text table from appropriate fields
    lwa_notif_longtxt-text_line = lwa_uptab-l_text.
    lwa_notif_longtxt-objtype = 'QMEL'.
    APPEND lwa_notif_longtxt TO lit_notif_longtxt.                                    " appending modified work area to table

    CLEAR :lwa_uptab , lwa_notif_header_in , lwa_notif_longtxt , lwa_notif_type.      " clearing work areas

  ENDLOOP.




ENDFORM.                    " FETCH_FILEDATA
*&---------------------------------------------------------------------*
*&      Form  VALIDATE_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validate_file .

  " to check if filepath has been entered
  IF p_upfile IS INITIAL.
    MESSAGE e000.                     " error message if filepath is blank
  ELSE.
    MESSAGE s001.                     " success message is filepath is entered correctly
  ENDIF.

ENDFORM.                    " VALIDATE_FILE
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_FILEDATA_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_filedata_list .

  " function to display alv in form of a list
  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
   EXPORTING
*     I_INTERFACE_CHECK              = ' '
*     I_BYPASSING_BUFFER             =
*     I_BUFFER_ACTIVE                = ' '
     i_callback_program              = sy-repid                    " program id
*     I_CALLBACK_PF_STATUS_SET       = ' '
     i_callback_user_command         = 'DISPLAY_DETAILS'           " form specfying action in case of interactive event
*     I_STRUCTURE_NAME               =
     is_layout                       = lwa_layout                  " work area which hold layour customizations
     it_fieldcat                     = lit_fcat                    " field catalog table containing details of colomns to be displayed
*     IT_EXCLUDING                   =
*     IT_SPECIAL_GROUPS              =
*     IT_SORT                        =
*     IT_FILTER                      =
*     IS_SEL_HIDE                    =
*     I_DEFAULT                      = 'X'
*     I_SAVE                         = ' '
*     IS_VARIANT                     =
     it_events                       =  lit_events                  " table to hold list of events and their relevant forms
*     IT_EVENT_EXIT                  =
*     IS_PRINT                       =
*     IS_REPREP_ID                   =
*     I_SCREEN_START_COLUMN          = 0
*     I_SCREEN_START_LINE            = 0
*     I_SCREEN_END_COLUMN            = 0
*     I_SCREEN_END_LINE              = 0
*     IR_SALV_LIST_ADAPTER           =
*     IT_EXCEPT_QINFO                =
*     I_SUPPRESS_EMPTY_DATA          = ABAP_FALSE
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER        =
*     ES_EXIT_CAUSED_BY_USER         =
    TABLES
      t_outtab                       = lit_alv_output               " table where output details to be displayed are stored
   EXCEPTIONS
     program_error                  = 1
     OTHERS                         = 2
            .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


ENDFORM.                    " DISPLAY_FILEDATA_LIST
*&---------------------------------------------------------------------*
*&      Form  CREATE_NOTIF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_notif .


  LOOP AT lit_notif_header_in INTO lwa_notif_header_in.

    " reading notification type into the work area
    READ TABLE lit_notif_type INTO lwa_notif_type INDEX sy-tabix.          " reading notification table into work area to get notification type
    IF sy-subrc NE 0.
      MESSAGE e002.                                                        " displaying error message when the notification type is not specified
    ENDIF.

    " reading long texts into input table for create notification bapi
    READ TABLE lit_notif_longtxt INTO lwa_notif_longtxt INDEX sy-tabix.    " get the long texts one by one into the input table to create notification bapi
    IF sy-subrc NE 0.
      MESSAGE i005.                                                        " displaying Information message when the long text  is not specified
    ENDIF.

    APPEND lwa_notif_longtxt TO lit_notif_longtext2.                       " appending teh long texts to the input table for create notification bapi

    " function module to create bapi with temporary notification number
    CALL FUNCTION 'BAPI_ALM_NOTIF_CREATE'
      EXPORTING
*       EXTERNAL_NUMBER               =
        notif_type                    = lwa_notif_type-l_notif_type        " notification type
        notifheader                   = lwa_notif_header_in                " input notification information
*       TASK_DETERMINATION            = ' '
*       SENDER                        =
*       ORDERID                       =
*       IV_DONT_CHK_MANDATORY_PARTNER =
      IMPORTING
        notifheader_export            = lwa_notif_header_out_temp          " notification header with temporary notification number
      TABLES
*       NOTITEM                       =
*       NOTIFCAUS                     =
*       NOTIFACTV                     =
*       NOTIFTASK                     =
*       NOTIFPARTNR                   =
        longtexts                     = lit_notif_longtext2                " table which contains long text for notification
*       KEY_RELATIONSHIPS             =
        return                        = lit_create_return.                 " table to hold error messages

    IF lit_create_return IS INITIAL.
      " function module to save notification
      Clear lwa_notif_header_out.
      CALL FUNCTION 'BAPI_ALM_NOTIF_SAVE'
        EXPORTING
          number              = lwa_notif_header_out_temp-notif_no           " giving temporary notification number as input
*         TOGETHER_WITH_ORDER = ' '
        IMPORTING
          notifheader         = lwa_notif_header_out                         " getting notification header alogn with notification number
        TABLES
          return              = lit_save_return.                             " return table to hold error messages

      " function module to commit changes
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*      EXPORTING
*        WAIT   = 'X'
        IMPORTING
          return = lwa_commit_return.                                        " return work area to hold error messages

      MOVE-CORRESPONDING lwa_notif_header_out TO lwa_alv_output.             " moving the notification header fields to output alv table
      APPEND lwa_commit_return TO lit_commit_return.                         " appending error information to table


    ENDIF.

    " if there are no errors in creating and saving the notification
    IF lit_save_return IS INITIAL AND lit_create_return IS INITIAL.

      lwa_alv_output-comments = lv_comments.                               " assigning success message to output alv workarea
      APPEND lwa_alv_output TO lit_alv_output.                             " appending the modified work area to input alv table

      " if there is a problem in creating a notification
    ELSEIF lit_create_return IS NOT INITIAL AND lit_save_return IS INITIAL OR lit_save_return IS NOT INITIAL.

      READ TABLE lit_create_return INTO lwa_create_return INDEX lv_firstrow." fetching error data from create notification bapi return table
      IF sy-subrc NE 0.
        MESSAGE e003.                                                      "  displaying error message if there is error in retriving data from table
      ENDIF.

      lwa_alv_output-comments = lwa_create_return-message.                 " assigning error message to output alv work area
      APPEND lwa_alv_output TO lit_alv_output.                             " appending the modified work area to input alv table

      " if there is a problem in saving the notification
    ELSEIF lit_create_return IS INITIAL AND lit_save_return IS NOT INITIAL." fetching error data from save notification bapi return table

      READ TABLE lit_save_return INTO lwa_save_return INDEX lv_firstrow.   " fetching error data from create notification bapi return table
      IF sy-subrc NE 0.
        MESSAGE e004.                                                      "  displaying error message if there is error in retriving data from table
      ENDIF.

      lwa_alv_output-comments = lwa_save_return-message.                   " assigning error message to output alv work area
      APPEND lwa_alv_output TO lit_alv_output.                             " appending the modified work area to input alv table

    ENDIF.

    CLEAR : lwa_commit_return , lwa_notif_header_out , lwa_notif_header_out_temp ,lwa_notif_header_in,  " clearing all the work areas and certain tables used in the loop
            lwa_notif_type,lit_create_return,lit_save_return, lit_notif_longtext2.
  ENDLOOP.
ENDFORM.                    " CREATE_NOTIF
*&---------------------------------------------------------------------*
*&      Form  POPULATE_ALVDATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM populate_alvdata .

  " populating alv in appropriate format

  lwa_fcat-col_pos   = '1'.                                       " position of the colom
  lwa_fcat-fieldname = 'NOTIF_NO'.                                " name of the field to be displayed
  lwa_fcat-tabname   = 'lit_alv_output'.                          " name of the table where the above field is located
  lwa_fcat-ref_fieldname = 'QMNUM'.                               " reference field name to be displayed
  lwa_fcat-ref_tabname = 'QMEL'  .                                " reference field table which contains the reference field
  APPEND lwa_fcat TO lit_fcat.                                    " appending the details to the field catalog table

  CLEAR lwa_fcat.                                                 " clearing work area to avoid conflicts

  lwa_fcat-col_pos   = '2'.                                       " position of the colom
  lwa_fcat-fieldname = 'NOTIF_DATE'.                              " name of the field to be displayed
  lwa_fcat-tabname   = 'lit_alv_output'.                          " name of the table where the above field is located
  lwa_fcat-ref_fieldname = 'QMDAT'.                               " reference field name to be displayed
  lwa_fcat-ref_tabname = 'QMEL'  .                                " reference field table which contains the reference field
  APPEND lwa_fcat TO lit_fcat.                                    " appending the details to the field catalog table
  CLEAR lwa_fcat.                                                 " clearing work area to avoid conflicts

  lwa_fcat-col_pos   = '7'.                                       " position of the colom
  lwa_fcat-fieldname = 'COMMENTS'.                                " name of the field to be displayed
  lwa_fcat-tabname   = 'lit_alv_output'.                          " name of the table where the above field is located
  lwa_fcat-seltext_m = 'COMMENTS'.                                " text to be displayed as the header
  lwa_fcat-outputlen = 100.                                       " changing output length of colomn to fit the text
  APPEND lwa_fcat TO lit_fcat.                                    " appending the details to the field catalog table
  CLEAR lwa_fcat.                                                 " clearing work area to avoid conflicts

ENDFORM.                    " POPULATE_ALVDATA
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DETAILS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_details USING r_syucomm LIKE sy-ucomm rs_selfield TYPE slis_selfield.

  " 1.r_syucomm is for holding value when interactive event is called
  " 2.rs_selfield is for holding relevant clicked field values

  IF r_syucomm = '&IC1'.                                                   " triggered on double click
    READ TABLE lit_alv_output INTO lwa_alv_output INDEX rs_selfield-tabindex. " getting the relevant data fetched into the work area
    SET PARAMETER ID 'IQM' FIELD lwa_alv_output-notif_no.                  " setting the parameter of IW23 with relevant values
    CALL TRANSACTION 'IW23' AND SKIP FIRST SCREEN.                                               " calling transaction for displaying notification
  ENDIF.




ENDFORM.                    " DISPLAY_DETAILS
*&---------------------------------------------------------------------*
*&      Form  FORMATTING_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM formatting_alv .

  " function module which holds the list of events possible in alv

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
*   EXPORTING
*     I_LIST_TYPE           = 0
   IMPORTING
     et_events             =  lit_events               " table holding list of events
*   EXCEPTIONS
*     LIST_TYPE_WRONG       = 1
*     OTHERS                = 2
            .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  READ TABLE lit_events INTO lwa_events WITH KEY name =  slis_ev_top_of_page. " getting top of page event in the work area
  IF sy-subrc NE 0.
    MESSAGE i006.                                      " displaying information message if event does not exist
  ENDIF.

  lwa_events-form = 'TOP_OF_PAGE'.                     " specifying the form name which holds header information
  APPEND lwa_events TO lit_events.


  " applyign zebra layout to alv
  lwa_layout-zebra = 'X'.



ENDFORM.                    " FORMATTING_ALV

*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM top_of_page .

  " typ has two values H & S
  "  H : ignores key field
  "  S : takes into account both key and info

  lwa_header-typ  = 'H'.
  lwa_header-info = 'NOTIFICATION CREATION REPORT'.         " header to be displayed on Top Of Page

  APPEND lwa_header TO lit_header.
  CLEAR lwa_header.

  lwa_header-typ = 'S'.
  lwa_header-key = 'DATE OF GENERATION OF REPORT : '.
  lwa_header-info = sy-datum.                               " current date to be displayed

  APPEND lwa_header TO lit_header.
  CLEAR lwa_header.


  " function module to write data in ALV report

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lit_header
*     I_LOGO             =
*     I_END_OF_LIST_GRID =
*     I_ALV_FORM         =
    .

ENDFORM.                    "TOP_OF_PAGE
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_FILEDATA_GRID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_filedata_grid .


  " function module to display data in alv in form of a grid

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
   EXPORTING
*     I_INTERFACE_CHECK                 = ' '
*     I_BYPASSING_BUFFER                = ' '
*     I_BUFFER_ACTIVE                   = ' '
     i_callback_program                 = sy-repid                      " program id
*     I_CALLBACK_PF_STATUS_SET          = ' '
     i_callback_user_command            = 'DISPLAY_DETAILS'             " form specfying action in case of interactive event
     i_callback_top_of_page             = 'TOP_OF_PAGE'                 " form containing header information
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME                  =
*     I_BACKGROUND_ID                   = ' '
*     I_GRID_TITLE                      =
*     I_GRID_SETTINGS                   =
     is_layout                          =  lwa_layout                   " work area which hold layour customizations
     it_fieldcat                        =  lit_fcat                     " field catalog table containing details of colomns to be displayed
*     IT_EXCLUDING                      =
*     IT_SPECIAL_GROUPS                 =
*     IT_SORT                           =
*     IT_FILTER                         =
*     IS_SEL_HIDE                       =
*     I_DEFAULT                         = 'X'
*     I_SAVE                            = ' '
*     IS_VARIANT                        =
     it_events                          =  lit_events                   " events table for holding events possible in alv
*     IT_EVENT_EXIT                     =
*     IS_PRINT                          =
*     IS_REPREP_ID                      =
*     I_SCREEN_START_COLUMN             = 0
*     I_SCREEN_START_LINE               = 0
*     I_SCREEN_END_COLUMN               = 0
*     I_SCREEN_END_LINE                 = 0
*     I_HTML_HEIGHT_TOP                 = 0
*     I_HTML_HEIGHT_END                 = 0
*     IT_ALV_GRAPHICS                   =
*     IT_HYPERLINK                      =
*     IT_ADD_FIELDCAT                   =
*     IT_EXCEPT_QINFO                   =
*     IR_SALV_FULLSCREEN_ADAPTER        =
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER           =
*     ES_EXIT_CAUSED_BY_USER            =
    TABLES
      t_outtab                          = lit_alv_output                 " table containing data to be displayed in ALV
*   EXCEPTIONS
*     PROGRAM_ERROR                     = 1
*     OTHERS                            = 2
            .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.



ENDFORM.                    " DISPLAY_FILEDATA_GRID
*&---------------------------------------------------------------------*
*&      Form  CREATE_NOTIF_DIFFERENT_BAPI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_notif_different_bapi .


  LOOP AT lit_uptab INTO lwa_uptab.

    SHIFT lwa_uptab-l_notif_typ LEFT DELETING LEADING ' '.
    lwa_iqs4notif_header_in-qmart = lwa_uptab-l_notif_typ.
    lwa_iqs4notif_header_in-qmtxt = lwa_uptab-l_notif_desc.
    lwa_iqs4notif_header_in-priok = lwa_uptab-l_priority.

*    APPEND lwa_iqs4notif_header_in TO lit_iqs4notif_header_in.
*
*  ENDLOOP.

    CALL FUNCTION 'IQS4_CREATE_NOTIFICATION'
      EXPORTING
*       I_QMNUM            =
*       I_AUFNR            =
        i_riqs5            = lwa_iqs4notif_header_in
*       I_TASK_DET         = ' '
*       I_CONV             = ' '
*       I_BIN_RELATIONSHIP = ' '
*       I_SENDER           =
*       I_POST             = 'X'
       I_COMMIT            = c_x
*       I_WAIT             = ' '
*       I_REFRESH_COMPLETE = 'X'
*       I_CHECK_PARNR_COMP = 'X'
*       I_RFC_CALL         = ' '
*       I_RBNR             = ' '
      IMPORTING
        e_viqmel           = lwa_iqs4notif_header_out
*       E_RIWO03           =
      TABLES
*       I_INLINES_T        =
*       I_VIQMFE_T         =
*       I_VIQMUR_T         =
*       I_VIQMSM_T         =
*       I_VIQMMA_T         =
*       I_IHPA_T           =
*       E_KEYS             =
*       E_BIN_RELATION_TAB =
        return             = lit_create_return.

    APPEND lwa_iqs4notif_header_out TO lit_iqs4notif_header_out.

    IF lit_create_return IS INITIAL.
      lwa_alv_output-notif_date = lwa_iqs4notif_header_out-qmdat.
      lwa_alv_output-notif_no = lwa_iqs4notif_header_out-qmnum.
      lwa_alv_output-comments = lv_comments.                               " assigning success message to output alv workarea
      APPEND lwa_alv_output TO lit_alv_output.                             " appending the modified work area to input alv table
    ELSEIF lit_create_return IS NOT INITIAL.

      READ TABLE lit_create_return INTO lwa_create_return INDEX lv_firstrow." fetching error data from create notification bapi return table
      IF sy-subrc NE 0.
        MESSAGE e003.                                                      "  displaying error message if there is error in retriving data from table
      ENDIF.
      lwa_alv_output-comments = lwa_create_return-message.
      APPEND lwa_alv_output TO lit_alv_output.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " CREATE_NOTIF_DIFFERENT_BAPI
