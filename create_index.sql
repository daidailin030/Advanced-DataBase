--Q1 index
CREATE INDEX numberofOrder_index on ORDERMAIN(to_char(ORDER_TIME, 'Q'));
CREATE INDEX numberofOrder_index2 on ORDERSTATUS(substr(NAME, 1, 3));

--Q2
CREATE INDEX expensiveOrder_index on PRODUCT(name);
--Q6
CREATE INDEX promocode_index on PROMOCODE(percentage);

--Q8
CREATE INDEX promocodeExpiration_index on PROMOCODE(expiration);