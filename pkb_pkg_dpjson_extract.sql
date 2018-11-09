create or replace PACKAGE BODY pkg_dpjson_extract AS

  -- $Author: $
  -- $Date: $
  -- $Rev: $
  -- $URL: $

gr_structure data_source_structure%ROWTYPE;

CURSOR c_get_mod_defs IS
SELECT dssd.source_structure_id, dssd.attribute_id, dssd.source_attr_name, dssd.attr_file_position, dssd.attr_format_mask, dssd.attr_output_name, dssd.data_source_view_column
                  , dssd.mcm_type, da.external_attribute_id, da.source_id, da.attribute_data_format, da.xml_element_name, da.object_type, da.multiset_attribute, da.attribute_type, da.context_name
                  , da.context_value, dss.structure_data_type
     FROM data_source_structure_def dssd
                 ,data_source_structure dss
                 ,data_attribute da
     WHERE dss.structure_id = gr_structure.structure_id
           AND SYSDATE BETWEEN dss.start_date_active AND dss.end_date_active
           AND SYSDATE BETWEEN dssd.start_date_active AND dssd.end_date_active
           AND da.attribute_type <> 'META'
           AND da.external_attribute_id IS NOT NULL
           AND da.attribute_id = dssd.attribute_id
           AND dssd.source_structure_id = dss.structure_id
UNION
SELECT dssd.source_structure_id, dssd.attribute_id, dssd.source_attr_name, dssd.attr_file_position, dssd.attr_format_mask, dssd.attr_output_name, dssd.data_source_view_column
                  , dssd.mcm_type, da.external_attribute_id, da.source_id, da.attribute_data_format, da.xml_element_name, da.object_type, da.multiset_attribute, da.attribute_type, da.context_name
                  , da.context_value, dssg.structure_data_type
     FROM data_source_structure_def dssd
                 ,data_source_structure dss
                 ,data_source_structure dssg
                 ,data_attribute da
     WHERE dss.structure_id = gr_structure.structure_id
           AND SYSDATE BETWEEN dss.start_date_active AND dss.end_date_active
           AND SYSDATE BETWEEN dssg.start_date_active AND dssg.end_date_active
           AND SYSDATE BETWEEN dssd.start_date_active AND dssd.end_date_active
           AND dssg.group_structure_id = dss.structure_id
           AND da.attribute_type <> 'META'
           AND da.external_attribute_id IS NOT NULL
           AND da.attribute_id = dssd.attribute_id
           AND dssd.source_structure_id = dssg.structure_id
     ORDER BY attr_file_position ASC NULLS LAST;

TYPE lt_defn IS TABLE OF c_get_mod_defs%ROWTYPE INDEX BY BINARY_INTEGER;
gt_defn_tab lt_defn;


/* *** PRIVATE PROGRAM UNITS *** */
PROCEDURE build_stmt(p_modules IN VARCHAR2, x_stmt IN OUT NOCOPY CLOB) IS

lb_spare BOOLEAN:=TRUE;
lb_dp BOOLEAN:=TRUE;
lb_msu BOOLEAN:=TRUE;
lc_ma_list VARCHAR2(2000 CHAR);
lc_dp_list VARCHAR2(32000 CHAR);
li_idx PLS_INTEGER:=0;
TYPE multiset_list IS TABLE OF data_attribute.context_name%TYPE;
lt_multisets multiset_list:=multiset_list();

lt_modules split_tbl;

l_idx pls_integer;

BEGIN

  x_stmt := 'SELECT x.cl_id, x.cl_source_id, x.avid, x.cr_id, x.content_timestamp, x.record_status, x.cr_status';
  IF substr(gr_structure.structure_data_type,1,3) = 'VAL' THEN
    x_stmt := x_stmt || ', x.v_extract_type as extract_type, ';
  ELSIF substr(gr_structure.structure_data_type,1,3) = 'MAI' THEN
    x_stmt := x_stmt || ', x.m_extract_type as extract_type, ';
  ELSE
    x_stmt := x_stmt || ', NULL as extract_type, ';
  END IF;

  -- Build the structure details
  OPEN c_get_mod_defs;
  FETCH c_get_mod_defs BULK COLLECT INTO gt_defn_tab;
  CLOSE c_get_mod_defs;

  lt_modules := split_list_pl (p_list => p_modules, p_del => '|');
