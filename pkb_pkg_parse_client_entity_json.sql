create or replace package body pkg_parse_client_entity_json AS

  -- $Author: $
  -- $Date: $
  -- $Rev: $
  -- $URL: $

gc_ievt_code CONSTANT CHAR(6):='INSERT';
gd_eot CONSTANT DATE:=TO_DATE('31-12-9999 00:00:00','DD-MM-YYYY HH24:MI:SS');
gt_module_list pkg_dpcliententity_v2.module_list; -- list of configured module external attribute id's that the source is configured to send
gt_cfd_list pkg_parse_client_entity_json.cfd_spares; -- list of configured SPAREx mapped data points that the source is configured to send
gt_ent_log pkg_entity_process_log.lt_ep_log_type:=pkg_entity_process_log.lt_ep_log_type();
gts_run_ts CONSTANT TIMESTAMP := SYSTIMESTAMP;

FUNCTION get_dssd_spares(p_strcID IN NUMBER) RETURN pkg_parse_client_entity_json.cfd_spares AS

CURSOR c_get_cfd IS
SELECT da.default_column_name, dssd.source_attr_name, da.external_attribute_id
FROM data_source_structure dss
,data_source_structure_def dssd
,data_attribute da
WHERE dss.structure_id = p_strcID
AND dss.structure_id = dssd.source_structure_id
AND dssd.attribute_id = da.attribute_id
AND dssd.source_attr_name IS NOT NULL
AND REGEXP_LIKE(da.default_column_name,'^SPARE[0-9]{1,2}$','c');

lt_return pkg_parse_client_entity_json.cfd_spares;

BEGIN

   OPEN c_get_cfd;
   FETCH c_get_cfd BULK COLLECT INTO lt_return;
   CLOSE c_get_cfd;

   RETURN lt_return;

EXCEPTION
 WHEN others THEN
   IF c_get_cfd%ISOPEN THEN
   CLOSE c_get_cfd;
   END IF;
   RETURN NULL;
END get_dssd_spares;

PROCEDURE add_to_modules(p_csr_id IN NUMBER, p_source_id IN NUMBER, p_cr_status IN VARCHAR2, p_ext_attr_id IN VARCHAR2, p_ext_attr_name IN VARCHAR2, p_attr_value IN VARCHAR2
                                                   , x_modules IN OUT NOCOPY pkg_avoxcliententity.pt_svc_param
                                                   , x_outcome OUT NOCOPY VARCHAR2
                                                   , x_outcome_detail OUT NOCOPY VARCHAR2) IS

ln_hrs NUMBER;
le_skip EXCEPTION;
li_mod_idx PLS_INTEGER:=0;

