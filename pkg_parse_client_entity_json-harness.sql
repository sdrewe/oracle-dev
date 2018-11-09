declare

lc_json CLOB:='
{
	"contentTimestamp": "2018-10-02T10:38:39Z",
	"Entities": [{
			"recordStatus": "null",
			"managingSource": 117,
			"DataPoints": [{
					"dataPointName": "AVID",
					"dataPointID": "CDA0074",
					"dataPointValue": 25551904
				}, {
					"dataPointName": "LEGAL NAME",
					"dataPointID": "CDA0008",
					"dataPointValue": "Norbord Maine LLC"
				}, {
					"dataPointName": "TRADING STATUS",
					"dataPointID": "CDA0011",
					"dataPointValue": "Suspended"
				}, {
					"dataPointName": "CLIENT NOTE(S)",
					"dataPointID": "CDA0073"
				}, {
					"dataPointName": "SWIFT BIC",
					"dataPointID": "CDA0019"
				}, {
					"dataPointName": "OPERATIONAL STREET 1",
					"dataPointID": "CDA0032",
					"dataPointValue": "70 Seaview Avenue"
				}, {
					"dataPointName": "OPERATIONAL STREET 2",
					"dataPointID": "CDA0033"
				}, {
					"dataPointName": "OPERATIONAL STREET 3",
					"dataPointID": "CDA0034"
				}, {
					"dataPointName": "OPERATIONAL CITY",
					"dataPointID": "CDA0035",
					"dataPointValue": "Stamford"
				}, {
					"dataPointName": "OPERATIONAL STATE NAME",
					"dataPointID": "CDA0037",
					"dataPointValue": "CT"
				}, {
					"dataPointName": "OPERATIONAL COUNTRY CODE",
					"dataPointID": "CDA0038",
					"dataPointValue": "US"
				}, {
					"dataPointName": "OPERATIONAL POSTCODE",
					"dataPointID": "CDA0040",
					"dataPointValue": "06902"
				}, {
					"dataPointName": "OPERATIONAL PO BOX",
					"dataPointID": "CDA0029"
				}, {
					"dataPointName": "REGISTERED STREET 1",
					"dataPointID": "CDA0045",
					"dataPointValue": "1209 Orange Street"
				}, {
					"dataPointName": "REGISTERED STREET 2",
					"dataPointID": "CDA0046"
				}, {
					"dataPointName": "REGISTERED STREET 3",
					"dataPointID": "CDA0047"
				}, {
					"dataPointName": "REGISTERED CITY",
					"dataPointID": "CDA0048",
					"dataPointValue": "Wilmington"
				}, {
					"dataPointName": "REGISTERED STATE NAME",
					"dataPointID": "CDA0050",
					"dataPointValue": "DE"
				}, {
					"dataPointName": "REGISTERED COUNTRY CODE",
					"dataPointID": "CDA0051",
					"dataPointValue": "US"
				}, {
					"dataPointName": "REGISTERED POSTCODE",
					"dataPointID": "CDA0053",
					"dataPointValue": "19801"
				}, {
					"dataPointName": "REGISTERED PO BOX",
					"dataPointID": "CDA0042"
				}, {
					"dataPointName": "REGULATORY ID",
					"dataPointID": "CDA0028"
				},
				{
					"dataPointName": "ULTIMATE PARENT NAME",
					"dataPointID": "CDA0057"
				},
				{
					"dataPointName": "IMMEDIATE PARENT PERCENTAGE OWNERSHIP",
					"dataPointID": "CDA0056"
				},
				{
					"dataPointName": "ENTITY TYPE",
					"dataPointID": "CDA0054",
					"dataPointValue": "Ultimate Parent"
				},
				{
					"dataPointName": "ENTITY CLASS",
					"dataPointID": "CDA0058",
					"dataPointValue": "CORP"
				},
				{
					"dataPointName": "REGULATED BY",
					"dataPointID": "CDA0026"
				},
				{
					"dataPointName": "DATE OF INCORPORATION",
					"dataPointID": "CDA0013",
					"dataPointValue": "2012-01-18"
				},
				{
					"dataPointName": "DATE OF DISSOLUTION",
					"dataPointID": "CDA0014"
				},
				{
					"dataPointName": "COMPANY WEBSITE",
					"dataPointID": "CDA0012"
				},
				{
					"dataPointName": "OPERATIONAL FLOOR",
					"dataPointID": "CDA0030"
				},
				{
					"dataPointName": "OPERATIONAL BUILDING",
					"dataPointID": "CDA0031"
				},
				{
					"dataPointName": "REGISTERED FLOOR",
					"dataPointID": "CDA0043"
				},
				{
					"dataPointName": "REGISTERED BUILDING",
					"dataPointID": "CDA0044"
				},
				{
					"dataPointName": "IMMEDIATE PARENT NAME",
					"dataPointID": "CDA0055"
				},
				{
					"dataPointName": "TAX ID",
					"dataPointID": "CDA0022"
				},
				{
					"dataPointName": "REGULATORY STATUS",
					"dataPointID": "CDA0027"
				},
				{
					"dataPointName": "PRIMARY EXCHANGE",
					"dataPointID": "CDA0025"
				},
				{
					"dataPointName": "REGISTERED AGENT NAME",
					"dataPointID": "CDA0041",
					"dataPointValue": "The Corporation Trust Company"
				},
				{
					"dataPointName": "TICKER CODE",
					"dataPointID": "CDA0024"
				},
				{
					"dataPointName": "CENTRAL INDEX KEY (CIK)",
					"dataPointID": "CDA0023"
				},
				{
					"dataPointName": "LEI",
					"dataPointID": "CDA0018"
				},
				{
					"dataPointName": "CLIENT RECORD IDENTIFIER",
					"dataPointID": "CDA0015",
					"dataPointValue": "SAMPLE_DATA_135"
				},
				{
					"dataPointName": "PREVIOUS NAME(S)",
					"dataPointID": "CDA0009",
					"dataPointValue": "Fraser Paper, Inc.|Fraser Paper, Limited"
				},
				{
					"dataPointName": "US SIC CODE",
					"dataPointID": "CDA0063"
				},
				{
					"dataPointName": "NAICS 2012 CODE",
					"dataPointID": "CDA0061"
				},
				{
					"dataPointName": "NACE 2 CODE",
					"dataPointID": "CDA0067"
				},
				{
					"dataPointName": "NAICS CODE",
					"dataPointID": "CDA0059"
				},
				{
					"dataPointName": "NACE CODE",
					"dataPointID": "CDA0065"
				},
				{
					"dataPointName": "US SIC DESCRIPTION",
					"dataPointID": "CDA0064"
				},
				{
					"dataPointName": "NAICS DESCRIPTION",
					"dataPointID": "CDA0060"
				},
				{
					"dataPointName": "NACE DESCRIPTION",
					"dataPointID": "CDA0066"
				},
				{
					"dataPointName": "NAICS 2012 DESCRIPTION",
					"dataPointID": "CDA0062"
				},
				{
					"dataPointName": "NACE 2 DESCRIPTION",
					"dataPointID": "CDA0068"
				},
                {
                    "dataPointName": "CLIENT NOTE(S)",
                    "dataPointValue": "This is a note."
                }
			]
		},
		{
			"DataServiceOptions": [{
            "dataPointID": "CDA0004",
			"dataPointValue": "Y"
            }]
		}
	]
}';

