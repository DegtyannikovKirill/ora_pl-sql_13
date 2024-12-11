create or replace package ut_common_pack is

  c_client_field_email_id  constant client_data_field.field_id%type := 1;
  c_client_mobile_phone_id constant client_data_field.field_id%type := 2;
  c_client_inn_id          constant client_data_field.field_id%type := 3;
  c_client_birthday_id     constant client_data_field.field_id%type := 4;

  c_non_existing_client_id constant client.client_id%type := -777;

  -- Сообщения об ошибках
  c_error_msg_test_failed constant varchar2(100 char) := 'Unit-тест или API выполнены не верно';

  -- Коды ошибок
  c_error_code_test_failed constant number(10) := -20999;

  -- Генерация значения полей для сущности клиент
  function get_random_client_email return client_data.field_value%type;
  function get_random_client_mobile_phone return client_data.field_value%type;
  function get_random_client_inn return client_data.field_value%type;
  function get_random_client_bday return client_data.field_value%type;

  -- Создание клиента
  function create_default_client(p_client_data t_client_data_array := null)
    return client.client_id%type;

  -- Получить информацию по сущности "Клиент"
  function get_client_info(p_client_id client_data.client_id%type)
    return client%rowtype;

  -- Получить данные по полю клиента
  function get_client_field_value(p_client_id client_data.client_id%type
                                 ,p_field_id  client_data.field_id%type)
    return client_data.field_value%type;

  -- возбуждение исключения о неверном тесте
  procedure ut_failed;

end ut_common_pack;
/
create or replace package body ut_common_pack is
    -- Генерация значения полей для сущности клиент
  function get_random_client_email return client_data.field_value%type is
  begin
    return dbms_random.string('l', 10) || '@' || dbms_random.string('l',
                                                                    10) || '.com';
  end;

  function get_random_client_mobile_phone return client_data.field_value%type is
  begin
    return '+7' || trunc(dbms_random.value(79000000000, 79999999999));
  end;

  function get_random_client_inn return client_data.field_value%type is
  begin
    return trunc(dbms_random.value(1000000000000, 99999999999999));
  end;

  function get_random_client_bday return client_data.field_value%type is
  begin
    return add_months(trunc(sysdate),
                      -trunc(dbms_random.value(18 * 12, 50 * 12)));
  end;

  function create_default_client(p_client_data t_client_data_array := null)
    return client.client_id%type is
    v_client_data t_client_data_array := p_client_data;
  begin
    -- если ничего не передано, то по умолчанию генерим какие-то значения
    if v_client_data is null
       or v_client_data is empty then
      v_client_data := t_client_data_array(t_client_data(c_client_field_email_id,
                                                         get_random_client_email()),
                                           t_client_data(c_client_mobile_phone_id,
                                                         get_random_client_mobile_phone()),
                                           t_client_data(c_client_inn_id,
                                                         get_random_client_inn()),
                                           t_client_data(c_client_birthday_id,
                                                         get_random_client_bday()));
    end if;
  
    return client_api_pack.create_client(p_client_data => v_client_data);
  end;
end ut_common_pack;
/