BEGIN
dbms_output.put_line('In add to modules: '||p_ext_attr_id||' : '||p_attr_value);
  -- Validate the Module Option values submitted
  IF p_ext_attr_id = 'CDA0003' THEN -- RAPID VALIDATION FLAG
    BEGIN
      ln_hrs := TO_NUMBER(p_attr_value);
    EXCEPTION
      WHEN OTHERS THEN
        -- Log value error against RV Hours
       x_outcome := api_return_code(p_lookup_code=>'BAD_REQUEST');
       x_outcome_detail := 'Invalid value for RV Hours: '||p_attr_value;
        RAISE le_skip;
    END;
    IF ln_hrs IS NOT NULL AND validate_rv_value(p_sourceID => p_source_id, p_value => ln_hrs) = 'N' THEN
      -- Log the error for incorrect RV Hours value
      x_outcome := api_return_code(p_lookup_code=>'BAD_REQUEST');
      x_outcome_detail := 'Source not configured for RV Hours value: '||p_attr_value;
      RAISE le_skip;
    END IF;
  -- Only add the other modules where the submitted value  = 'Y'
  ELSIF NVL(p_attr_value,'N') NOT IN ('Y','N') THEN
    -- Log the error for incorrect Module Flag value
    x_outcome := api_return_code(p_lookup_code=>'BAD_REQUEST');
    x_outcome_detail := 'Invalid value for a Module Flag: '||p_attr_value;
    RAISE le_skip;
  END IF;

  -- Checks passed, IF it's Rapid Validation or its another module and value = 'Y' then build the record
  li_mod_idx := x_modules.COUNT + 1;
  -- Set the Rapid Validation specific values
  IF p_ext_attr_id = 'CDA0003' THEN -- RAPID VALIDATION FLAG
    x_modules(li_mod_idx).service_duration_hours := p_attr_value;
    x_modules(li_mod_idx).service_due_ts := get_rv_timestamp(p_start => SYSTIMESTAMP, p_schedule => get_strct_sched(p_src_id => p_source_id)
                                                                                                , p_iterations => x_modules(li_mod_idx).service_duration_hours*60);
  END IF;
  IF p_ext_attr_id = 'CDA0003' OR p_attr_value = 'Y' THEN
    x_modules(li_mod_idx).ent_svc_param_id := ent_svc_param_id_seq.nextval;
    x_modules(li_mod_idx).csr_id := p_csr_id;
    -- For SDA and WS1 compatibilty the service option name needs to be the original name not the Master Field List external name
    CASE p_ext_attr_id
      WHEN 'CDA0007' THEN
        x_modules(li_mod_idx).service_option_name := 'FCA';
      WHEN 'CDA0003' THEN
        x_modules(li_mod_idx).service_option_name := 'RAPID VALIDATION';
      WHEN 'CDA0005' THEN
        x_modules(li_mod_idx).service_option_name := 'EMIR';
      WHEN 'CDA0006' THEN
        x_modules(li_mod_idx).service_option_name := 'DODD FRANK';
      WHEN 'CDA0004' THEN
        x_modules(li_mod_idx).service_option_name := 'FATCA';
    ELSE
      x_modules(li_mod_idx).service_option_name := p_ext_attr_name;
    END CASE;
    x_modules(li_mod_idx).structure_id := get_module_strct_id_v2(p_source_id => p_source_id, p_process_type => 'MDS', p_module => x_modules(li_mod_idx).service_option_name);
    x_modules(li_mod_idx).start_date_active := SYSDATE;
    x_modules(li_mod_idx).end_date_active := gd_eot;
    x_modules(li_mod_idx).anniversary_date := add_months(x_modules(li_mod_idx).start_date_active,12);
    x_modules(li_mod_idx).record_creation_ts := SYSTIMESTAMP;
    --x_modules(li_mod_idx).created_by := gn_user_id;
    x_modules(li_mod_idx).service_option_value := p_attr_value;
    x_modules(li_mod_idx).ovn := 1;
  END IF;

EXCEPTION
  WHEN le_skip THEN
    NULL;
END add_to_modules;

PROCEDURE map_to_spare(p_id IN VARCHAR2, p_value IN VARCHAR2, p_csr_rec IN OUT NOCOPY client_csr%ROWTYPE, x_outcome OUT NOCOPY VARCHAR2) IS

lb_ele_valid BOOLEAN;

BEGIN

    FOR idx IN  1..gt_cfd_list.COUNT LOOP
        IF p_id = gt_cfd_list(idx).element_name THEN
            lb_ele_valid := TRUE;
            -- Map the value to the appropriate SPARE column
           CASE gt_cfd_list(idx).field_name
           WHEN 'SPARE0' THEN
               p_csr_rec.spare0 := p_value;
           WHEN 'SPARE1' THEN
               p_csr_rec.spare1 := p_value;
           WHEN 'SPARE2' THEN
               p_csr_rec.spare2 := p_value;
           WHEN 'SPARE3' THEN
               p_csr_rec.spare3 := p_value;
           WHEN 'SPARE4' THEN
               p_csr_rec.spare4 := p_value;
           WHEN 'SPARE5' THEN
            p_csr_rec.spare5 := p_value;
           WHEN 'SPARE6' THEN
            p_csr_rec.spare6 := p_value;
           WHEN 'SPARE7' THEN
            p_csr_rec.spare7 := p_value;
           WHEN 'SPARE8' THEN
            p_csr_rec.spare8 := p_value;
           WHEN 'SPARE9' THEN
            p_csr_rec.spare9 := p_value;
           WHEN 'SPARE10' THEN
            p_csr_rec.spare10 := p_value;
           WHEN 'SPARE11' THEN
            p_csr_rec.spare11 := p_value;
           WHEN 'SPARE12' THEN
               p_csr_rec.spare12 := p_value;
           WHEN 'SPARE13' THEN
               p_csr_rec.spare13 := p_value;
           WHEN 'SPARE14' THEN
               p_csr_rec.spare14 := p_value;
           WHEN 'SPARE15' THEN
               p_csr_rec.spare15 := p_value;
           WHEN 'SPARE16' THEN
               p_csr_rec.spare16 := p_value;
           WHEN 'SPARE17' THEN
               p_csr_rec.spare17 := p_value;
          WHEN 'SPARE18' THEN
               p_csr_rec.spare18 := p_value;
           WHEN 'SPARE19' THEN
               p_csr_rec.spare19 := p_value;
           WHEN 'SPARE20' THEN
               p_csr_rec.spare20 := p_value;
           ELSE
            -- No CFD mapping found so...
            lb_ele_valid := FALSE;
           END CASE; -- CASE lt_cfd_list(idx).field_name

        END IF; -- p_name = lt_cfd_list(idx).element_name

   END LOOP;

   IF lb_ele_valid THEN
     x_outcome := api_return_code(p_lookup_code=>'SUCCESS');
   ELSE
     x_outcome := api_return_code(p_lookup_code=>'NOT_FOUND');
   END IF;

