set define off;
DECLARE

gd_date_mask CONSTANT VARCHAR2(10 CHAR):='yyyy-mm-dd';
lc_json CLOB:='
{
"contentTimestamp":"2018-08-28T10:38:39Z"
,"Entities":[
{
"recordStatus":"null"
,"managingSource":117
,"DataPoints":[
{
"dataPointName":"AVID"
,"dataPointID":"MDS0047"
,"dataPointValue":"25551904"
}
,{
"dataPointName":"LEGAL NAME"
,"dataPointID":"MDS0010"
,"dataPointValue":"Norbord Maine LLC"
}
,{
"dataPointName":"TRADING STATUS"
,"dataPointID":"MDS0014"
,"dataPointValue":"Suspended"
}
,{
"dataPointName":"NOTES"
,"dataPointID":"MDS0019"
}
,{
"dataPointName":"SWIFT BIC"
,"dataPointID":"MDS0051"
}
,{
"dataPointName":"OPERATIONAL STREET 1"
,"dataPointID":"MDS0023"
,"dataPointValue":"70 Seaview Avenue"
}
,{
"dataPointName":"OPERATIONAL STREET 2"
,"dataPointID":"MDS0024"
}
,{
"dataPointName":"OPERATIONAL STREET 3"
,"dataPointID":"MDS0025"
}
,{
"dataPointName":"OPERATIONAL CITY"
,"dataPointID":"MDS0026"
,"dataPointValue":"Stamford"
}
,{
"dataPointName":"OPERATIONAL STATE NAME"
,"dataPointID":"MDS0027"
,"dataPointValue":"CT"
}
,{
"dataPointName":"OPERATIONAL COUNTRY CODE"
,"dataPointID":"MDS0028"
,"dataPointValue":"US"
}
,{
"dataPointName":"OPERATIONAL POSTCODE"
,"dataPointID":"MDS0030"
,"dataPointValue":"06902"
}
,{
"dataPointName":"OPERATIONAL PO BOX"
,"dataPointID":"MDS0020"
}
,{
"dataPointName":"REGISTERED STREET 1"
,"dataPointID":"MDS0035"
,"dataPointValue":"1209 Orange Street"
}
,{
"dataPointName":"REGISTERED STREET 2"
,"dataPointID":"MDS0036"
}
,{
"dataPointName":"REGISTERED STREET 3"
,"dataPointID":"MDS0037"
}
,{
"dataPointName":"REGISTERED CITY"
,"dataPointID":"MDS0038"
,"dataPointValue":"Wilmington"
}
,{
"dataPointName":"REGISTERED STATE NAME"
,"dataPointID":"MDS0039"
,"dataPointValue":"DE"
}
,{
"dataPointName":"REGISTERED COUNTRY CODE"
,"dataPointID":"MDS0040"
,"dataPointValue":"US"
}
,{
"dataPointName":"REGISTERED POSTCODE"
,"dataPointID":"MDS0042"
,"dataPointValue":"19801"
}
,{
"dataPointName":"REGISTERED PO BOX"
,"dataPointID":"MDS0032"
}
,{
"dataPointName":"REGULATORY ID"
,"dataPointID":"MDS0056"
,"ValueMetaData":{
"Provenance":[
]
}
}
,{
"dataPointName":"ULTIMATE PARENT NAME"
,"dataPointID":"MDS0067"
,"ValueMetaData":{
"Provenance":[
]
}
}
,{
"dataPointName":"IMMEDIATE PARENT PERCENTAGE OWNERSHIP"
,"dataPointID":"MDS0065"
}
,{
"dataPointName":"ULTIMATE PARENT REGISTERED STATE NAME"
,"dataPointID":"MDS0068"
}
,{
"dataPointName":"ULTIMATE PARENT REGISTERED COUNTRY CODE"
,"dataPointID":"MDS0069"
}
,{
"dataPointName":"LEGAL STRUCTURE"
,"dataPointID":"MDS0011"
,"dataPointValue":"LIMITED LIABILITY COMPANY"
}
,{
"dataPointName":"ENTITY TYPE"
,"dataPointID":"MDS0059"
,"dataPointValue":"Ultimate Parent"
}
,{
"dataPointName":"ENTITY CLASS"
,"dataPointID":"MDS0071"
,"dataPointValue":"CORP"
}
,{
"dataPointName":"REGULATED BY"
,"dataPointID":"MDS0057"
}
,{
"dataPointName":"DATE OF INCORPORATION"
,"dataPointID":"MDS0015"
,"dataPointValue":"2012-01-18"
}
,{
"dataPointName":"DATE OF DISSOLUTION"
,"dataPointID":"MDS0016"
}
,{
"dataPointName":"COMPANY WEBSITE"
,"dataPointID":"MDS0017"
}
,{
"dataPointName":"OPERATIONAL FLOOR"
,"dataPointID":"MDS0021"
}
,{
"dataPointName":"OPERATIONAL BUILDING"
,"dataPointID":"MDS0022"
}
,{
"dataPointName":"REGISTERED FLOOR"
,"dataPointID":"MDS0033"
}
,{
"dataPointName":"REGISTERED BUILDING"
,"dataPointID":"MDS0034"
}
,{
"dataPointName":"IMMEDIATE PARENT NAME"
,"dataPointID":"MDS0061"
}
,{
"dataPointName":"IMMEDIATE PARENT REGISTERED STATE NAME"
,"dataPointID":"MDS0062"
}
,{
"dataPointName":"IMMEDIATE PARENT REGISTERED COUNTRY CODE"
,"dataPointID":"MDS0063"
}
,{
"dataPointName":"TAX ID"
,"dataPointID":"MDS0052"
}
,{
"dataPointName":"ULTIMATE PARENT AVID"
,"dataPointID":"MDS0066"
}
,{
"dataPointName":"REGULATORY STATUS"
,"dataPointID":"MDS0058"
}
,{
"dataPointName":"PRIMARY EXCHANGE"
,"dataPointID":"MDS0055"
}
,{
"dataPointName":"IMMEDIATE PARENT AVID"
,"dataPointID":"MDS0060"
}
,{
"dataPointName":"REGISTERED AGENT NAME"
,"dataPointID":"MDS0031"
,"dataPointValue":"The Corporation Trust Company"
}
,{
"dataPointName":"TICKER CODE"
,"dataPointID":"MDS0054"
}
,{
"dataPointName":"CENTRAL INDEX KEY (CIK)"
,"dataPointID":"MDS0053"
}
,{
"dataPointName":"LEI"
,"dataPointID":"MDS0048"
}
,{
"dataPointName":"LEI LOU"
,"dataPointID":"MDS0049"
}
,{
"dataPointName":"CLIENT RECORD IDENTIFIER"
,"dataPointID":"CDA0015"
,"dataPointValue":"SAMPLE_DATA_135"
}
,{
"dataPointName":"PREVIOUS NAME(S)"
,"dataPointID":"MDS0012"
,"dataPointValue":"Fraser Paper, Inc."
}
,{
"dataPointName":"PREVIOUS NAME(S)"
,"dataPointID":"MDS0012"
,"dataPointValue":"Fraser Paper, Limited"
}
,{
"dataPointName":"PREVIOUS NAME(S)"
,"dataPointID":"MDS0012"
}
,{
"dataPointName":"US SIC CODE"
,"dataPointID":"MDS0076"
}
,{
"dataPointName":"NAICS 2012 CODE"
,"dataPointID":"MDS0074"
}
,{
"dataPointName":"NACE 2 CODE"
,"dataPointID":"MDS0080"
}
,{
"dataPointName":"NAICS CODE"
,"dataPointID":"MDS0072"
}
,{
"dataPointName":"NACE CODE"
,"dataPointID":"MDS0078"
}
,{
"dataPointName":"US SIC DESCRIPTION"
,"dataPointID":"MDS0077"
}
,{
"dataPointName":"NAICS DESCRIPTION"
,"dataPointID":"MDS0073"
}
,{
"dataPointName":"NACE DESCRIPTION"
,"dataPointID":"MDS0079"
}
,{
"dataPointName":"NAICS 2012 DESCRIPTION"
,"dataPointID":"MDS0075"
}
,{
"dataPointName":"NACE 2 DESCRIPTION"
,"dataPointID":"MDS0081"
}
]
}
,{
"DataServiceOptions":[
{
}
]
}
]
}';

