create or replace package ut_utils_pack  is

procedure run_tests(p_package_name user_objects.object_name%type := null);
end ut_utils_pack ;
/