END map_to_spare;

PROCEDURE map_to_column ( p_dp_id IN VARCHAR2, p_dp_value IN VARCHAR2, p_csr_rec IN OUT NOCOPY client_csr%ROWTYPE
                                                   , p_modules IN OUT NOCOPY pkg_avoxcliententity.pt_svc_param
                                                   , x_client_note OUT NOCOPY VARCHAR2
                                                   , x_outcome OUT NOCOPY VARCHAR2
                                                   , x_outcome_detail OUT NOCOPY VARCHAR2) IS

lc_ext_name data_attribute.external_name%TYPE;

BEGIN

dbms_output.put_line('m2c: '||  p_dp_id);
--dbms_output.put_line('m2c value: '||  p_dp_value);

  -- Map by Datapoint ID
  CASE p_dp_id
    WHEN 'CDA0008' THEN
      p_csr_rec.legal_name := p_dp_value;
    WHEN 'CDA0015' THEN
      p_csr_rec.cl_id := p_dp_value;
    WHEN 'CDA0011' THEN
      p_csr_rec.status := p_dp_value;
    WHEN 'CDA0009' THEN
      p_csr_rec.previous_names := TRIM(BOTH '|' FROM p_csr_rec.previous_names||'|'||p_dp_value);
    WHEN 'CDA0010' THEN
      p_csr_rec.trades_as := TRIM(BOTH '|' FROM p_csr_rec.trades_as||'|'||p_dp_value);
    WHEN 'CDA0052' THEN
      p_csr_rec.reg_country := NVL(p_dp_value,p_csr_rec.reg_country);
    WHEN 'CDA0051' THEN
      p_csr_rec.reg_country := NVL(p_dp_value,p_csr_rec.reg_country);
    WHEN 'CDA0048' THEN
      p_csr_rec.reg_city := p_dp_value;
    WHEN 'CDA0042' THEN
      p_csr_rec.reg_pobox := p_dp_value;
    WHEN 'CDA0043' THEN
      p_csr_rec.reg_floor := p_dp_value;
    WHEN 'CDA0044' THEN
      p_csr_rec.reg_building := p_dp_value;
    WHEN 'CDA0045' THEN
      p_csr_rec.reg_street_1 := p_dp_value;
    WHEN 'CDA0046' THEN
      p_csr_rec.reg_street_2 := p_dp_value;
    WHEN 'CDA0047' THEN
      p_csr_rec.reg_street_3 := p_dp_value;
    WHEN 'CDA0050' THEN
      p_csr_rec.reg_state := p_dp_value;
    WHEN 'CDA0053' THEN
      p_csr_rec.reg_postcode := p_dp_value;
    WHEN 'CDA0039' THEN
        p_csr_rec.op_country := NVL(p_dp_value,p_csr_rec.op_country);
    WHEN 'CDA0038' THEN
        p_csr_rec.op_country := NVL(p_dp_value,p_csr_rec.op_country);
    WHEN 'CDA0035' THEN
      p_csr_rec.op_city := p_dp_value;
    WHEN 'CDA0029' THEN
      p_csr_rec.op_pobox := p_dp_value;
    WHEN 'CDA0030' THEN
      p_csr_rec.op_floor := p_dp_value;
    WHEN 'CDA0031' THEN
      p_csr_rec.op_building := p_dp_value;
    WHEN 'CDA0032' THEN
      p_csr_rec.op_street_1 := p_dp_value;
    WHEN 'CDA0033' THEN
      p_csr_rec.op_street_2 := p_dp_value;
    WHEN 'CDA0034' THEN
      p_csr_rec.op_street_3 := p_dp_value;
    WHEN 'CDA0037' THEN
      p_csr_rec.op_state := p_dp_value;
    WHEN 'CDA0040' THEN
      p_csr_rec.op_postcode := p_dp_value;
    WHEN 'CDA0021' THEN
      p_csr_rec.op_reg_no := p_dp_value;
    WHEN 'CDA0020' THEN
      p_csr_rec.inc_reg_no := p_dp_value;
    WHEN 'CDA0013' THEN
      p_csr_rec.date_of_registration := convert2date(p_dp_value);
    WHEN 'CDA0014' THEN
      p_csr_rec.date_of_dissolution := convert2date(p_dp_value);
    WHEN 'CDA0041' THEN
      p_csr_rec.reg_agent_name := p_dp_value;
    WHEN 'CDA0012' THEN
      p_csr_rec.website := p_dp_value;
    WHEN 'CDA0025' THEN
      p_csr_rec.exchange_name := p_dp_value;
    WHEN 'CDA0024' THEN
      p_csr_rec.ticker_code := p_dp_value;
    WHEN 'CDA0022' THEN
      p_csr_rec.tax_id := p_dp_value;
    WHEN 'CDA0058' THEN
      p_csr_rec.entity_class := p_dp_value;
    WHEN 'CDA0019' THEN
      p_csr_rec.swift_bic := p_dp_value;
    WHEN 'CDA0023' THEN
      p_csr_rec.cik := p_dp_value;
    WHEN 'CDA0059' THEN
      p_csr_rec.naics := p_dp_value;
    WHEN 'CDA0060' THEN
      p_csr_rec.naics_desc := p_dp_value;
    WHEN 'CDA0063' THEN
      p_csr_rec.us_sic := p_dp_value;
    WHEN 'CDA0064' THEN
      p_csr_rec.us_sic_desc := p_dp_value;
    WHEN 'CDA0065' THEN
      p_csr_rec.nace_code := p_dp_value;
    WHEN 'CDA0066' THEN
      p_csr_rec.nace_description := p_dp_value;
    WHEN 'CDA0054' THEN
      p_csr_rec.entity_type := p_dp_value;
    WHEN 'CDA0026' THEN
      p_csr_rec.regulated_by := p_dp_value;
    WHEN 'CDA0028' THEN
      p_csr_rec.regulatory_identifier := p_dp_value;
    WHEN 'CDA0027' THEN
      p_csr_rec.regulatory_classification := p_dp_value;
    WHEN 'CDA0055' THEN
      p_csr_rec.ip_parent_name := p_dp_value;
    WHEN 'CDA0056' THEN
      p_csr_rec.percent_owned_by_parent := p_dp_value;
    WHEN 'CDA0057' THEN
      p_csr_rec.up_parent_name := p_dp_value;
    WHEN 'CDA0018' THEN
      p_csr_rec.lei := p_dp_value;
    WHEN 'CDA0073' THEN
      -- Create a notes entry
      x_client_note := p_dp_value;
    ELSE

      -- Check for module mapping
      IF p_dp_id MEMBER OF gt_module_list THEN

        -- Add to modules list
        lc_ext_name := attribute_ext_name(p_attr_ext_id => p_dp_id);
        add_to_modules(p_csr_id => p_csr_rec.csr_id, p_source_id => p_csr_rec.source_id, p_cr_status => NULL, p_ext_attr_id => p_dp_id, p_ext_attr_name => lc_ext_name, p_attr_value => p_dp_value
                                   , x_modules => p_modules, x_outcome=>x_outcome, x_outcome_Detail => x_outcome_detail);
        IF x_outcome <> api_return_code(p_lookup_code=>'SUCCESS') THEN
          x_outcome_detail := 'Invalid Module Attribute found: '||p_dp_id||' with value: '||p_dp_value;
          RETURN;
        END IF;

