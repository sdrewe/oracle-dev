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

lc_stmt := 'select cl_id,cl_source_id,avid,cr_id,content_timestamp,record_status,cr_status,v_extract_type,
legal_name,legal_form,trading_status,reg_date,diss_date,reg_pobox,reg_floor, reg_building, reg_address1,reg_address2,reg_address3,reg_city, reg_state,reg_country3
from v_6495_getrecord_full_v2 where cr_id = 94351389';
open lc_cur for lc_stmt;
--FETCH lc_cur INTO lt_data;
 APEX_JSON.initialize_clob_output;

  APEX_JSON.open_object;
  APEX_JSON.write('record', lc_cur);
  APEX_JSON.close_object;

  dbms_output.put_line(apex_json.get_clob_output);
  APEX_JSON.free_output;
--CLOSE lc_cur;

end;