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
 , cr_status central_records.status%TYPE, extract_type VARCHAR2(100 CHAR)
 , datapoints datapoint_tab
 , MULTISETS DATAPOINT_TAB
, SERVICE_OPTIONS DATAPOINT_TAB
, spare_data datapoint_tab
 ,metadata datapoint_tab
  );
  lt_data lr_dp;
 
BEGIN

pkg_context_api.data_channel_set_param(p_name => 'source_id' , p_value => '8157'); 
pkg_context_api.process_set_param(p_name => 'industry_code' , p_value => 'USSIC|NACE|NAICS|NAICS12|ISIC4'); 
pkg_context_api.process_set_param(p_name => 'industry_desc' , p_value => 'USSIC|NACE|NAICS|NAICS12|ISIC4'); 

lc_stmt := 'select cl_id,cl_source_id,avid,cr_id,content_timestamp,record_status,cr_status,v_extract_type,
datapoint_tab(avid,legal_name,legal_form,trading_status,reg_date,diss_date,reg_pobox,reg_floor, reg_building, reg_address1,reg_address2,reg_address3,reg_city, reg_state,reg_country3) as datapoints
, previous_names multiset union trades_as multiset union industry_code multiset union industry_desc as multisets
, service_options
, spare_data
,metadata
from v_6495_getrecord_full_v2 where cr_id = :b1';
open lc_cur for lc_stmt using 94351547;
FETCH lc_cur INTO lt_data;
 APEX_JSON.initialize_clob_output;

  apex_json.open_object; -- { document
  --apex_json.write('record', lc_cur);
  apex_json.write('contentTimestamp', lt_data.content_timestamp);
  apex_json.open_array('Entities'); --[
  apex_json.open_object; -- {
  apex_json.write('recordStatus', nvl(lt_data.record_status,'null'));
  if lt_data.avid is not null then
    apex_json.write('managingSource',6495);
  else
    apex_json.write('managingSource',lt_data.source_id.datapointvalue);
  end if;
  apex_json.open_array('DataPoints'); --[ DataPoints
--dbms_output.put_line('DP count: '||to_char(lt_data.datapoints.count));
    --apex_json.open_object; -- { DP
 -- Data points
  for idx in 1..lt_data.datapoints.count loop    
    apex_json.open_object; -- { DP
    apex_json.write('dataPointName', lt_data.datapoints(idx).datapointname);
    apex_json.write('dataPointID', lt_data.datapoints(idx).datapointid);
    apex_json.write('dataPointValue', lt_data.datapoints(idx).datapointvalue);
    apex_json.open_object('ValueMetaData'); -- { ValueMetaData
    
    -- Find the metadata for this Datapoint via the parentdatapointid
    apex_json.open_array('Provenance'); --[ Provenance  
    apex_json.open_object; -- {
    apex_json.close_object; -- } 
    apex_json.close_array; --] Provenance
    
    apex_json.close_object; -- } ValueMetaData
    apex_json.close_object; -- } DP
  end loop; --1..lt_data.datapoints.count
  -- Multisets
dbms_output.put_line('MS count: '||to_char(lt_data.multisets.count));
  for idx in 1..lt_data.multisets.count loop
    apex_json.open_object; -- { DP
    apex_json.write('dataPointName', lt_data.multisets(idx).datapointname);
    apex_json.write('dataPointID', lt_data.multisets(idx).datapointid);
    apex_json.write('dataPointValue', lt_data.multisets(idx).datapointvalue);
    apex_json.close_object; -- } DP
  end loop; --lt_data.multisets.count
  
  -- SPAREx Data

  apex_json.close_array; --] DataPoints
  apex_json.close_object; -- }
  
    -- Service Options
    apex_json.open_object; -- { 
    apex_json.open_array('DataServiceOptions'); --[ DataServiceOptions  
    apex_json.open_object; -- { 
    apex_json.close_object; -- } 
    apex_json.close_array; --] DataServiceOptions
    apex_json.close_object; -- }
  
  apex_json.close_array; --] Entities
  APEX_JSON.close_object; -- } document

  lc_result := apex_json.get_clob_output;
  APEX_JSON.free_output;
  dbms_output.put_line(lc_result);
  
  pkg_context_api.data_channel_clear_all_context;
  pkg_context_api.process_clear_all_context;

end;