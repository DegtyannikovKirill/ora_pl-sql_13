/*
* �����: ����������� �.�.
* �������� �������: API ��� ��������� ������� � ������� ��������
*/
-- �������� �������
declare
  c_payment_create_discription constant varchar2(200) := '������ ������';
  �_payment_create_status constant number := 0;
begin
  dbms_output.put_line(c_payment_create_discription||'. ������: '||�_payment_create_status);
end;
/
-- ������ ���������� �������
declare
  c_payment_error_discription constant varchar2(200) := '����� ������� � "��������� ������"';
  �_payment_error_status constant number := 2;
  v_payment_error_reason varchar2(200);
begin
  v_payment_error_reason := '������������ �������';

  dbms_output.put_line(c_payment_error_discription||' � ��������� �������. '||
                      '������: '||�_payment_error_status||'. �������: '||v_payment_error_reason);
end;
/
-- ������ �������
declare
  c_payment_cancel_discription constant varchar2(200) := '������ �������';
  �_payment_cancel_status constant number := 3;
  v_payment_cancel_reason varchar2(200);
begin
  v_payment_cancel_reason := '������ ������������';

  dbms_output.put_line(c_payment_cancel_discription||' � ��������� �������. '||
                      '������: '||�_payment_cancel_status||'. �������: '||v_payment_cancel_reason);
end;
/
-- �������� ���������� �������
declare
  c_payment_success_discription constant varchar2(200) := '�������� ���������� �������';
  c_payment_success_status constant number := 1;
begin

  dbms_output.put_line(c_payment_success_discription||'. ������: '||c_payment_success_status);
end;
/
-- ����������/���������� ������ �� ������� 
declare
  c_payment_update_discription constant varchar2(200) := '������ ������� ��������� ��� ���������';
begin
  dbms_output.put_line(c_payment_update_discription||' �� ������ id_����/��������');
end;
/
-- �������� ������� �������
declare
  c_payment_delete_discription constant varchar2(200) := '������ ������� �������';
begin
  dbms_output.put_line(c_payment_delete_discription||' �� ������ id_�����');
end;
/
