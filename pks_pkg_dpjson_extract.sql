create or replace PACKAGE pkg_dpjson_extract AS

  -- $Author: $
  -- $Date: $
  -- $Rev: $
  -- $URL: $


TYPE lr_dp IS RECORD (
   cl_id datapoint_obj
 , cl_source_id datapoint_obj
 , avid datapoint_obj
 , cr_id central_Records.cr_id%TYPE, content_timestamp VARCHAR2(100 CHAR), record_status VARCHAR2(100 CHAR)
 , cr_status central_Records.status%TYPE, extract_type VARCHAR2(100 CHAR)
 , datapoints datapoint_tab
 , multisets datapoint_tab
 , sparedata datapoint_tab
 , metadata datapoint_tab
 , changedata dpchange_tab
 );
TYPE lt_dp_data_rc_tab IS TABLE OF lr_dp INDEX BY BINARY_INTEGER;


PROCEDURE assemble_record(p_structure IN data_source_structure%ROWTYPE, p_modules IN VARCHAR2, p_cr_id IN NUMBER
                                                    , x_outcome OUT NOCOPY VARCHAR2
                                                    , x_outcomeDetail OUT NOCOPY VARCHAR2
                                                    , x_data OUT NOCOPY CLOB
                                                    , x_dss_log_id OUT NOCOPY NUMBER);

END pkg_dpjson_extract;