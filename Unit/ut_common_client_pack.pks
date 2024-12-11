create or replace package ut_common_client_pack is

  c_client_field_email_id  constant client_data_field.field_id%type := 1;
  c_client_mobile_phone_id constant client_data_field.field_id%type := 2;
  c_client_inn_id          constant client_data_field.field_id%type := 3;
  c_client_birthday_id     constant client_data_field.field_id%type := 4;

  c_non_existing_client_id constant client.client_id%type := -777;
  
  -- Генерация значения полей для сущности клиент
  function get_random_client_email return client_data.field_value%type;
  function get_random_client_mobile_phone return client_data.field_value%type;
  function get_random_client_inn return client_data.field_value%type;
  function get_random_client_bday return client_data.field_value%type;
  
  -- Создаем деффолтного клиента
  function create_default_client(p_client_data t_client_data_array := null) return client.client_id%type;
  --
  function get_client_field_value(p_client_id client_data.client_id%type
                                 ,p_field_id  client_data.field_id%type) return client_data.field_value%type;

end ut_common_client_pack;
/
