create or replace package body ut_common_pack is
  procedure ut_failed is
  begin
    raise_application_error(c_error_code_test_failed,
                            c_error_msg_test_failed);
  end;
end ut_common_pack;
/