--      ELSE
--
--        -- Check for proprietry[sic] SPARE mapping
--        map_to_spare(p_id => p_dp_id, p_value => p_dp_value, p_csr_rec => p_csr_rec, x_outcome => x_outcome);
--        IF x_outcome <> api_return_code(p_lookup_code=>'SUCCESS') THEN
--          x_outcome_detail := 'No Module or SPARE column mapping found for: '||p_dp_id||' with value: '||p_dp_value;
--          RETURN;
--        END IF;

      ELSE
          x_outcome := api_return_code(p_lookup_code=>'NOT_FOUND');
          x_outcome_detail := 'Attribute not configured for source: '||p_dp_id||' value: '||p_dp_value;
          RETURN;
      END IF; -- p_dp_id MEMBER OF gt_module_list

  END CASE; -- p_dp_id

END map_to_column;

/* *** PUBLIC INTERFACE *** */
PROCEDURE json2client_entity( p_json IN CLOB, x_csr IN OUT NOCOPY client_csr%ROWTYPE
                                                     , x_client_notes OUT NOCOPY client_entity_note.note_text%TYPE
                                                     , x_modules OUT NOCOPY pkg_avoxcliententity.pt_svc_param
                                                     , x_outcome OUT NOCOPY VARCHAR2
                                                     , x_outcomeDetail OUT NOCOPY VARCHAR2) IS