--  l_idx := lt_modules.first;
--   while (l_idx is not null) loop
--      dbms_output.put_line( 'Value = ' || lt_modules(l_idx));
--      l_idx := lt_modules.next(l_idx);
--   end loop;

  -- Get the configured fields for this module set and build the select statement, each attribute in the lt_dp_data_tab needs a value even if just NULL
  -- If the structure_data_type is for a module that is not part of the currently selected module list (p_modules) then just add 'NULL as <data_source_view_column>'
  -- to the SELECT statement
  FOR idx IN 1..gt_defn_tab.COUNT LOOP

    IF gt_defn_tab(idx).attribute_type = 'CLIENT' THEN
         lb_spare := FALSE;    
    ELSIF gt_defn_tab(idx).object_type = 'datapoint_obj' THEN

        IF lb_dp THEN
          lc_dp_list := lc_dp_list || ' datapoint_tab(';
          lb_dp := FALSE;
        END IF;

--        IF gt_defn_tab(idx).structure_data_type NOT IN ('VALIDATION','MAINTENANCE','FULL','ADHOC MDS') AND gt_defn_tab(idx).structure_data_type NOT MEMBER OF lt_modules THEN
--          lc_dp_list := lc_dp_list || 'datapoint_obj('''|| gt_defn_tab(idx).source_attr_name ||''','''|| gt_defn_tab(idx).external_attribute_id ||''',null,null,null,null),';
--          CONTINUE;
--        END IF;

        lc_dp_list := lc_dp_list || 'x.'|| CASE 
                                        WHEN gt_defn_tab(idx).attr_format_mask IS NULL THEN
                                        nvl(gt_defn_tab(idx).data_source_view_column,'NULL')||','
                                        ELSE
                                          CASE
                                          WHEN gt_defn_tab(idx).attribute_data_format = 'VARCHAR2' THEN
                                            gt_defn_tab(idx).attr_format_mask||'('||nvl(gt_defn_tab(idx).data_source_view_column,'NULL')||')'||','
                                          WHEN gt_defn_tab(idx).attribute_data_format = 'CHAR' THEN
                                            gt_defn_tab(idx).attr_format_mask||'('||nvl(gt_defn_tab(idx).data_source_view_column,'NULL')||')'||','
                                          WHEN gt_defn_tab(idx).attribute_data_format = 'DATE' THEN
                                            'to_char('||nvl(gt_defn_tab(idx).data_source_view_column,'NULL')||','''|| gt_defn_tab(idx).attr_format_mask||''')'||','
                                          WHEN gt_defn_tab(idx).attribute_data_format = 'TIMESTAMP' THEN
                                            'to_char('||nvl(gt_defn_tab(idx).data_source_view_column,'NULL')||','''|| gt_defn_tab(idx).attr_format_mask||''')'||','
                                          ELSE
                                            nvl(gt_defn_tab(idx).data_source_view_column,'NULL')||','
                                          END 
                                     END;

      ELSIF gt_defn_tab(idx).object_type = 'datapoint_tab' THEN

--        IF gt_defn_tab(idx).structure_data_type NOT IN ('VALIDATION','MAINTENANCE','FULL','ADHOC MDS') AND gt_defn_tab(idx).structure_data_type NOT MEMBER OF lt_modules THEN
--          x_stmt := x_stmt || 'datapoint_tab() AS '||gt_defn_tab(idx).data_source_view_column||',';
--          CONTINUE;
--        END IF;

        -- Multiset attribute that will be a separate datapoint_tab so must be selected on it's own
        -- Each multiset requires a datapoint_tab for the parent record object so may be union'ed into the datapoint_tab
--        IF gt_defn_tab(idx).multiset_attribute = 'Y' THEN
--          -- Add the attribute as a separate select item as the data will be assembled into a datapoint_tab by the view
--          x_stmt := x_stmt || 'x.'||gt_defn_tab(idx).data_source_view_column||',';
--          -- No need to process this attribute any further so...
--          CONTINUE;
--        END IF;
        -- If the object_type is datapoint_tab but the attribute is not a multiset attribute then it's a list of separate attributes of the same type e.g. industry codes so add to the defined 
        -- context value
        IF gt_defn_tab(idx).context_name IS NULL THEN

          IF lb_msu THEN
            lc_ma_list := 'x.' || gt_defn_tab(idx).data_source_view_column ||',';
            lb_msu := FALSE;
          ELSE
            lc_ma_list := RTRIM(lc_ma_list,',') || ' MULTISET UNION ALL x.' || gt_defn_tab(idx).data_source_view_column||',';
          END IF;

        ELSE
          -- Reset the context parameter if there are no contexts in the list.
          IF lt_multisets.COUNT = 0 THEN
            pkg_context_api.process_set_param(p_name => gt_defn_tab(idx).context_name, p_value => NULL);
          END IF;
          -- This is a bit messy but needed to cater for inconsistent naming e.g. NAICS (2002) vs NAICS12 vs NAICS2017 and US SIC vs USSIC and extensible lists like additional industry codes
--dbms_output.put_line('setting '||gt_defn_tab(idx).context_name||' to '||TRIM(BOTH '|' FROM sys_context(pkg_context_api.gc_proc_opt_ctx,gt_defn_tab(idx).context_name)||'|'||
--                                                                                                            gt_defn_tab(idx).context_value));
          pkg_context_api.process_set_param(p_name => gt_defn_tab(idx).context_name
                                                                         , p_value => TRIM(BOTH '|' FROM sys_context(pkg_context_api.gc_proc_opt_ctx,gt_defn_tab(idx).context_name)||'|'||
                                                                                                            gt_defn_tab(idx).context_value));

          -- Need to add the multiset attribute to the multiset union in the select list, this will be the context_name but it only needs adding once regardless of how many more datapoints are in the
          -- complete subscribed list.
          IF gt_defn_tab(idx).context_name NOT MEMBER OF lt_multisets THEN
            lt_multisets.EXTEND;
            li_idx := li_idx + 1;
            lt_multisets(li_idx) := gt_defn_tab(idx).context_name;
            IF lb_msu THEN
              lc_ma_list := 'x.' || gt_defn_tab(idx).context_name ||',';
              lb_msu := FALSE;
            ELSE
              lc_ma_list := RTRIM(lc_ma_list,',') || ' MULTISET UNION ALL x.' || gt_defn_tab(idx).context_name||',';
            END IF;
          END IF; -- gt_defn_tab(idx).context_name NOT MEMBER OF lt_multisets 
        END IF; -- gt_defn_tab(idx).context_name IS NULL

      END IF; -- gt_defn_tab(idx).attribute_type = 'CLIENT' 

    END LOOP; -- 1..gt_defn_tab.COUNT

     -- Add the remaining objects
     -- Note:  the objects must be added in the same order as the type into which they are BULK COLLECTed/FETCHed
     IF lb_dp THEN
      x_stmt := x_stmt || 'datapoint_tab() as datapoints,';
     ELSE
      x_stmt := x_stmt || rtrim(lc_dp_list,',') || ') as datapoints,';
     END IF;
     IF lb_msu THEN
      x_stmt := x_stmt || 'datapoint_tab() as multisets,';
     ELSE
      x_stmt := x_stmt || rtrim(lc_ma_list,',') || ' as multisets,';
     END IF;
     IF lb_spare THEN
      x_stmt := x_stmt || 'datapoint_tab() as sparedata,';
     ELSE
      x_stmt := x_stmt || 'spare_data as sparedata,';
     END IF;
     x_stmt := x_stmt || ' metadata as metadata, changedata as changedata FROM '||
                                      gr_structure.data_source_view_name || ' x WHERE x.cr_id = :b1';

END build_stmt;


PROCEDURE write_datapoint(p_dp IN datapoint_obj, p_prov IN datapoint_tab) IS

BEGIN

  apex_json.open_object; -- { DP
  apex_json.write('dataPointName', p_dp.datapointname);
  apex_json.write('dataPointID', p_dp.datapointid);
  apex_json.write('dataPointValue', p_dp.datapointvalue);
  apex_json.write('qualifier', p_dp.qualifier);
  apex_json.open_object('ValueMetaData'); -- { ValueMetaData
  -- 
  apex_json.open_array('Provenance'); --[ Provenance
  FOR idx IN 1..p_prov.COUNT LOOP
    apex_json.open_object; -- {
    apex_json.write('provenanceName', p_prov(idx).datapointname);
    apex_json.write('provenanceValue', p_prov(idx).datapointvalue);
    apex_json.close_object; -- }
  END LOOP; -- 1..p_prov.COUNT
  apex_json.close_array; --] Provenance
  --
  apex_json.close_object; -- } ValueMetaData
  apex_json.close_object; -- } DP

END write_datapoint;
/* *** END OF PRIVATE PROGRAM UNITS *** */


/* *** PUBLIC INTERFACE *** */
PROCEDURE assemble_record(p_structure IN data_source_structure%ROWTYPE, p_modules IN VARCHAR2, p_cr_id IN NUMBER
                                                   , x_outcome OUT NOCOPY VARCHAR2
												   , x_outcomeDetail OUT NOCOPY VARCHAR2
												   , x_data OUT NOCOPY CLOB
                                                   , x_dss_log_id OUT NOCOPY NUMBER) IS

--ln_cl_cr_id central_records.cr_id%TYPE;
lc_result CLOB;
lc_stmt VARCHAR2(32767);
TYPE lt_rc IS REF CURSOR;
lc_cur lt_rc;
lt_prov_tab datapoint_tab:=datapoint_tab();
lr_data pkg_dpjson_extract.lr_dp;
li_pt_idx PLS_INTEGER;

BEGIN

  IF p_cr_id IS NULL THEN
    x_outcome := api_return_code(p_lookup_code => 'MANDATORY_DATA_MISSING');
    RETURN;
  END IF;
  pkg_context_api.data_channel_set_param(p_name => 'source_id' , p_value => p_structure.source_id); 
  gr_structure := p_structure;
  pkg_context_api.data_channel_set_param(p_name => 'audit_structure_id' , p_value => gr_structure.structure_id); 

  build_stmt(p_modules => p_modules, x_stmt => lc_stmt);
--dbms_output.put_line('STMT: '||lc_stmt);  
--dbms_output.put_line('pcrid: '||p_cr_id);  
  OPEN lc_cur FOR lc_stmt USING p_cr_id;
  FETCH lc_cur INTO lr_data;
  CLOSE lc_cur;
--dbms_output.put_line('C ts: '||lr_data.content_timestamp);  
  -- Initialise a json document CLOB
  APEX_JSON.initialize_clob_output;

  -- Start the json document
  apex_json.open_object; -- { --document
  --apex_json.write('record', lc_cur);
  apex_json.write('contentTimestamp', lr_data.content_timestamp);
  apex_json.open_array('Entities'); --[
  apex_json.open_object; -- {
  apex_json.write('recordStatus', nvl(lr_data.record_status,'null'));
  IF lr_data.avid IS NOT NULL THEN
    apex_json.write('managingSource',6495);
  ELSE
    apex_json.write('managingSource',lr_data.cl_source_id.datapointvalue);
  END IF;

  -- Start the data points array
  apex_json.open_array('DataPoints'); --[ DataPoints
dbms_output.put_line('DP count: '||to_char(lr_data.datapoints.count));
dbms_output.put_line('PROV dp count: '||to_char(lr_data.metadata.COUNT));    
 -- Process the Data points
 write_datapoint(p_dp => lr_data.avid, p_prov => lt_prov_tab);
  FOR idx IN 1..lr_data.datapoints.COUNT LOOP
--dbms_output.put_line('writing dp: '||lr_data.datapoints(idx).datapointname);
	-- Get the Datapoint object and the corresponding Provenance object
	lt_prov_tab.DELETE;
    li_pt_idx := 0;
	FOR j IN 1..lr_data.metadata.COUNT LOOP
	  IF lr_data.metadata(j).parentdatapointid = lr_data.datapoints(idx).datapointid THEN
        li_pt_idx := li_pt_idx + 1;
        lt_prov_tab.EXTEND;
	     lt_prov_tab(li_pt_idx) := lr_data.metadata(j);
--	     EXIT;
	  END IF;
	END LOOP;
    -- Write them to the json output
    write_datapoint(p_dp => lr_data.datapoints(idx), p_prov => lt_prov_tab);

  END LOOP; --1..lt_data.datapoints.count
  -- Multisets
dbms_output.put_line('MS count: '||to_char(lr_data.multisets.count));
  FOR idx IN 1..lr_data.multisets.COUNT LOOP
    -- Get the Datapoint object and the corresponding Provenance object
	lt_prov_tab.DELETE;
    li_pt_idx := 0;
	FOR j IN 1..lr_data.metadata.COUNT LOOP
	  IF lr_data.metadata(j).parentdatapointid = lr_data.multisets(idx).datapointid THEN
	    li_pt_idx := li_pt_idx + 1;
         lt_prov_tab.EXTEND;
	    lt_prov_tab(li_pt_idx) := lr_data.metadata(j);
--	     EXIT;
	  END IF;
	END LOOP;
    -- Write them to the json output
    write_datapoint(p_dp => lr_data.multisets(idx), p_prov => lt_prov_tab);

  END LOOP; --lr_data.multisets.count

  -- SPAREx Data
  lt_prov_tab.DELETE;
  FOR idx IN 1..lr_data.sparedata.COUNT LOOP
    write_datapoint(p_dp => lr_data.datapoints(idx), p_prov => lt_prov_tab);
  END LOOP;

  apex_json.close_array; --] DataPoints
  apex_json.close_object; -- }

  /*
  -- Service Options
  apex_json.open_object; -- { 
  apex_json.open_array('DataServiceOptions'); --[ DataServiceOptions  
  apex_json.open_object; -- { 
   FOR idx IN 1..lr_data.dataserviceoptions.COUNT LOOP
    write_datapoint(p_dp => lr_data.dataserviceoptions(idx), p_prov => NULL);
  END LOOP;
  apex_json.close_object; -- } 
  apex_json.close_array; --] DataServiceOptions
  apex_json.close_object; -- }
*/

  apex_json.close_array; --] Entities
  APEX_JSON.close_object; -- } document

--  x_data := apex_json.get_clob_output;
  x_data := UNISTR(REGEXP_REPLACE(replace(apex_json.get_clob_output,'\/','/'),'\u([A-Z,0-9]{4})',('\1')));
  APEX_JSON.free_output;
--dbms_output.put_line(lc_result);

  pkg_context_api.data_channel_clear_all_context;
  pkg_context_api.process_clear_all_context;

  x_outcome := api_return_code(p_lookup_code => 'SUCCESS');

--EXCEPTION WHEN OTHERS THEN
  --x_outcome := api_return_code(p_lookup_code => 'UNHANDLED_EXCEPTION');
-- x_outcomeDetail := SQLERRM;
END assemble_record;
/* *** END OF PUBLIC INTERFACE *** */

END pkg_dpjson_extract;