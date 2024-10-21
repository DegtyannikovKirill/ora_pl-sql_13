create or replace package payment_api_pack is

-- Author  : Дегтянников К.А.
-- Created : 14.10.2024 18:52:13
-- Purpose : API по платежу

-- Статусы платежа
с_status_create                 constant payment.status%type := 0;
c_status_success                constant payment.status%type := 1;
с_status_error                  constant payment.status%type := 2;
с_status_cancel                 constant payment.status%type := 3;

-- Причины перевода платежа на "проблемный" статус

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

-- Объекты исключений
-- Коды ошибок
c_error_code_invalid_parameter            constant number(10) := -20100;
c_error_code_delete_forbidden             constant number(10) := -20101;
c_error_code_payment_dml_disallow         constant number(10) := -20102;
c_error_code_payment_detail_dml_disallow  constant number(10) := -20103;

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

-- проверка на прямой DML
procedure check_payment_dml_allowed;

/*** 
* "Создание платежа"
* @param p_payment_from_client_id - ОТ КАКОГО клиента платеж
* @param p_payment_to_client_id   - КАКОМУ клиенту платеж
* @param p_payment_sum            - сумма платежа
* @param p_currency_id            - валюта
* @param p_payment_date           - дата занесения платежа
* @param p_payment_detail_data    - коллекция с деталями платежа
* 
* @return NUMBER - ID созданного платежа
***/
function create_payment( p_payment_from_client_id   payment.from_client_id%type
                       , p_payment_to_client_id     payment.to_client_id%type
                       , p_payment_sum              payment.summa%type
                       , p_currency_id              payment.currency_id%type
                       , p_payment_date             timestamp
                       , p_payment_detail_data      t_payment_detail_array
                       )
return payment.payment_id%type;

/*** 
* "Успешное завершение платежа"
* @param p_payment_id  - ID платежа
***/
procedure successful_finish_payment(p_payment_id payment.payment_id%type);

/*** 
* "Сброс платежа в ошибочный статус"
* @param p_payment_id             - ID платежа
* @param p_payment_error_reason   - Причина перевода в ошибочный статус
***/
procedure fail_payment( p_payment_id            payment.payment_id%type
                      , p_payment_error_reason  payment.status_change_reason%type
                      );

/*** 
* "Отмена платежа"
* @param p_payment_id              - ID платежа
* @param p_payment_cancel_reason   - Причина отмены платежа
***/
procedure cancel_payment( p_payment_id              payment.payment_id%type
                        , p_payment_cancel_reason   payment.status_change_reason%type
                        );

end payment_api_pack;
/