jdata apex_json.t_values;
lc_key VARCHAR2(32767);
lc_oc VARCHAR2(30 CHAR);
lc_oc_detail VARCHAR2(1000 CHAR);
lc_dp_id data_attribute.external_attribute_id%TYPE;
lc_dp_value VARCHAR2(4000 BYTE);
lc_client_note client_entity_note.note_text%TYPE;
lb_spare BOOLEAN;

BEGIN

  apex_json.parse(jdata, p_json);
dbms_output.put_line('jdata count: '||to_char(jdata.count));
  -- Get the list of configured modules
  gt_module_list := get_src_modules_v2(p_sourceID =>SYS_CONTEXT('sds_data_channel','source_id'));  
  -- Get the list of configured SPAREs
  gt_cfd_list := get_dssd_spares(p_strcID => SYS_CONTEXT('sds_data_channel','structure_id'));
--    FOR x IN 1..gt_cfd_list.COUNT loop
-- dbms_output.put_line(' spares: '||gt_cfd_list(x).field_name||' '||gt_cfd_list(x).element_name);
--END LOOP;

  -- Loop over the parsed value array and extract the remaining datapoint values into the outbound parameters
  lc_key := jdata.FIRST;
  LOOP
  EXIT WHEN lc_key IS NULL;
    lb_spare := FALSE;
    IF jdata(lc_key).kind = apex_json.c_object OR  jdata(lc_key).kind = apex_json.c_array THEN
      lc_key := jdata.next(lc_key);
      CONTINUE;

    ELSIF (jdata(lc_key).kind = apex_json.c_varchar2 OR jdata(lc_key).kind = apex_json.c_number)
               AND SUBSTR(lc_key,-5) != 'Value' 
               AND SUBSTR(lc_key,1,8) = 'Entities' THEN
      -- Map by ID is preferred but if the name is supplied then get the inbound client attribute ID from RESULT CACHE function (this is NOT the same as the MDS ID for the same datapoint)
      -- Due to the option of using ID or Name or Both this may process an attribute twice if both are passed....not ideal but meets the requirement.
      -- and this could be a SPAREx field
dbms_output.put_line(lc_key||' : '||jdata(lc_key).varchar2_value||' : '||jdata(lc_key).kind);

     FOR x IN 1..gt_cfd_list.COUNT loop
       IF gt_cfd_list(x).element_name = jdata(lc_key).varchar2_value 
         OR gt_cfd_list(x).attr_ext_id = jdata(lc_key).varchar2_value THEN
dbms_output.put_line(lc_key||' : map to spare '||jdata(lc_key).varchar2_value);
         lc_dp_id := gt_cfd_list(x).element_name;
         lb_spare := TRUE;
         EXIT;
       END IF;
     END LOOP;

      IF substr(lc_key,-2) = 'ID' THEN
        IF NOT(lb_spare) THEN
          -- Map the Identifier to the name
          lc_dp_id :=   jdata(lc_key).varchar2_value;        
        END IF; -- lb_spare

      -- Now get the value of the data point from the appropriate location in the json values
