CREATE OR REPLACE VIEW "AVOX_USER"."V_6495_GETRECORD_FULL_V2" AS 

----------------------------------------------------------------------------------------------------------------------------------
--
-- $Author: mbailey $
-- $Date: 2018-09-27 14:31:16 +0100 (Thu, 27 Sep 2018) $
-- $Revision: 7018 $
-- $URL: http://svn.avox.national/svn/era-database/trunk/Views/v_6495_getrecord_full_v2.sql $
--
-- Date         Initials  JIRA      Description
-- -----------  --------  --------  ----------------------------------------------------------------------------------------------
-- 21-08-2018   MB        CD-372    1. Changed format on all date fields that were being output in DD-Mon-YYYY format to come out
--                                     in YYYY-MM-DD format (ISO-8601).
--                                  2. Replaced the existing call to function get_service_options to individual calls to the new
--                                     get_service_options. We now have an individual call for each service.
-- 13-09-2018   MB        CD-365    1. Added module flags for 'ana credit full' and 'ana credit complete'.
-- 
----------------------------------------------------------------------------------------------------------------------------------

    SELECT
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'CL_ID'),attribute_ext_id(p_xml_element_name => 'CL_ID'),cr.client_record_id,NULL,NULL,NULL) AS cl_id,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'CL_SOURCE_ID'),attribute_ext_id(p_xml_element_name => 'CL_SOURCE_ID'),cr.source_id,NULL,NULL,NULL) AS cl_source_id,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'AVID'),attribute_ext_id(p_xml_element_name => 'AVID'),cr.avid,NULL,NULL,NULL) AS avid,
        cr.cr_id AS cr_id,
        cr.status AS cr_status,
        --pkg_entity_utils.map_single_attr(p_primary_attr => 'RecordIdentifierStatus', p_prim_source_id => 6495, p_mapped_attr => SYS_CONTEXT('sds_data_channel','stsattr'), p_mapped_source_id => SYS_CONTEXT('sds_data_channel','source_id') ,p_primary_value => cr.status) 
        NULL AS record_status,
        TO_CHAR(systimestamp,'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS content_timestamp,
        -- CLIENT_CSR data for Validation Extract Type determination
        v_extract_type(p_avid => ae.avid,p_client_rec => v_ext_type_obj(cc.source_id,cc.legal_name,cc.status,cc.website,cc.op_pobox,cc.op_floor,cc.op_building,cc.op_street_1,cc.op_street_2,cc.op_street_3,cc.op_city,cc.op_state,cc.op_country,cc.op_postcode,cc.op_reg_no,cc.inc_reg_no,cc.date_of_registration,cc.date_of_dissolution,cc.reg_agent_name,cc.reg_pobox,cc.reg_floor,cc.reg_building,cc.reg_street_1,cc.reg_street_2,cc.reg_street_3,cc.reg_city,cc.reg_state,cc.reg_country,cc.reg_postcode,cc.tax_id,cc.exchange_name,cc.ticker_code,cc.entity_class,cc.swift_bic,cc.cik,cc.naics,cc.naics_desc,cc.us_sic,cc.us_sic_desc,cc.nace_code,cc.nace_description,cc.entity_type,cc.ip_parent_name,cc.percent_owned_by_parent,cc.up_parent_name,cc.regulated_by,cc.regulatory_identifier,cc.regulatory_classification,cc.lei),p_avid_rec => v_ext_type_obj(6495,ae.legal_name,ae.trading_status,ae.company_website,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,op.country_code,op.post_code,NULL,NULL,ae.date_of_registration,ae.date_of_dissolution,reg.agent_name,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,reg.country_code,reg.post_code,NULL,ae.primary_exchange_name,NULL,ae.entity_class,ai.identifier_value,NULL,NULL,NULL,NULL,NULL,NULL,NULL,DECODE(ae.entity_type,'TP','Ultimate Parent','LE','Subsidiary','BRA','Branch','SLE','Branch','DIV','Division',ae.entity_type),ipe.legal_name,ip.percentage_of_child_owned,upe.legal_name,ae.regulated_by,ae.regulatory_identifier,ae.regulatory_classification,lei.record_identifier),p_dssid => sys_context('sds_data_channel','structure_id') ) AS v_extract_type,
	    -- Maintenance Extract Type
        m_extract_type(p_avid => ae.avid,p_dssid => sys_context('sds_data_channel','structure_id'),p_sourceid => cr.source_id,p_change_date => TO_DATE(sys_context('sds_data_channel','eff_date'),'YYYY-MM-DD"T"HH24:MI:SS"Z"'),p_ip_avid => ipe.avid,p_up_avid => upe.avid) AS m_extract_type,
        -- Datapoints
        datapoint_obj(attribute_ext_name(p_attr_name => 'LEGAL NAME'),attribute_ext_id(p_attr_name => 'LEGAL NAME'),ae.legal_name,NULL,NULL,NULL) AS legal_name,
        datapoint_obj(attribute_ext_name(p_attr_name => 'LEGAL FORM'),attribute_ext_id(p_attr_name => 'LEGAL FORM'),ae.legal_form,NULL,NULL,NULL) AS legal_form,
        datapoint_obj(attribute_ext_name(p_attr_name => 'STATUS'),attribute_ext_id(p_attr_name => 'STATUS'),ae.trading_status,NULL,NULL,NULL) AS trading_status,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'REG_POBOX'),attribute_ext_id(p_xml_element_name => 'REG_POBOX'),reg.pobox,NULL,NULL,NULL) AS reg_pobox,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'REG_FLOOR'),attribute_ext_id(p_xml_element_name => 'REG_FLOOR'),reg.floor,NULL,NULL,NULL) AS reg_floor,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'REG_BUILDING'),attribute_ext_id(p_xml_element_name => 'REG_BUILDING'),reg.building,NULL,NULL,NULL) AS reg_building,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'REG_ADDRESS1'),attribute_ext_id(p_xml_element_name => 'REG_ADDRESS1'),reg.address_1,NULL,NULL,NULL) AS reg_address1,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'REG_ADDRESS2'),attribute_ext_id(p_xml_element_name => 'REG_ADDRESS2'),reg.address_2,NULL,NULL,NULL) AS reg_address2,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'REG_ADDRESS3'),attribute_ext_id(p_xml_element_name => 'REG_ADDRESS3'),reg.address_3,NULL,NULL,NULL) AS reg_address3,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'REG_CITY'),attribute_ext_id(p_xml_element_name => 'REG_CITY'),reg.city,NULL,NULL,NULL) AS reg_city,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'REG_STATE'),attribute_ext_id(p_xml_element_name => 'REG_STATE'),reg.state,NULL,NULL,NULL) AS reg_state,
        --reg_state_name
        --reg_iso_state
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'REG_COUNTRY'),attribute_ext_id(p_xml_element_name => 'REG_COUNTRY'),pkg_utils.get_country_2_from_3(reg.country_code),NULL,NULL,NULL) AS reg_country,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'REG_COUNTRY3'),attribute_ext_id(p_xml_element_name => 'REG_COUNTRY3'),reg.country_code,NULL,NULL,NULL) AS reg_country3,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'REG_COUNTRY_NAME'),attribute_ext_id(p_xml_element_name => 'REG_COUNTRY_NAME'),DECODE(pkg_utils.get_country_name_from_3(reg.country_code),'NULL',NULL,pkg_utils.get_country_name_from_3(reg.country_code) ),NULL,NULL,NULL) AS reg_country_name,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'REG_POSTCODE'),attribute_ext_id(p_xml_element_name => 'REG_POSTCODE'),reg.post_code,NULL,NULL,NULL) AS reg_postcode,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'REG_AGENT_NAME'),attribute_ext_id(p_xml_element_name => 'REG_AGENT_NAME'),reg.agent_name,NULL,NULL,NULL) AS reg_agent_name,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'INC_REG_NO'),attribute_ext_id(p_xml_element_name => 'INC_REG_NO'),reg.regulatory_identifier,NULL,NULL,NULL) AS inc_reg_no,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'OP_REG_NO'),attribute_ext_id(p_xml_element_name => 'OP_REG_NO'),op.regulatory_identifier,NULL,NULL,NULL) AS op_reg_no,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'OP_POBOX'),attribute_ext_id(p_xml_element_name => 'OP_POBOX'),op.pobox,NULL,NULL,NULL) AS op_pobox,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'OP_FLOOR'),attribute_ext_id(p_xml_element_name => 'OP_FLOOR'),op.floor,NULL,NULL,NULL) AS op_floor,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'OP_BUILDING'),attribute_ext_id(p_xml_element_name => 'OP_BUILDING'),op.building,NULL,NULL,NULL) AS op_building,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'OP_ADDRESS1'),attribute_ext_id(p_xml_element_name => 'OP_ADDRESS1'),op.address_1,NULL,NULL,NULL) AS op_address1,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'OP_ADDRESS2'),attribute_ext_id(p_xml_element_name => 'OP_ADDRESS2'),op.address_2,NULL,NULL,NULL) AS op_address2,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'OP_ADDRESS3'),attribute_ext_id(p_xml_element_name => 'OP_ADDRESS3'),op.address_3,NULL,NULL,NULL) AS op_address3,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'OP_CITY'),attribute_ext_id(p_xml_element_name => 'OP_CITY'),op.city,NULL,NULL,NULL) AS op_city,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'OP_STATE'),attribute_ext_id(p_xml_element_name => 'OP_STATE'),op.state,NULL,NULL,NULL) AS op_state,
        --op_state_name
        --op_iso_state
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'OP_COUNTRY'),attribute_ext_id(p_xml_element_name => 'OP_COUNTRY'),pkg_utils.get_country_2_from_3(op.country_code),NULL,NULL,NULL) AS op_country,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'OP_COUNTRY3'),attribute_ext_id(p_xml_element_name => 'OP_COUNTRY3'),op.country_code,NULL,NULL,NULL) AS op_country3,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'OP_COUNTRY_NAME'),attribute_ext_id(p_xml_element_name => 'OP_COUNTRY_NAME'),DECODE(pkg_utils.get_country_name_from_3(op.country_code),'NULL',NULL,pkg_utils.get_country_name_from_3(op.country_code) ),NULL,NULL,NULL) AS op_country_name,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'OP_POSTCODE'),attribute_ext_id(p_xml_element_name => 'OP_POSTCODE'),op.post_code,NULL,NULL,NULL) AS op_postcode,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'REG_STATUS'),attribute_ext_id(p_xml_element_name => 'REG_STATUS'),ae.regulatory_classification,NULL,NULL,NULL) AS reg_status,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'REG_BY'),attribute_ext_id(p_xml_element_name => 'REG_BY'),ae.regulated_by,NULL,NULL,NULL) AS reg_by,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'REG_ID'),attribute_ext_id(p_xml_element_name => 'REG_ID'),ae.regulatory_identifier,NULL,NULL,NULL) AS reg_id,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'ISSUER_FLAG'),attribute_ext_id(p_xml_element_name => 'ISSUER_FLAG'),get_issuer_flag(ae.avid),NULL,NULL,NULL) AS issuer_flag,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'NAME_NOTES'),attribute_ext_id(p_xml_element_name => 'NAME_NOTES'),nn.note,NULL,NULL,NULL) AS name_notes,
        CAST(MULTISET(
            SELECT
                datapoint_obj(attribute_ext_name(p_xml_element_name => 'TRADES_AS'),attribute_ext_id(p_xml_element_name => 'TRADES_AS'),alias_name,alias_type,effective_date,NULL)
            FROM
                avox_aliases
            WHERE
                alias_type = 'AKA'
                AND   avid = cr.avid
        ) AS datapoint_tab) AS trades_as,
        CAST(MULTISET(
            SELECT
                datapoint_obj(attribute_ext_name(p_xml_element_name => 'PREVIOUS_NAMES'),attribute_ext_id(p_xml_element_name => 'PREVIOUS_NAMES'),alias_name,alias_type,effective_date,NULL)
            FROM
                avox_aliases
            WHERE
                alias_type = 'FKA'
                AND   avid = cr.avid
        ) AS datapoint_tab) AS previous_names,
        datapoint_obj(attribute_ext_name(p_attr_name => 'DATE OF REGISTRATION'),attribute_ext_id(p_attr_name => 'DATE OF REGISTRATION'),TO_CHAR(ae.date_of_registration,'YYYY-MM-DD'),NULL,NULL,NULL) AS reg_date,   -- CD-372
        datapoint_obj(attribute_ext_name(p_attr_name => 'DATE OF INACTIVITY'),attribute_ext_id(p_attr_name => 'DATE OF INACTIVITY'),TO_CHAR(ae.date_of_dissolution,'YYYY-MM-DD'),NULL,NULL,NULL) AS diss_date,       -- CD-372
        datapoint_obj(attribute_ext_name(p_attr_name => 'LAST UPDATE DATE'),attribute_ext_id(p_attr_name => 'LAST UPDATE DATE'),TO_CHAR(get_me_date(ae.avid,'LU'),'YYYY-MM-DD'),NULL,NULL,NULL) AS last_update_date, -- CD-372
        datapoint_obj(attribute_ext_name(p_attr_name => 'MAINTENANCE DATE'),attribute_ext_id(p_attr_name => 'MAINTENANCE DATE'),TO_CHAR(get_me_date(ae.avid,'MA'),'YYYY-MM-DD'),NULL,NULL,NULL) AS maintenance_date, -- CD-372
        datapoint_obj(attribute_ext_name(p_attr_name => 'ANNIVERSARY DATE'),attribute_ext_id(p_attr_name => 'ANNIVERSARY DATE'),TO_CHAR(get_me_date(ae.avid,'AN'),'YYYY-MM-DD'),NULL,NULL,NULL) AS anniversary_date, -- CD-372
        datapoint_obj(attribute_ext_name(p_attr_name => 'ENTITY TYPE'),attribute_ext_id(p_attr_name => 'ENTITY TYPE'),DECODE(ae.entity_type,'TP','Ultimate Parent','LE','Subsidiary','BRA','Branch','SLE','Branch','DIV','Division',ae.entity_type),NULL,NULL,NULL) AS entity_type,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'ENTITY_CLASS'),attribute_ext_id(p_xml_element_name => 'ENTITY_CLASS'),ae.entity_class,NULL,NULL,NULL) AS entity_class,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'COMPANY_WEBSITE'),attribute_ext_id(p_xml_element_name => 'COMPANY_WEBSITE'),ae.company_website,NULL,NULL,NULL) AS company_website,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'PRIMARY_EXCHANGE_NAME'),attribute_ext_id(p_xml_element_name => 'PRIMARY_EXCHANGE_NAME'),ae.primary_exchange_name,NULL,NULL,NULL) AS primary_exchange_name,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'TICKER_CODE'),attribute_ext_id(p_xml_element_name => 'TICKER_CODE'),tc.identifier_value,NULL,NULL,NULL) AS ticker_code,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'CIK'),attribute_ext_id(p_xml_element_name => 'CIK'),tk.identifier_value,NULL,NULL,NULL) AS cik,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'TAX_ID'),attribute_ext_id(p_xml_element_name => 'TAX_ID'),ti.identifier_value,NULL,NULL,NULL) AS tax_id,
        -- Industry Codes
        CAST(MULTISET(
            SELECT
                datapoint_obj(attribute_ext_name(p_xml_element_name => replace(aic.industry_code_type
                || '_CODE',' ','') ),attribute_ext_id(p_xml_element_name => replace(aic.industry_code_type
                || '_CODE',' ','') ),industry_code,NULL,NULL,NULL)
            FROM
                avox_industry_codes aic
            WHERE
                aic.avid = ae.avid
                AND   aic.industry_code_type IN(
                    SELECT
                        st.column_value
                    FROM
                        TABLE(split_list(p_list => sys_context('process_option','industry_code'),p_del => '|') ) st
                )
        ) AS datapoint_tab) AS industry_code,
        -- Industry Code Descriptions
        CAST(MULTISET(
            SELECT
                datapoint_obj(attribute_ext_name(p_xml_element_name => replace(aic.industry_code_type
                || '_DESC',' ','') ),attribute_ext_id(p_xml_element_name => replace(aic.industry_code_type
                || '_DESC',' ','') ),industry_description,NULL,NULL,NULL)
            FROM
                avox_industry_codes aic
            WHERE
                aic.avid = ae.avid
                AND   aic.industry_code_type IN(
                    SELECT
                        st.column_value
                    FROM
                        TABLE(split_list(p_list => sys_context('process_option','industry_desc'),p_del => '|') ) st
                )
        ) AS datapoint_tab) AS industry_desc,
        --
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'SWIFT_BIC'),attribute_ext_id(p_xml_element_name => 'SWIFT_BIC'),ai.identifier_value,NULL,NULL,NULL) AS swift_bic,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'LEI'),attribute_ext_id(p_xml_element_name => 'LEI'),get_lei(p_avid => ae.avid),NULL,NULL,NULL) AS lei,
        datapoint_obj(attribute_ext_name(p_attr_name => 'LEI LOU'),attribute_ext_id(p_attr_name => 'LEI LOU'),source_name(p_src_id => lei.source_id),NULL,NULL,NULL) AS lei_louid,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'LOU_STATUS'),attribute_ext_id(p_xml_element_name => 'LOU_STATUS'),get_ds_flex_attr_value(lei.source_id,'ROC_STATUS'),NULL,NULL,NULL) AS lou_status,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'LOU_NAME'),attribute_ext_id(p_xml_element_name => 'LOU_NAME'),get_lou_attribute(lei.record_identifier,'NAME'),NULL,NULL,NULL) AS lou_name,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'LOU_LEI'),attribute_ext_id(p_xml_element_name => 'LOU_LEI'),get_lou_attribute(lei.record_identifier,'LEI'),NULL,NULL,NULL) AS lou_lei,
        datapoint_obj(attribute_ext_name(p_attr_name => 'ROC_STATUS'),attribute_ext_id(p_attr_name => 'ROC_STATUS'),get_ds_flex_attr_value(lei.source_id,'ROC_STATUS'),NULL,NULL,NULL) AS lei_roc_end,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'LEI_LEGAL_NAME'),attribute_ext_id(p_xml_element_name => 'LEI_LEGAL_NAME'),lei.entity_name,NULL,NULL,NULL) AS lei_legal_name,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'LEI_RECORD_STATE'),attribute_ext_id(p_xml_element_name => 'LEI_RECORD_STATE'),lei.record_identifier_status,NULL,NULL,NULL) AS lei_record_state,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'LEI_NEXT_MAINT_DATE'),attribute_ext_id(p_xml_element_name => 'LEI_NEXT_MAINT_DATE'),get_flex_attr_value(lei.source_id,lei.record_identifier,'NextRenewalDate','''yyyy-mm-dd"T"hh24:mi:ss"Z"'''),NULL,NULL,NULL) AS lei_next_maint_date,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'LEI_LAST_UPD_DATE'),attribute_ext_id(p_xml_element_name => 'LEI_LAST_UPD_DATE'),TO_CHAR(lei.source_last_update_date,'yyyy-mm-dd"T"hh24:mi:ss"Z"'),NULL,NULL,NULL) AS lei_last_upd_date,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'LEI_ASS_DATE'),attribute_ext_id(p_xml_element_name => 'LEI_ASS_DATE'),TO_CHAR(lei.record_id_asg_date,'yyyy-mm-dd"T"hh24:mi:ss"Z"'),NULL,NULL,NULL) AS lei_ass_date,
        --datapoint_obj(attribute_ext_name(p_xml_element_name=>'LEI_MAINT_STATE'),attribute_ext_id(p_xml_element_name=>'LEI_MAINT_STATE'),get_flex_attr_value(lei.source_id,lei.record_identifier,'LEIMaintState') ,NULL,NULL,NULL) AS lei_maint_state,
        /*datapoint_obj(attribute_ext_name(p_xml_element_name=>'LEI_ANGLICIZED_NAME'),attribute_ext_id(p_xml_element_name=>'LEI_ANGLICIZED_NAME'),(SELECT alias_value FROM entity_alias WHERE er_id = lei.er_id AND alias_type='ANGLICIZED') ,NULL,NULL,NULL) AS lei_anglicized_name,*/
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'IP_LEI'),attribute_ext_id(p_xml_element_name => 'IP_LEI'),get_lei(p_avid => ip.parent_id),NULL,NULL,NULL) AS ip_lei,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'UP_LEI'),attribute_ext_id(p_xml_element_name => 'UP_LEI'),get_lei(p_avid => up.parent_id),NULL,NULL,NULL) AS up_lei,
        --
        dp_auditdata(p_avid => cr.avid,p_csr_id => cr.csr_id) AS metadata,
        --dp_change_types(p_avid => cr.avid, p_dssID => SYS_CONTEXT('sds_data_channel','structure_id'), p_sourceID => SYS_CONTEXT('sds_data_channel','source_id') , p_change_date => SYS_CONTEXT('sds_data_channel','eff_date')) AS changedata,
        dpchange_tab() AS changedata,
        --get_service_options(p_csr_id => cr.csr_id) AS service_options, -- CD-372
        dss_spare_data(p_csr_id => cr.csr_id) AS spare_data,
        --
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'NFA_ID'),attribute_ext_id(p_xml_element_name => 'NFA_ID'),nfa_id(ae.avid),NULL,NULL,NULL) AS nfa_id,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'NFA_SD'),attribute_ext_id(p_xml_element_name => 'NFA_SD'),nfa_sd(ae.avid),NULL,NULL,NULL) AS nfa_sd,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'NFA_MSP'),attribute_ext_id(p_xml_element_name => 'NFA_MSP'),nfa_msp(ae.avid),NULL,NULL,NULL) AS nfa_msp,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'FI_FLAG'),attribute_ext_id(p_xml_element_name => 'FI_FLAG'),arrfs_fi(icn.industry_code,ics.industry_code),NULL,NULL,NULL) AS fi_flag,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'US_PERSON_FLAG'),attribute_ext_id(p_xml_element_name => 'US_PERSON_FLAG'),fatca_us_person(ae.avid),NULL,NULL,NULL) AS us_person_flag,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'US_PERSON_QUALIFIER'),attribute_ext_id(p_xml_element_name => 'US_PERSON_QUALIFIER'),fatca_us_person_qualifier(ae.avid,icn.industry_code,ics.industry_code,op.country_code,reg.country_code,ae.entity_type),NULL,NULL,NULL) AS us_person_qualifier,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'EMIR_FC_FLAG'),attribute_ext_id(p_xml_element_name => 'EMIR_FC_FLAG'),emir_fin_party(ae.avid),NULL,NULL,NULL) AS emir_fc_flag,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'EMIR_CORP_SECTOR'),attribute_ext_id(p_xml_element_name => 'EMIR_CORP_SECTOR'),emir_corp_sector(ae.avid),NULL,NULL,NULL) AS emir_corp_sector,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'EMIR_EXEMPT_FLAG'),attribute_ext_id(p_xml_element_name => 'EMIR_EXEMPT_FLAG'),emir_exempt(ae.avid),NULL,NULL,NULL) AS emir_exempt_flag,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'EMIR_EXEMPTION_TYPE'),attribute_ext_id(p_xml_element_name => 'EMIR_EXEMPTION_TYPE'),emir_csexempt_type(ae.avid),NULL,NULL,NULL) AS emir_exemption_type,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'ISDA_NFC_REPRESENTATION'),attribute_ext_id(p_xml_element_name => 'ISDA_NFC_REPRESENTATION'),emir_nfc(ae.avid),NULL,NULL,NULL) AS isda_nfc_representation,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'ISDA_NFC_ACCEPTANCE_DATE'),attribute_ext_id(p_xml_element_name => 'ISDA_NFC_ACCEPTANCE_DATE'),TO_CHAR(TO_DATE(emir_nfc_acc_date(ae.avid),'DD-MM-YYYY'),'YYYY-MM-DD'),NULL,NULL,NULL) AS isda_nfc_acceptance_date, -- CD-372
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'EEA_FLAG'),attribute_ext_id(p_xml_element_name => 'EEA_FLAG'),emir_eea_country(ae.avid),NULL,NULL,NULL) AS eea_flag,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'IP_AVID'),attribute_ext_id(p_xml_element_name => 'IP_AVID'),ipe.avid,NULL,NULL,NULL) AS ip_avid,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'IP_NAME'),attribute_ext_id(p_xml_element_name => 'IP_NAME'),ipe.legal_name,NULL,NULL,NULL) AS ip_name,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'UP_AVID'),attribute_ext_id(p_xml_element_name => 'UP_AVID'),upe.avid,NULL,NULL,NULL) AS up_avid,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'UP_NAME'),attribute_ext_id(p_xml_element_name => 'UP_NAME'),upe.legal_name,NULL,NULL,NULL) AS up_name,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'PERCENT_OWNED'),attribute_ext_id(p_xml_element_name => 'PERCENT_OWNED'),ip.percentage_of_child_owned,NULL,NULL,NULL) AS percent_owned,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'IP_REG_STATE'),attribute_ext_id(p_xml_element_name => 'IP_REG_STATE'),ip_reg.state,NULL,NULL,NULL) AS ip_reg_state,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'IP_REG_COUNTRY'),attribute_ext_id(p_xml_element_name => 'IP_REG_COUNTRY'),pkg_utils.get_country_2_from_3(ip_reg.country_code),NULL,NULL,NULL) AS ip_reg_country,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'IP_REG_COUNTRY_NAME'),attribute_ext_id(p_xml_element_name => 'IP_REG_COUNTRY_NAME'),DECODE(pkg_utils.get_country_name_from_3(ip_reg.country_code),'NULL',NULL,pkg_utils.get_country_name_from_3(ip_reg.country_code) ),NULL,NULL,NULL) AS ip_reg_country_name,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'UP_REG_STATE'),attribute_ext_id(p_xml_element_name => 'UP_REG_STATE'),up_reg.state,NULL,NULL,NULL) AS up_reg_state,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'UP_REG_COUNTRY'),attribute_ext_id(p_xml_element_name => 'UP_REG_COUNTRY'),pkg_utils.get_country_2_from_3(up_reg.country_code),NULL,NULL,NULL) AS up_reg_country,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'UP_REG_COUNTRY_NAME'),attribute_ext_id(p_xml_element_name => 'UP_REG_COUNTRY_NAME'),DECODE(pkg_utils.get_country_name_from_3(up_reg.country_code),'NULL',NULL,pkg_utils.get_country_name_from_3(up_reg.country_code) ),NULL,NULL,NULL) AS up_reg_country_name,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'IGA_FLAG'),attribute_ext_id(p_xml_element_name => 'IGA_FLAG'),fatca_iga_flag(ae.avid),NULL,NULL,NULL) AS iga_flag,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'IGA_TYPE'),attribute_ext_id(p_xml_element_name => 'IGA_TYPE'),fatca_iga_type(ae.avid),NULL,NULL,NULL) AS iga_type,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'FATCA_FI_FLAG'),attribute_ext_id(p_xml_element_name => 'FATCA_FI_FLAG'),fatca_fi(icn.industry_code,ics.industry_code),NULL,NULL,NULL) AS fatca_fi_flag,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'FATCA_ENTITY_TYPE'),attribute_ext_id(p_xml_element_name => 'FATCA_ENTITY_TYPE'),fatca_entity_type(ae.avid,reg.country_code),NULL,NULL,NULL) AS fatca_entity_type,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'NFFE_TYPE'),attribute_ext_id(p_xml_element_name => 'NFFE_TYPE'),pkg_fatca_utils.fatca_nffe_type(ae.avid,reg.country_code),NULL,NULL,NULL) AS nffe_type,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'NFFE_TYPE_QUALIFIER'),attribute_ext_id(p_xml_element_name => 'NFFE_TYPE_QUALIFIER'),pkg_fatca_utils.fatca_nffe_qualifier(ae.avid,reg.country_code),NULL,NULL,NULL) AS nffe_type_qualifier,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'PUBLICLY_LISTED'),attribute_ext_id(p_xml_element_name => 'PUBLICLY_LISTED'),pkg_fatca_utils.fatca_public_listed(ae.avid),NULL,NULL,NULL) AS publicly_listed,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'PUBLICLY_LISTED_PARENT'),attribute_ext_id(p_xml_element_name => 'PUBLICLY_LISTED_PARENT'),pkg_fatca_utils.fatca_public_parent(ae.avid),NULL,NULL,NULL) AS publicly_listed_parent,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'UNLISTED'),attribute_ext_id(p_xml_element_name => 'UNLISTED'),pkg_fatca_utils.fatca_public_unlisted(ae.avid),NULL,NULL,NULL) AS unlisted,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'GIIN'),attribute_ext_id(p_xml_element_name => 'GIIN'),pkg_giin_utils.get_multiple_giins(ae.avid,'|',1),NULL,NULL,NULL) AS giin,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'GIIN_COUNTRY_CORR'),attribute_ext_id(p_xml_element_name => 'GIIN_COUNTRY_CORR'),DECODE(ae.avid,NULL,NULL,pkg_giin_utils.giin_country_correspondence(ae.avid) ),NULL,NULL,NULL) AS giin_country_corr,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'CDOT'),attribute_ext_id(p_xml_element_name => 'CDOT'),DECODE(ae.avid,NULL,NULL,fatca_cdot(ae.avid) ),NULL,NULL,NULL) AS cdot,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'FRN'),attribute_ext_id(p_xml_element_name => 'FRN'),get_fca_frn_value(ae.avid,'FRN'),NULL,NULL,NULL) AS frn,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'FRN_STATUS'),attribute_ext_id(p_xml_element_name => 'FRN_STATUS'),get_fca_frn_value(ae.avid,'FRN_STATUS'),NULL,NULL,NULL) AS frn_status,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'FRN_TYPE'),attribute_ext_id(p_xml_element_name => 'FRN_TYPE'),get_fca_frn_value(ae.avid,'FRN_TYPE'),NULL,NULL,NULL) AS frn_type,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'PRIMARY_BIC'),attribute_ext_id(p_xml_element_name => 'PRIMARY_BIC'),get_fca_bic_value(ae.avid,'P','BIC'),NULL,NULL,NULL) AS primary_bic,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'PRIMARY_BIC_TYPE'),attribute_ext_id(p_xml_element_name => 'PRIMARY_BIC_TYPE'),get_fca_bic_value(ae.avid,'P','BIC_TYPE'),NULL,NULL,NULL) AS primary_bic_type,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'SECONDARY_BIC'),attribute_ext_id(p_xml_element_name => 'SECONDARY_BIC'),get_fca_bic_value(ae.avid,'S','BIC'),NULL,NULL,NULL) AS secondary_bic,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'SECONDARY_BIC_TYPE'),attribute_ext_id(p_xml_element_name => 'SECONDARY_BIC_TYPE'),get_fca_bic_value(ae.avid,'S','BIC_TYPE'),NULL,NULL,NULL) AS secondary_bic_type,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'LGL_PROC_STS'),attribute_ext_id(p_xml_element_name => 'LGL_PROC_STS'),fnc_legal_proc(p_avid => ae.avid),NULL,NULL,NULL) AS lgl_proc_sts,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'LGL_PROC_DATE'),attribute_ext_id(p_xml_element_name => 'LGL_PROC_DATE'),TO_CHAR(fnc_legal_proc_date(p_avid => ae.avid),'YYYY-MM-DD'),NULL,NULL,NULL) AS lgl_proc_date,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'NUTS3_REGION'),attribute_ext_id(p_xml_element_name => 'NUTS3_REGION'),fnc_get_nuts3(p_avid => ae.avid),NULL,NULL,NULL) AS nuts3_region,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'LGL_FORM_CODE'),attribute_ext_id(p_xml_element_name => 'LGL_FORM_CODE'),fnc_legal_form_values(p_avid => ae.avid,p_attribute_name => 'LGL_FORM_CODE'),NULL,NULL,NULL) AS lgl_form_code,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'LGL_FORM_ACR'),attribute_ext_id(p_xml_element_name => 'LGL_FORM_ACR'),fnc_legal_form_values(p_avid => ae.avid,p_attribute_name => 'LGL_FORM_ACR'),NULL,NULL,NULL) AS lgl_form_acr,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'LGL_FORM_ELIG'),attribute_ext_id(p_xml_element_name => 'LGL_FORM_ELIG'),fnc_legal_form_values(p_avid => ae.avid,p_attribute_name => 'LGL_FORM_ELIG'),NULL,NULL,NULL) AS lgl_form_elig,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'INST_SECT_CODE'),attribute_ext_id(p_xml_element_name => 'INST_SECT_CODE'),get_inst_sector_code(p_avid => ae.avid),NULL,NULL,NULL) AS inst_sect_code,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'INST_SECT_DESC'),attribute_ext_id(p_xml_element_name => 'INST_SECT_DESC'),get_inst_sector_description(p_avid => ae.avid),NULL,NULL,NULL) AS inst_sect_desc,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'HO_UNDER_ID'),attribute_ext_id(p_xml_element_name => 'HO_UNDER_ID'),pkg_anacredit.avid_ut_id(p_avid => ae.avid,p_entity_type => ae.entity_type,p_entity_class => ae.entity_class,p_naics => icn.industry_code,p_sic => ics.industry_code,p_riad_type => 'HO',p_ip_avid => ip.parent_id,p_up_avid => up.parent_id),NULL,NULL,NULL) AS ho_under_id,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'IP_UNDER_ID'),attribute_ext_id(p_xml_element_name => 'IP_UNDER_ID'),pkg_anacredit.avid_ut_id(p_avid => ae.avid,p_entity_type => ae.entity_type,p_entity_class => ae.entity_class,p_naics => icn.industry_code,p_sic => ics.industry_code,p_riad_type => 'IP',p_ip_avid => ip.parent_id,p_up_avid => up.parent_id),NULL,NULL,NULL) AS ip_under_id,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'UP_UNDER_ID'),attribute_ext_id(p_xml_element_name => 'UP_UNDER_ID'),pkg_anacredit.avid_ut_id(p_avid => ae.avid,p_entity_type => ae.entity_type,p_entity_class => ae.entity_class,p_naics => icn.industry_code,p_sic => ics.industry_code,p_riad_type => 'UP',p_ip_avid => ip.parent_id,p_up_avid => up.parent_id),NULL,NULL,NULL) AS up_under_id,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'COUNTERPARTY_ID'),attribute_ext_id(p_xml_element_name => 'COUNTERPARTY_ID'),pkg_anacredit.counterparty_id(p_avid => ae.avid),NULL,NULL,NULL) AS counterparty_id,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'NATIONAL_ID'),attribute_ext_id(p_xml_element_name => 'NATIONAL_ID'),get_national_identifier(p_avid => ae.avid),NULL,NULL,NULL) AS national_id,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'NATIONAL_ID_TYPE'),attribute_ext_id(p_xml_element_name => 'NATIONAL_ID_TYPE'),get_national_identifier_type(p_avid => ae.avid),NULL,NULL,NULL) AS national_id_type,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'FATCA_FLAG'),attribute_ext_id(p_xml_element_name => 'FATCA_FLAG'),get_service_options(p_csr_id => cr.csr_id,p_service_option_name => 'FATCA'),NULL,NULL,NULL) AS fatca_flag,                                                            -- CD-372
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'DODD_FRANK_FLAG'),attribute_ext_id(p_xml_element_name => 'DODD_FRANK_FLAG'),get_service_options(p_csr_id => cr.csr_id,p_service_option_name => 'DODD FRANK'),NULL,NULL,NULL) AS dodd_frank_flag,                                        -- CD-372 
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'EMIR_FLAG'),attribute_ext_id(p_xml_element_name => 'EMIR_FLAG'),get_service_options(p_csr_id => cr.csr_id,p_service_option_name => 'EMIR'),NULL,NULL,NULL) AS emir_flag,                                                                -- CD-372
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'FCA_TRANSACTION_REPORTING_FLAG'),attribute_ext_id( p_xml_element_name => 'FCA_TRANSACTION_REPORTING_FLAG'),get_service_options(p_csr_id => cr.csr_id,p_service_option_name => 'FCA'),NULL,NULL,NULL) AS fca_transaction_reporting_flag, -- CD-372
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'LEI_EDS_FLAG'),attribute_ext_id(p_xml_element_name => 'LEI_EDS_FLAG'),get_service_options(p_csr_id => cr.csr_id,p_service_option_name => 'LEI EDS FLAG'),NULL,NULL,NULL) AS lei_eds_flag,                                               -- CD-372
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'ANACREDIT_EDS_FLAG'),attribute_ext_id(p_xml_element_name => 'ANACREDIT_EDS_FLAG'),get_service_options(p_csr_id => cr.csr_id,p_service_option_name => 'ANACREDIT EDS FLAG'),NULL,NULL,NULL) AS anacredit_eds_flag,                       -- CD-372
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'ANACREDIT_FULL_FLAG'),attribute_ext_id(p_xml_element_name => 'ANACREDIT_FULL_FLAG'),get_service_options(p_csr_id => cr.csr_id,p_service_option_name => 'ANACREDIT FULL FLAG'),NULL,NULL,NULL) AS anacredit_full_flag,                   -- CD-365
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'ANACREDIT_COMP_FLAG'),attribute_ext_id(p_xml_element_name => 'ANACREDIT_COMP_FLAG'),get_service_options(p_csr_id => cr.csr_id,p_service_option_name => 'ANACREDIT COMP FLAG'),NULL,NULL,NULL) AS anacredit_comp_flag,                   -- CD-365
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'ENTERPRISE_SIZE'),attribute_ext_id(p_xml_element_name => 'ENTERPRISE_SIZE'),pkg_anacreditfull.enterprise_size(p_avid => ae.avid),NULL,NULL,NULL) AS enterprise_size,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'DATE_OF_ENTERPRISE_SIZE'),attribute_ext_id(p_xml_element_name => 'DATE_OF_ENTERPRISE_SIZE'),pkg_anacreditfull.enterprise_size_date(p_avid => ae.avid),NULL,NULL,NULL) AS date_of_enterprise_size,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'NUMBER_OF_EMPLOYEES'),attribute_ext_id(p_xml_element_name => 'NUMBER_OF_EMPLOYEES'),pkg_anacreditfull.no_of_employees(p_avid => ae.avid),NULL,NULL,NULL) AS number_of_employees,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'BALANCE_SHEET_TOTAL'),attribute_ext_id(p_xml_element_name => 'BALANCE_SHEET_TOTAL'),pkg_anacreditfull.bal_sheet_total(p_avid => ae.avid),NULL,NULL,NULL) AS balance_sheet_total,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'ANNUAL_TURNOVER'),attribute_ext_id(p_xml_element_name => 'ANNUAL_TURNOVER'),pkg_anacreditfull.annual_turnover(p_avid => ae.avid),NULL,NULL,NULL) AS annual_turnover,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'CURRENCY'),attribute_ext_id(p_xml_element_name => 'CURRENCY'),pkg_anacreditfull.currency(p_avid => ae.avid),NULL,NULL,NULL) AS currency,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'ACCOUNTS_TYPE'),attribute_ext_id(p_xml_element_name => 'ACCOUNTS_TYPE'),pkg_anacreditfull.acc_type(p_avid => ae.avid),NULL,NULL,NULL) AS accounts_type,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'ACCOUNTING_STANDARD'),attribute_ext_id(p_xml_element_name => 'ACCOUNTING_STANDARD'),pkg_anacreditfull.acc_std(p_avid => ae.avid),NULL,NULL,NULL) AS accounting_standard,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'FX_RATE'),attribute_ext_id(p_xml_element_name => 'FX_RATE'),pkg_anacreditfull.fx_rate(p_avid => ae.avid),NULL,NULL,NULL) AS fx_rate,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'EUR_BALANCE_SHEET_TOTAL'),attribute_ext_id(p_xml_element_name => 'EUR_BALANCE_SHEET_TOTAL'),pkg_anacreditfull.eur_bal_sheet_total(p_avid => ae.avid),NULL,NULL,NULL) AS eur_balance_sheet_total,
        datapoint_obj(attribute_ext_name(p_xml_element_name => 'EUR_ANNUAL_TURNOVER'),attribute_ext_id(p_xml_element_name => 'EUR_ANNUAL_TURNOVER'),pkg_anacreditfull.eur_annual_turnover(p_avid => ae.avid),NULL,NULL,NULL) AS eur_annual_turnover
    FROM
        central_records cr
        JOIN client_csr cc ON ( cc.csr_id = cr.csr_id )
        LEFT OUTER JOIN avox_entities ae ON ( ae.avid = cr.avid )
        LEFT OUTER JOIN avox_addresses op ON ( op.avid = cr.avid
                                               AND op.address_type = 'OP' )
        LEFT OUTER JOIN avox_addresses reg ON ( reg.avid = cr.avid
                                                AND reg.address_type = 'REG' )
        LEFT OUTER JOIN avox_parents ip ON ( ip.avid = ae.avid
                                             AND ip.parent_type = 'IP' )
        LEFT OUTER JOIN avox_addresses ip_reg ON ( ip.parent_id = ip_reg.avid
                                                   AND ip_reg.address_type = 'REG' )
        LEFT OUTER JOIN avox_parents up ON ( up.avid = ae.avid
                                             AND up.parent_type = 'UP' )
        LEFT OUTER JOIN avox_addresses up_reg ON ( up.parent_id = up_reg.avid
                                                   AND up_reg.address_type = 'REG' )
        LEFT OUTER JOIN avox_entities ipe ON ( ipe.avid = ip.parent_id )
        LEFT OUTER JOIN avox_entities upe ON ( upe.avid = up.parent_id )
        LEFT OUTER JOIN avox_identifiers tc ON ( tc.avid = cr.avid
                                                 AND tc.identifier_name = 'TICKER CODE' )
        LEFT OUTER JOIN avox_identifiers tk ON ( tk.avid = cr.avid
                                                 AND tk.identifier_name = 'CIK' )
        LEFT OUTER JOIN avox_identifiers ti ON ( ti.avid = cr.avid
                                                 AND ti.identifier_name = 'TAX ID' )
        LEFT OUTER JOIN avox_identifiers vn ON ( vn.avid = cr.avid
                                                 AND vn.identifier_name = 'VAT NO' )
        LEFT OUTER JOIN all_notes nn ON ( nn.cr_id = cr.cr_id
                                          AND nn.note_type = 'NAME NOTES' )
        LEFT OUTER JOIN avox_identifiers ai ON ( ai.avid = cr.avid
                                                 AND ai.identifier_name = 'SWIFT ID' )
        -- The NAICS and US SIC are needed for the FATCA derivation functions
        LEFT OUTER JOIN avox_user.avox_industry_codes icn ON ( icn.avid = cr.avid
                                                               AND icn.industry_code_level = 1
                                                               AND icn.industry_code_type = 'NAICS' )
        LEFT OUTER JOIN avox_user.avox_industry_codes ics ON ( ics.avid = cr.avid
                                                               AND ics.industry_code_level = 1
                                                               AND ics.industry_code_type = 'US SIC' )
        --
        LEFT OUTER JOIN entity lei ON ( lei.er_id = get_lei_erid(p_avid => ae.avid) )
        LEFT OUTER JOIN entity_address lei_reg ON ( lei_reg.er_id = lei.er_id
                                                    AND lei_reg.address_type_code = 'REG' )
        LEFT OUTER JOIN entity_address lei_hq ON ( lei_hq.er_id = lei.er_id
                                                   AND lei_hq.address_type_code = 'HQ' )
    WHERE
        cr.source_id = sys_context('sds_data_channel','source_id')
WITH READ ONLY;
/