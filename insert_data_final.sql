begin
    insert into Product(id_product, name, price, id_image)
    select rownum, 'Product ' || to_char(rownum), round(dbms_random.value(1, 500),2), rownum
    from dual
    connect by level <= 100;
    
    insert_into_customer();
    insert_into_Order();
    insert_into_OrderProduct();

    insert_into_promoCode(); 

    insert into PaymentType(name) values('Cash');
    insert into PaymentType(name) values('Credit Card');
    insert into PaymentType(name) values('PayPal');

    insert into OrderStatus(name) values('Preparing');
    insert into OrderStatus(name) values('Delivered');
    insert into OrderStatus(name) values('Returned');
    insert into OrderStatus(name) values('Payed');
    insert into OrderStatus(name) values('Processing');


    update_OrderMain();
end;
/
--Insert Image was done by importing a .csv file and so it does not appear in this file

Create or replace procedure insert_into_customer as
    p_id integer;
    random varchar2(8);
    begin
        for i in 1..10000
            loop
                SELECT customer_seq.nextval
                INTO p_id
                FROM dual;

                select dbms_random.string('L', 8) into random from dual;
                insert into customer(id_customer, email, first_name, last_name, pass) values (
                                                p_id,
                                                'email@' || random,
                                                'first-' || random,
                                                'last-' || random,
                                                get_hash('email@' || random, random)
                );
                commit;
            end loop;
    end;
/
create or replace FUNCTION get_hash (p_email  IN  VARCHAR2,
                     p_password  IN  VARCHAR2)
    RETURN VARCHAR2 AS
    l_salt VARCHAR2(7) := 'mySalt';
  BEGIN
    RETURN DBMS_CRYPTO.HASH(UTL_RAW.CAST_TO_RAW(p_email || l_salt || UPPER(p_password)),DBMS_CRYPTO.HASH_SH1);
  END;
/
create or replace procedure insert_into_promoCode as
    next_id integer;
    randomCust integer;
    randomName varchar2(5);
    randomDate date;
    randomPer float;
    begin
        for i in 1..100000
            loop
                select id_promoCode_sequence.nextval
                into next_id
                from dual;
                
                select dbms_random.string('A', 5) into randomName from dual;
                select dbms_random.value(1, 10000) into randomCust from dual;
                select trunc(dbms_random.value(0.01, 0.99),2) into randomPer from dual; 
                select to_date('2021-01-01', 'yyyy-mm-dd')+trunc(dbms_random.value(1,1000)) into randomDate from dual;
                
                insert into PromoCode(id,name,percentage,expiration,customer_id,spent) values (
                                                next_id,
                                                randomName,
                                                randomPer,
                                                randomDate,
                                                randomCust,
                                                '0'
                );
                commit;
            end loop;
    end;
/

create or replace procedure insert_invoice(user_id in integer, ordertime in date, amount in float, payment_id in integer, order_id in integer)
as 
    first_name customer.first_name%type;
    last_name customer.last_name%type;
    email customer.email%type;
    payment paymentType.name%type;
    p_id integer;
    result varchar2(500);

begin
    select cu.first_name, cu.last_name, cu.email into first_name, last_name, email
    from Customer cu
    where cu.id_customer = user_id;
    
    select pt.name into payment
    from PaymentType pt
    where pt.id_payment = payment_id;
    
    SELECT id_invoice_sequence.nextval
                INTO p_id
                FROM dual;
            
    select json_object('person' is json_object('firstName' is first_name, 'secondName' is last_name, 'email' is email), 'paymentType' is payment, 'orderTime' is to_char(orderTime, 'DDMMYYYY'), 'amount' is amount) into result from dual;
    insert into invoice values (p_id, result, order_id);
    
END;
/
create or replace procedure insert_into_Order as
    next_id integer;
    randomOS integer;
    randomPay integer;
    randomCust integer;
    randomDate date;
   
    begin
        for i in 1..10000
            loop
                select id_order_sequence.nextval
                into next_id
                from dual;
                
                select dbms_random.value(1, 10000) into randomCust from dual;
                select dbms_random.value(1, 3) into randomPay from dual;
                select dbms_random.value(1, 5) into randomOS from dual;
                select to_date('2021-01-01', 'yyyy-mm-dd')+trunc(dbms_random.value(1,370)) into randomDate from dual;
                
                insert into OrderMain(id_order,order_time,amount,order_status_id,payment_type_id,id_customer) values (
                                                next_id,
                                                randomDate,
                                                0.0,
                                                randomOS,
                                                randomPay,
                                                randomCust
                );
                insert_invoice(randomCust, randomDate, 0.0, randomPay, next_id);
                
                commit;
            end loop;
end;
/
create or replace procedure insert_into_OrderProduct as
    q integer;
    order_id integer;
    product_id integer;
    next_id integer;
    
    begin
        for i in 1..100000
            loop
                select id_OrderProduct_sequence.nextval
                    into next_id
                    from dual;
                select dbms_random.value(1,10000) into order_id from dual;
                select dbms_random.value(1, 100) into product_id from dual;
                select dbms_random.value(1, 10) into q from dual;
             
                insert into OrderProduct(id, id_product, id_order, quantity) values (
                                                next_id,
                                               product_id,
                                               order_id,
                                               q
                );
                commit;
            end loop;
end;
/
create or replace procedure update_OrderMain as
    price_result float;
    begin
        for i in 1..10000
            loop
            select sum(price) into price_result from (
                  select o.ID, o.ID_ORDER, (o.QUANTITY * PRICE) as price
                  from ORDERPRODUCT o
                           join PRODUCT p on p.ID_PRODUCT = o.ID_PRODUCT
                  where o.ID_ORDER = i
              );
             
            update OrderMain set amount = price_result where id_order = i;
                commit;
            end loop;
end;
/