--dbms_output.put_line('set value for: '||lc_key);                          
--dbms_output.put_line('get value from: '||REPLACE(lc_key,'dataPointID','dataPointValue'));
    BEGIN
      lc_dp_value := jdata(REPLACE(lc_key,'dataPointID','dataPointValue')).varchar2_value;
--dbms_output.put_line('set varchar2 value: '||lc_dp_value);                          
      IF lc_dp_value IS NULL THEN
        lc_dp_value :=  jdata(REPLACE(lc_key,'dataPointID','dataPointValue')).number_value;
--dbms_output.put_line('set number value: '||lc_dp_value);                    
      END IF;
       EXCEPTION
      WHEN no_data_found THEN
        lc_dp_value := NULL;
    END;
      
  ELSIF substr(lc_key,-4) = 'Name' THEN

    IF lb_spare THEN
      -- Map to the SPARE column
      lc_dp_id := jdata(lc_key).varchar2_value;
    ELSE
      lc_dp_id := attribute_ext_id(p_ext_name => jdata(lc_key).varchar2_value, p_type=> 'C');    
    END IF; -- lb_spare
  
--dbms_output.put_line(lc_key|| ' map by Name: '||lc_dp_id);
      -- Now get the value of the data point from the appropriate location in the json values
--dbms_output.put_line('set value for: '||lc_key);                          
--dbms_output.put_line('get value from: '||REPLACE(lc_key,'dataPointName','dataPointValue'));
    BEGIN
      lc_dp_value := jdata(REPLACE(lc_key,'dataPointName','dataPointValue')).varchar2_value;
--dbms_output.put_line('set varchar2 value: '||lc_dp_value);                          
      IF lc_dp_value IS NULL THEN
        lc_dp_value :=  jdata(REPLACE(lc_key,'dataPointName','dataPointValue')).number_value;
--dbms_output.put_line('set number value: '||lc_dp_value);                    
      END IF;
    EXCEPTION
      WHEN no_data_found THEN
        lc_dp_value := NULL;
    END;
  END IF; -- substr(lc_key,-2) = 'ID'

      IF lc_dp_id IS NULL THEN
        x_outcome := api_return_code(p_lookup_code => 'NOT_FOUND');
	    x_outcomedetail := 'Unable to map attribute with no External ID: '||lc_key;
        RETURN;
      END IF;

      IF lc_dp_id != lc_dp_value THEN
        IF lb_spare THEN
          map_to_spare(p_id => lc_dp_id, p_value => lc_dp_value, p_csr_rec => x_csr, x_outcome => x_outcome);   
        ELSE
          map_to_column (p_dp_id => lc_dp_id
                                   , p_dp_value => lc_dp_value
                                   , p_csr_rec => x_csr
                                   , p_modules => x_modules
                                   , x_client_note => lc_client_note
	                               , x_outcome => x_outcome
	                               , x_outcome_detail => x_outcomeDetail);

          IF x_outcome <> api_return_code(p_lookup_code=>'SUCCESS') THEN
            EXIT;
          END IF;

          IF lc_client_note IS NOT NULL THEN
            x_client_notes := x_client_notes || lc_client_note;
          END IF;
        END IF; -- lb_spare
      END IF; -- lc_dp_id != lc_dp_value

    ELSE
      NULL;
--   dbms_output.put_line(lc_key||' : '||jdata(lc_key).kind);
    END IF;
    lc_key := jdata.NEXT(lc_key);
  END LOOP; -- loop jdata

  gt_module_list.DELETE;
  gt_cfd_list.DELETE;

  IF x_outcome IS NULL THEN
    x_outcome := api_return_code(p_lookup_code => 'SUCCESS');
    x_outcomeDetail := NULL;
  END IF;

--EXCEPTION
--  WHEN OTHERS THEN
--    x_outcome := api_return_code(p_lookup_code => 'UNHANDLED_EXCEPTION');
--	   x_outcomeDetail := SQLERRM;
--	   gt_module_list.DELETE;
--    gt_cfd_list.DELETE;
END json2client_entity;
/* *** END OF PUBLIC INTERFACE *** */
END pkg_parse_client_entity_json;