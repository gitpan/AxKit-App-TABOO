CREATE TABLE customers (
       username 	VARCHAR(8) PRIMARY KEY NOT NULL,
       address          VARCHAR(50),
       locality		VARCHAR(30),
       code		VARCHAR(10),
       contactstatus	SMALLINT,
       comment		VARCHAR(80)
);


CREATE TABLE products (
       prodid	      VARCHAR(10) PRIMARY KEY NOT NULL,
       catname	      VARCHAR(15) NOT NULL,
       title	      VARCHAR(70) NOT NULL,
       descr	      TEXT,
       imgsmallurl    VARCHAR(254),
       imglargeurl    VARCHAR(254),
       imgcaption     VARCHAR(254),
       comment	      VARCHAR(80)
);

CREATE TABLE productsubtypes (
       prodsubid	     VARCHAR(10) NOT NULL, 
       prodid		     VARCHAR(10) NOT NULL, 
       title		     VARCHAR(70),
       stockconfirmed	     INT,
       stockshipped	     INT,
       stockordered	     INT
);

CREATE TABLE productprices (
       prodid	      VARCHAR(10) NOT NULL,
       volume	      SMALLINT NOT NULL,
       price	      NUMERIC(6,2) NOT NULL
);


CREATE TABLE orders (
       orderid	    INT PRIMARY KEY NOT NULL,
       username	    VARCHAR(8),
       totalprice   NUMERIC(6,2) NOT NULL,
       paid 	    NUMERIC(6,2),
       paymentopt   SMALLINT,
       status	    SMALLINT,
       orderdate    TIMESTAMP,
       paiddate     TIMESTAMP,
       shippeddate  TIMESTAMP,
       tracker	    VARCHAR(20),
       errormode    INT,
       comment      VARCHAR(80)
);



CREATE TABLE ordereditems (
       username		  VARCHAR(8),
       prodid		  VARCHAR(10),
       orderid		  INT,
       prodsubid	  VARCHAR(10),
       volume		  SMALLINT
);
