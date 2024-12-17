create or replace package ut_common_pack is
  -- Вспомогательный пакет для вего фреймворка

  -- Сообщения об ошибках
  c_error_msg_test_failed constant varchar2(100 char) := 'Unit-тест или API выполнены не верно';

  -- Коды ошибок
  c_error_code_test_failed constant number(10) := -20999;

  -- возбуждение исключения о неверном тесте
  procedure ut_failed;

end ut_common_pack;
/