jdata apex_json.t_values;
l_key VARCHAR2(32767);
TYPE pt_svc_param IS TABLE OF entity_service_parameter%rowtype INDEX BY BINARY_INTEGER;
lr_csr client_csr%ROWTYPE;

BEGIN

NULL;
  apex_json.parse(jdata, lc_json); 
  dbms_output.put_line('jdata count: '||to_char(jdata.count));
--  dbms_output.put_line(apex_json.get_count(p_path=>'.',p_values=>jdata)); -- 
--  dbms_output.put_line(apex_json.get_count(p_path=>'DataPoints',p_values=>jdata)); -- 
l_key := jdata.first;

 LOOP
   EXIT WHEN l_key IS NULL;
   IF jdata(l_key).kind = apex_json.c_object OR  jdata(l_key).kind = apex_json.c_array THEN
     l_key := jdata.next(l_key);
     CONTINUE;
   ELSIF jdata(l_key).kind = apex_json.c_number THEN
   null;
   dbms_output.put_line(l_key||' : '||to_char(jdata(l_key).number_value));
   ELSIF jdata(l_key).kind = apex_json.c_varchar2 THEN
   dbms_output.put_line(l_key||' : '||jdata(l_key).varchar2_value);
   CASE  jdata(l_key).varchar2_value
   WHEN 'LEGAL NAME' THEN
    lr_csr.legal_name := jdata(REPLACE(l_key,'dataPointName','dataPointValue')).varchar2_value;
    dbms_output.put_line('LGL NAME DPID: '||jdata(REPLACE(l_key,'dataPointName','dataPointID')).varchar2_value);
    dbms_output.put_line('CSR LGL NAME: '||lr_csr.legal_name);
    WHEN 'DATE OF INCORPORATION' THEN
    BEGIN
    lr_csr.date_of_registration := TO_DATE(jdata(REPLACE(l_key,'dataPointName','dataPointValue')).varchar2_value,gd_date_mask);
    dbms_output.put_line('DOI DPID: '||jdata(REPLACE(l_key,'dataPointName','dataPointID')).varchar2_value);
    dbms_output.put_line('CSR D O REG: '||lr_csr.date_of_registration);
    EXCEPTION
    WHEN no_data_found THEN
    lr_csr.date_of_registration := NULL;    
    END;
   ELSE 
     NULL;
   END CASE;
    ELSE
    NULL;
--   dbms_output.put_line(l_key||' : '||jdata(l_key).kind);
   end if;
   l_key := jdata.next(l_key);
 END LOOP;
 
END;