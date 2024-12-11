create or replace package common_pack is

  -- Purpose : пакет с общими константами для сущностей “платеж”, “детали платежа”

  -- Описание ошибок
  c_error_msg_field_id_is_null              constant varchar2(200 char) := 'ID поля не может быть пустым';
  c_error_msg_field_valie_is_null           constant varchar2(200 char) := 'Значение в поле не может быть пустым';
  c_error_msg_array_is_empty                constant varchar2(200 char) := 'Коллекция не содержит данных';
  c_error_msg_payment_reason_is_null        constant varchar2(200 char) := 'Причина не может быть пустой';
  c_error_msg_object_id_is_null             constant varchar2(200 char) := 'ID объекта не может быть пустым';
  c_error_msg_object_value_is_null          constant varchar2(200 char) := 'Значение объекта не может быть пустым';
  c_error_msg_delete_forbidden              constant varchar2(200 char) := 'Удаление объекта запрещено';
  c_error_msg_payment_dml_disallow          constant varchar2(200 char) := 'Изменения разрещены только через пакет payment_api_pack';
  c_error_msg_payment_detail_dml_disallow   constant varchar2(200 char) := 'Изменения разрещены только через пакет payment_detail_api_pack';
  c_error_msg_inactive_object_state         constant varchar2(200 char) := 'Объект в конечном статусе. Изменения невозможны';
  c_error_msg_object_notfound               constant varchar2(200 char) := 'Объект не найден';
  c_error_msg_object_locked                 constant varchar2(200 char) := 'Объект заблокирован';

  -- Объекты исключений
  -- Коды ошибок
  c_error_code_invalid_parameter            constant number(10) := -20100;
  c_error_code_delete_forbidden             constant number(10) := -20101;
  c_error_code_payment_dml_disallow         constant number(10) := -20102;
  c_error_code_payment_detail_dml_disallow  constant number(10) := -20103;
  c_error_code_inactive_object_state        constant number(10) := -20104;
  c_error_code_object_notfound              constant number(10) := -20105;
  c_error_code_object_locked                constant number(10) := -20106;

  -- неволидный входной параметр
  e_invalid_parameter exception;
  pragma exception_init(e_invalid_parameter, c_error_code_invalid_parameter);

  -- запрет удаления строки в payment
  e_delete_forbidden exception;
  pragma exception_init(e_delete_forbidden, c_error_code_delete_forbidden);

  -- запред ручных DML над таблицей PAYMENT
  e_payment_dml_disallow exception;
  pragma exception_init(e_payment_dml_disallow, c_error_code_payment_dml_disallow);

  -- запред ручных DML над таблицей PAYMENT_DETAIL
  e_payment_detail_dml_disallow exception;
  pragma exception_init(e_payment_detail_dml_disallow, c_error_code_payment_detail_dml_disallow);
  
  -- запрет работы с объектом, находится в конечном стостоянии
  e_object_inactive exception;
  pragma exception_init(e_object_inactive, c_error_code_inactive_object_state);
  
  -- обьект не найден
  e_object_notfound exception;
  pragma exception_init(e_object_notfound, c_error_code_object_notfound);
  
  -- запись заблокирована
  e_row_locked exception;
  pragma exception_init(e_row_locked, -00054);
  
  -- объект заблокирован
  e_object_locked exception;
  pragma exception_init(e_object_locked, c_error_code_object_locked);
  
  -- Включение/выключение разрешения на ручной DML 
  procedure enable_manual_changes;
  procedure disable_manual_changes;
  
  function is_manual_changes_allowed return boolean;

end common_pack;
/
