DECLARE

 lc_result CLOB;
 lc_stmt varchar2(32000);
 type lt_rc is ref cursor;
 lc_cur lt_rc;
 TYPE lr_dp IS RECORD (
 avid NUMBER,
 last_update_date DATE,
 cl_ids cl_id_typ_tab 
  );
  TYPE lr_cl_ids_tab IS TABLE OF lr_dp;
  lt_data lr_cl_ids_tab;
 
BEGIN

pkg_context_api.data_channel_set_param(p_name => 'source_id' , p_value => '8157'); 
pkg_context_api.process_set_param(p_name => 'industry_code' , p_value => 'USSIC|NACE|NAICS|NAICS12|ISIC4'); 
pkg_context_api.process_set_param(p_name => 'industry_desc' , p_value => 'USSIC|NACE|NAICS|NAICS12|ISIC4'); 

lc_stmt := 'WITH avids AS
(SELECT DISTINCT(crc.avid) as avid, to_char(crc.maintained_date,''DD-MON-YYYY'') AS last_update_date
FROM avox_user.central_records crc
WHERE crc.source_id = :b1
AND crc.maintained_date >= :b2
AND crc.avid IS NOT NULL
AND crc.status NOT IN (''DEL'',''DELETED'',''WITHDRAWN'')
AND exists (SELECT NULL FROM avox_user.status_history sh
WHERE sh.cr_id = crc.cr_id
AND sh.status_type = ''SENT'')
)
SELECT avids.avid,avids.last_update_date
,CAST(MULTISET
(SELECT crl.client_record_id
FROM avox_user.central_records crl 
WHERE crl.status NOT IN (''DEL'',''DELETED'',''WITHDRAWN'')
AND crl.source_id = :b1
AND crl.avid = avids.avid) AS avox_user.cl_id_typ_tab ) AS cl_ids 
FROM avids';
OPEN lc_cur FOR lc_stmt USING 103, sysdate -10, 103;
FETCH lc_cur BULK COLLECT INTO lt_data;
CLOSE lc_cur;

dbms_output.put_line('rec count: '||to_char(lt_data.COUNT));
 APEX_JSON.initialize_clob_output;

  apex_json.open_object; -- { document
  --apex_json.write('record', lc_cur);
  apex_json.write('contentTimestamp', to_char(SYSDATE,'yyyymmdd"T"hh24:mi:ss'));
  apex_json.open_array('Entities'); --[
 
for idx in 1..lt_data.count loop
 apex_json.open_object; -- {
  apex_json.write('AVID',lt_data(idx).avid);
--dbms_output.put_line('AVID: '||to_char(lt_data(idx).avid));
apex_json.open_array('RecordIdentifiers'); --[
FOR j IN 1..lt_data(idx).cl_ids.COUNT LOOP
----dbms_output.put_line('cl_id: '||lt_data(idx).cl_ids(j).cl_id);
 apex_json.open_object; -- {
apex_json.WRITE('RecordIdentifier', lt_data(idx).cl_ids(j).cl_id);
apex_json.close_object; -- } 
END LOOP;
apex_json.close_array; --]
--
apex_json.close_object; -- } 
end loop;

  apex_json.close_array; --] Entities
  APEX_JSON.close_object; -- } document

  lc_result := apex_json.get_clob_output;
  APEX_JSON.free_output;
  dbms_output.put_line(lc_result);
  
  pkg_context_api.data_channel_clear_all_context;
  pkg_context_api.process_clear_all_context;

end;
