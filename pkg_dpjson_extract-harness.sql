declare

LC_RES clob;
lc_oc VARCHAR2(30 CHAR);
lc_ocDetail varchar2(300 char);
lc_mods varchar2(1000 char):= 'MDS';
LN_DSS_LOG_ID number;
LN_CR_ID number:= 94351611;
lr_struc data_source_structure%ROWTYPE;

BEGIN

SELECT * INTO lr_struc FROM data_source_structure WHERE structure_type = '117_GETRECORD_FULL_API';
lr_struc.data_source_view_name := 'v_6495_getrecord_full_v2';
lr_struc.source_id := 8157;

FOR I IN 1..1000 LOOP
pkg_dpjson_extract.assemble_record(p_structure => lr_struc, p_modules => lc_mods, p_cr_id => ln_cr_id
, x_outcome => lc_oc, x_outcomedetail => lc_ocdetail, x_data => lc_res, x_dss_log_id => ln_dss_log_id);
END LOOP;

DBMS_OUTPUT.PUT_LINE(LC_OC);
--DBMS_OUTPUT.PUT_LINE(LC_RES);
--DBMS_OUTPUT.PUT_LINE(unistr(regexp_replace('ABC\u0026qw','\u([A-Z,0-9]{4})','\1')));
--DBMS_OUTPUT.PUT_LINE(regexp_replace(LC_RES,'\u([A-Z,0-9]{4})','\1'));

--LC_RES := UNISTR(REGEXP_REPLACE(replace(LC_RES,'\/','\\'),'\u([A-Z,0-9]{4})',('\1'))); -- outputs valid json according to jsonlint.com
--LC_RES := replace(UNISTR(REGEXP_REPLACE(replace(LC_RES,'\/','\\'),'\u([A-Z,0-9]{4})',('\1'))),'\','\/'); -- doesn't cater for forward slash correctly, it converts them to back slash
--LC_RES := UNISTR(REGEXP_REPLACE(replace(LC_RES,'\/','/'),'\u([A-Z,0-9]{4})',('\1')));
--DBMS_OUTPUT.PUT_LINE(LC_RES);

--LX_XML := APEX_JSON.TO_XMLTYPE(P_SOURCE => LC_RES, P_STRICT=>false);
--dbms_output.put_line(substr(lx_xml.getCLobVal(),1,4000));
--pkg_context_api.data_channel_clear_all_context;

END;