LC_OC varchar2(30 char);
LC_OC_detail varchar2(300 char);
lr_csr client_csr%ROWTYPE;
lt_mods pkg_avoxcliententity.pt_svc_param;
lc_notes VARCHAR2(1000 char);
lr_structure data_source_structure%ROWTYPE;

BEGIN

pkg_context_api.data_channel_set_param(p_name => 'data_channel', p_value => 'FILE');
SELECT dss.* INTO lr_structure FROM data_source_structure dss WHERE dss.structure_type = '117_CLIENTDATA_API';
pkg_context_api.data_channel_set_param(p_name => 'source_id', p_value => lr_structure.source_id);
pkg_context_api.data_channel_set_param(p_name => 'structure_id', p_value => lr_structure.structure_id);
pkg_context_api.process_set_param(p_name => 'parent_log_id', p_value => dss_log_id_seq.NEXTVAL);

pkg_parse_client_entity_json.json2client_entity( p_json =>lc_json, x_csr => lr_csr 
                                                     , x_client_notes => lc_notes
                                                     , x_modules => lt_mods
                                                     , x_outcome => LC_OC
                                                     , x_outcomeDetail => LC_OC_detail);

DBMS_OUTPUT.PUT_LINE('OC: '||LC_OC);
DBMS_OUTPUT.PUT_LINE('OD Dtl: '||LC_OC_detail);

dbms_output.put_line('cc.legal_name: '||lr_csr.legal_name);
dbms_output.put_line('cc.cl_id: '||lr_csr.cl_id);
dbms_output.put_line('cc.status: '||lr_csr.status);
dbms_output.put_line('cc.op country: '||lr_csr.op_country);
dbms_output.put_line('cc.reg country: '||lr_csr.reg_country);
dbms_output.put_line('cc.spare0: '||lr_csr.spare0);
dbms_output.put_line('notes: '||lc_notes);
dbms_output.put_line('module count: '||lt_mods.COUNT);

FOR X IN 1..LT_MODS.COUNT LOOP
DBMS_OUTPUT.PUT_LINE('SON: '||LT_MODS(X).SERVICE_OPTION_NAME);
DBMS_OUTPUT.PUT_LINE('SID: '||LT_MODS(X).structure_id);
END LOOP;

pkg_context_api.data_channel_clear_all_context;
pkg_context_api.process_clear_all_context;

END;