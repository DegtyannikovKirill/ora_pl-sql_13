create or replace package ut_payment_detail_api_pack is

--%suite(UNIT-тесты для объекта "Детали платежа")
--%suitepath(payments)

--%beforeeach(ut_payment_api_pack.setup_random_data_for_payment, ut_payment_api_pack.setup_random_data_for_payment_detail)
--%aftereach(ut_payment_api_pack.cleanap_g_data)

--%context(positive_tests)

  --%test(Создание платежа. Проверка значений в таблице payment_detail)
  procedure create_payment_check_payment_detail_filds;

  --%test(Добавление/обновление данных по платежу. Проверка, что поля обновились)
  --%beforetest(ut_payment_api_pack.create_payment_on_global_parameters)
  procedure update_payment_detail_check_field_value;

--%endcontext

--%context(negative_tests)

  --%test(Создание платежа. Создание с пустыми деталями платежа)
  --%throws(common_pack.c_error_code_invalid_parameter)
  procedure create_payment_empty_payment_detail;

  --%test(Добавление/обновление данных по платежу. Создание с пустым payment_id)
  --%beforetest(ut_payment_api_pack.create_payment_on_global_parameters)
  --%throws(common_pack.c_error_code_invalid_parameter)
  procedure update_payment_detail_empty_payment_id;

--%endcontext

procedure setup_random_payment_detail_data;

end ut_payment_detail_api_pack;
/
