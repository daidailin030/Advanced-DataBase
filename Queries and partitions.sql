--number of orders in first quartals of years where order status is payed
--the customer with the most expensive order (the bigest amount) grouped by payment type
--top 10 most expensive products 
--top 10 orders with the smallest amount to be payed
--the order with the most products (overall products not product types)
--customer with the most promo codes that give more than 50% discount
--promo codes grouped by % (<20,>20&<40,>40)
--all promo codes which will be expired by February 2022
--% of orders where order statuse is returned
--top 10 product with most orders

--1. number of orders in first quartals of years where order status is payed
select count(*) as numberOfOrder
from ORDERMAIN om
join ORDERSTATUS O on om.ORDER_STATUS_ID = O.ID_ORDERSTATUS
where substr(O.NAME, 1, 3) = 'Pay' and to_char(om.ORDER_TIME, 'Q') = 1;

--2. the customer with the most expensive orders (the bigest amount) grouped by payment type
select email, name from (
    select email, name, row_number() over (partition by ID_PAYMENT order by result desc) as resultRank, result from (
                  select c.id_customer, c.email, p.ID_PAYMENT, p.NAME, sum(o.AMOUNT) as result
                  from customer c
                           join ORDERMAIN O on c.id_customer = O.id_customer
                           join PAYMENTTYPE P on P.ID_PAYMENT = O.PAYMENT_TYPE_ID
                  group by c.id_customer, c.email, p.ID_PAYMENT, p.NAME
              )
    ) where resultRank = 1;

--3. top 10 most expensive products 
select * from product order by price fetch next 10 rows only;

--4. op 10 orders with the smallest amount to be payed
select * from ordermain order by amount fetch next 10 rows only;


--5. the order with the most products (overall products not product types)
select  *
from OrderMain join OrderProduct using(id_order)
order by quantity desc;


--6. customer with the most promo codes that give more than 50% discount
select id_customer, count(id_customer)
    from Customer
    join PromoCode 
    ON Customer.id_customer = PromoCode.customer_id 
    where percentage > 0.5
    group by (id_customer)
    order By count(id_customer) desc;

--7. promo codes grouped by % (<20,>20&<40,>40)
                  select sum(case when percentage < 0.2 then 1 else 0 end)                       as LessThan20,
                         sum(case when percentage >= 0.2 and PERCENTAGE < 0.4 then 1 else 0 end) as Between20And40,
                         sum(case when percentage >= 0.4 then 1 else 0 end)                       as HigherThan40
                  from PROMOCODE;

--8. all promo codes which will be expired by February 2022
select * from promocode 
where expiration > to_date('31-01-2022','DD-MM-YYYY') AND expiration < to_date('01-03-2022','DD-MM-YYYY');

--9. % of orders where order status is returned
select (count(returned)/count(*)) * 100 from (
                  select (case when substr(o2.NAME, 1, 3) = 'Ret' then 1 else null end) as returned
                  from ORDERMAIN o
                           join ORDERSTATUS O2 on O2.ID_ORDERSTATUS = o.ORDER_STATUS_ID
              );

--10. top 10 product with most orders
select * from (
                  select p.name, count(*)
                  from PRODUCT p
                           join ORDERPRODUCT O on p.ID_PRODUCT = O.ID_PRODUCT
                  group by p.ID_PRODUCT, p.name
                  order by count(*) desc
              ) where rownum <= 10;

--orderproduct test
select *
from orderproduct
where quantity>5 OR quantity<3;


-- create partition
drop table orderproduct;

create table OrderProduct(
id INTEGER,
id_product INTEGER,
id_order INTEGER,
quantity INTEGER,
PRIMARY KEY (id),
CONSTRAINT const_order2 FOREIGN KEY (id_order) REFERENCES OrderMain (id_order),
CONSTRAINT const_prod2 FOREIGN KEY (id_product) REFERENCES Product (id_product)
)

partition by range(quantity)(
partition small values less than(4),
partition madium values less than(8),
partition big values less than(11)
);

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

begin
    insert_into_OrderProduct();
end;
/

select * from orderproduct PARTITION (small);
