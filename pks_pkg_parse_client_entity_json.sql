create or replace package pkg_parse_client_entity_json AS

  -- $Author: $
  -- $Date: $
  -- $Rev: $
  -- $URL: $

TYPE lr_dssd_spares IS RECORD (field_name client_file_definition.field_name%TYPE, element_name client_file_definition.proprietry_name%TYPE, attr_ext_id data_attribute.external_attribute_id%TYPE);
TYPE cfd_spares IS TABLE OF lr_dssd_spares;

PROCEDURE json2client_entity(p_json IN CLOB, x_csr IN OUT NOCOPY client_csr%ROWTYPE
                                                     , x_client_notes OUT NOCOPY client_entity_note.note_text%TYPE
                                                     , x_modules OUT NOCOPY pkg_avoxcliententity.pt_svc_param
                                                     , x_outcome OUT NOCOPY VARCHAR2
                                                     , x_outcomeDetail OUT NOCOPY VARCHAR2);

END pkg_parse_client_entity_json;