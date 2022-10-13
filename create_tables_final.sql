
CREATE TABLE Image
(
 id_image         integer NOT NULL ,
 created    date NOT NULL ,
 content     varchar2(380) NOT NULL ,
 other_data varchar2(45) NULL ,
PRIMARY KEY (id_image)
);

create table Product
 (id_product int,
  name varchar2(50) NOT NULL,
  price float NOT NULL,
  id_image int,
  PRIMARY KEY (id_product),
  CONSTRAINT const_image FOREIGN KEY (id_image) REFERENCES image (id_image)
);

 create SEQUENCE id_product_sequence;

 create table Customer
 (id_customer integer, 
  first_name varchar2(50), 
  last_name varchar2(50),
  email varchar2(50) NOT NULL UNIQUE,
  pass varchar2(160)NOT NULL,
  PRIMARY KEY (id_customer)
  );

 create SEQUENCE customer_seq;

 create table PromoCode
 (id integer,
  name varchar2(50) NOT NULL,
  percentage float NOT NULL,
  expiration date NOT NULL,
  customer_id integer,
  spent char(1),
  PRIMARY KEY (id),
  CONSTRAINT customer_fk FOREIGN KEY (customer_id) REFERENCES Customer (id_customer)
);
 create SEQUENCE id_promoCode_sequence;

 create table PaymentType
 (id_payment integer,
 name varchar2(50),
 PRIMARY KEY (id_payment)
);

create SEQUENCE id_payment_sequence;

CREATE OR REPLACE TRIGGER payment_sequence 
	BEFORE INSERT ON PaymentType
    FOR EACH ROW
BEGIN
    SELECT  id_payment_sequence.nextval
    INTO :new.id_payment
    FROM dual;
END;
/

create table OrderStatus
 (id_orderstatus integer,
 name varchar2(50),
 PRIMARY KEY (id_orderstatus)
);

create SEQUENCE id_orderstatus_sequence;

CREATE OR REPLACE TRIGGER orderstatus_sequence
    BEFORE INSERT ON OrderStatus
    FOR EACH ROW
BEGIN
    SELECT  id_orderstatus_sequence.nextval
    INTO :new.id_orderstatus
    FROM dual;
END;
/
create table OrderMain
 (id_order integer, 
  id_customer integer, 
  order_time date NOT NULL, 
  payment_type_id integer NOT NULL,
  order_status_id integer NOT NULL,
  amount float,
  PRIMARY KEY (id_order),
  CONSTRAINT const_user FOREIGN KEY (id_customer) REFERENCES Customer (id_customer),
  CONSTRAINT const_payment FOREIGN KEY (payment_type_id) REFERENCES PaymentType (id_payment),
  CONSTRAINT const_orderstauts FOREIGN KEY (order_status_id) REFERENCES OrderStatus (id_orderstatus)
);

create SEQUENCE id_order_sequence;
create table Invoice
 (id_invoice integer,
 invoice clob,
 order_id integer,
 constraint json_check check(invoice is json),
 PRIMARY KEY (id_invoice),
 CONSTRAINT const_order FOREIGN KEY (order_id) REFERENCES OrderMain (id_order)
);

create SEQUENCE id_invoice_sequence;

create table OrderProduct(
id INTEGER,
id_product INTEGER,
id_order INTEGER,
quantity INTEGER,
PRIMARY KEY (id),
CONSTRAINT const_order2 FOREIGN KEY (id_order) REFERENCES OrderMain (id_order),
CONSTRAINT const_prod2 FOREIGN KEY (id_product) REFERENCES Product (id_product)
);

create SEQUENCE id_OrderProduct_sequence;

commit;