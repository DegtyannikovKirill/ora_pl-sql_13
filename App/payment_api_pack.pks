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
c_field_id_is_null              constant varchar2(200 char) := 'ID поля не может быть пустым';
c_field_valie_is_null           constant varchar2(200 char) := 'Значение в поле не может быть пустым';
c_array_is_empty                constant varchar2(200 char) := 'Коллекция не содержит данных';
c_payment_reason_is_null        constant varchar2(200 char) := 'Причина не может быть пустой';
c_object_id_is_null             constant varchar2(200 char) := 'ID объекта не может быть пустым';
c_object_value_is_null          constant varchar2(200 char) := 'Значение объекта не может быть пустым';

-- Коды ошибок
c_error_code_invalid_parameter  constant number(10) := -20100;

-- Объекты исключений
e_invalid_parameter             exception;
pragma exception_init(e_invalid_parameter, c_error_code_invalid_parameter);

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
