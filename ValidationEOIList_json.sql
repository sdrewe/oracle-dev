DECLARE

 lc_result CLOB;
 lc_stmt varchar2(32000);
 type lt_rc is ref cursor;
 lc_cur lt_rc;
 TYPE lr_dp IS RECORD (
   cl_id datapoint_obj
 , source_id datapoint_obj
 , avid datapoint_obj
 , cr_id central_Records.cr_id%TYPE, content_timestamp VARCHAR2(100 CHAR), record_status VARCHAR2(100 CHAR)
 , cr_status central_Records.status%TYPE, extract_type VARCHAR2(100 CHAR)
 , datapoints datapoint_tab
  );
  lt_data lr_dp;
 
BEGIN

pkg_context_api.data_channel_set_param(p_name => 'source_id' , p_value => '8157'); 
-- VALIDATION
lc_stmt := 'SELECT crc.client_Record_id AS "recordIdentifier", crc.avid as "AVID"
     FROM avox_user.central_Records crc
                 ,avox_user.status_history sh
    WHERE crc.source_id = 101
        AND crc.status IN (''0'',''170'',''160'',''150'',''0qaqa'',''170qaqa'',''160qaqa'',''150qaqa'')
        AND sh.cr_id = crc.cr_id
        AND sh.status = crc.status';
-- MAINTENANCE WILL NEED A MANUAL JSON WRITER (Oracle generates nested json via XMLType so you get "CL_ID_TYP": {"CL_ID": 383212} )
open lc_cur for lc_stmt;
--FETCH lc_cur INTO lt_data;
 APEX_JSON.initialize_clob_output;

  apex_json.open_object;
  APEX_JSON.write('EOIList', lc_cur);
  APEX_JSON.close_object;

  dbms_output.put_line(apex_json.get_clob_output);
  APEX_JSON.free_output;
--CLOSE lc_cur;

end;