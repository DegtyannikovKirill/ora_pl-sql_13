create or replace package ut_payment_api_pack is

type t_payment_info_for_ut is record( payment_id                  payment.payment_id%type
                                    , payment_sum                 payment.summa%type
                                    , currency_id                 payment.currency_id%type
                                    , payment_from_client_id      payment.from_client_id%type
                                    , payment_to_client_id        payment.to_client_id%type
                                    , payment_detail_data         t_payment_detail_array
                                    , current_dtime               timestamp := systimestamp
                                    , payment_reason              payment.status_change_reason%type
                                    );
g_payment_info t_payment_info_for_ut;


--%suite(UNIT-тесты для объекта "Платеж")
--%suitepath(payments)

--%beforeeach(setup_random_data_for_payment, setup_random_data_for_payment_detail)
--%aftereach(cleanap_g_data)

--%context(positive_tests)

  --%test(Создание платежа. Проверка значений в таблице payment)
  procedure create_payment_check_payment_filds;

  --%test(Перевод платежа в статус "ошибочный". Проверка статуса, причины и тех.даты)
  --%beforetest(create_payment_on_global_parameters, setup_random_payment_reason)
  procedure fail_payment_check_status_and_resons;

--%endcontext

--%context(negative_tests)

  --%test(Создание платежа. Создание с пустым значением "payment_sum)
  --%throws(common_pack.c_error_code_invalid_parameter)
  procedure create_payment_empty_payment_sum;

  --%test(Перевод платежа в статус "ошибочный". Создание с пустым значением "payment_id")
  --%throws(common_pack.c_error_code_invalid_parameter)
  procedure fail_payment_empty_payment_id;

--%endcontext

procedure create_payment_on_global_parameters;
procedure setup_random_data_for_payment;
procedure setup_random_data_for_payment_detail;
procedure setup_random_payment_reason;
procedure cleanap_g_data;

end ut_payment_api_pack;

/
