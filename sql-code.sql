-- This is the extension part of the SQl | R project.
/* Here I will load all the dataset and make them connected by 
   applying the constraint.*/
-- first create a working database where all work will be done.
-- the data base name is :: codeone

CREATE DATABASE codeone;
-- now show in the RDBMS SQL server how many database are there.
SHOW DATABASES;
-- My working database is "codeone", let that use in.
USE codeone;
-- now all table I uploaded by GUI Navigator.
/* now i will do some wrangling process */
-- moto: to set primary key and connect each table 
-- count number of obs. each table
SELECT count(row_id)FROM superstore  -- 9996 obs.
SELECT count(row_id)FROM customers   -- 9996 obs.
SELECT count(row_id)FROM products    -- 9996 obs.
SELECT count(row_id)FROM sales       -- 9996 obs.
-- all number of obs. are same then itis ok to began mapping.
-- understand the data 
SELECT * FROM superstore 
DESC superstore 
SELECT * FROM customers 
DESC customers 
SELECT * FROM products 
DESC products 
SELECT * FROM sales 
DESC sales

-- Understand and Clean the data one by one table 

-- pre-cleaning observation 

SELECT row_id, count( row_id) 
FROM superstore 
GROUP BY row_id HAVING count(row_id)> 1 
-- |row_id|count( row_id)|
-- |------|--------------|
-- |3     |2             |
-- |9,821 |2             |

SELECT row_id, count( row_id) 
FROM sales  
GROUP BY row_id HAVING count(row_id)> 1 
-- |row_id|count( row_id)|
-- |------|--------------|
-- |3     |2             |
-- |9,821 |2             |
SELECT row_id, count( row_id) 
FROM customers  
GROUP BY row_id HAVING count(row_id)> 1
-- |row_id|count( row_id)|
-- |------|--------------|
-- |3     |2             |
-- |9,821 |2             |
SELECT row_id, count( row_id) 
FROM products  
GROUP BY row_id HAVING count(row_id)> 1
-- |row_id|count( row_id)|
-- |------|--------------|
-- |3     |2             |
-- |9,821 |2             |
-- As I see all the duplicate are in the same obs. row_id

-- work with customers table
-- let see the duplicated values on customer table
WITH customersCTE AS 
     (SELECT *, ROW_NUMBER ()
     OVER (PARTITION BY row_id ORDER BY row_id) AS index1
     FROM customers)
  SELECT * FROM customersCTE WHERE index1 > 1
  -- there is two row duplicated 
  -- let remove all the duplicated values 
  /* here is one problem than the row_id also duplicated so there have no
   * unique value which be my base to work with . thats why i am going to
   * create a unique value by adding a primary key + auto increment with 
   * a specific value and make it easy to clean. i will start from 1000 as
   * a first value to ignore any union values of the partition variable.
   */
  -- add a temp column as primary key to clean the data
  ALTER TABLE customers ADD index1 int NOT NULL AUTO_INCREMENT  PRIMARY KEY FIRST;
-- make the index1 from 1000 to ignore union confusion 
 ALTER TABLE customers
 AUTO_INCREMENT = 1000;
-- let see the data onece 
SELECT * FROM customers
-- now move to delete all the duplicate values
DELETE FROM customers WHERE index1 IN (
SELECT index1 FROM (SELECT index1,ROW_NUMBER() OVER (PARTITION BY row_id)AS frequency FROM customers)AS temp
WHERE frequency > 1 )
-- now all duplicated rows are deleted 
-- now delete the temporary index and row_id
ALTER TABLE customers DROP COLUMNS index1,row_id
-- now do the same process with all tables 
-- ==============================================================
-- work with superstore table
 -- let see the duplicated values on superstore table
WITH superstoreCTE AS 
     (SELECT *, ROW_NUMBER ()
     OVER (PARTITION BY row_id ORDER BY row_id) AS index1
     FROM superstore)
  SELECT * FROM superstoreCTE WHERE index1 > 1
  
-- add a temp column as primary key to clean the data
  ALTER TABLE superstore ADD index1 int NOT NULL AUTO_INCREMENT  PRIMARY KEY FIRST;
-- make the index1 from 1000 to ignore union confusion 
 ALTER TABLE superstore
 AUTO_INCREMENT = 1000;
-- let see the data onece 
SELECT * FROM superstore
-- now move to delete all the duplicate values
DELETE FROM superstore WHERE index1 IN (
SELECT index1 FROM (SELECT index1,ROW_NUMBER() OVER (PARTITION BY row_id)AS frequency FROM superstore)AS temp
WHERE frequency > 1 )
-- now all duplicated rows are deleted 
-- now delete the temporary index and row_id
delecte 
-- ==========================================================
-- let delete all the duplicate obs from products table

-- let see the duplicated values on products table
WITH productsCTE AS 
     (SELECT *, ROW_NUMBER ()
     OVER (PARTITION BY row_id ORDER BY row_id) AS index1
     FROM products)
  SELECT * FROM productsCTE WHERE index1 > 1
-- add a temp column as primary key to clean the data
  ALTER TABLE products ADD index1 int NOT NULL AUTO_INCREMENT  PRIMARY KEY FIRST;
-- make the index1 from 1000 to ignore union confusion 
 ALTER TABLE products
 AUTO_INCREMENT = 1000;
-- let see the data onece 
SELECT * FROM products
-- now move to delete all the duplicate values
DELETE FROM products WHERE index1 IN (
SELECT index1 FROM (SELECT index1,ROW_NUMBER() OVER (PARTITION BY row_id)AS frequency FROM products)AS temp
WHERE frequency > 1 )
-- now all duplicated rows are deleted 
-- now delete the temporary index and row_id
ALTER TABLE products DROP COLUMNS index1,row_id
-- ===========================================
-- let delete all duplicated obs from sales table
 -- let see the duplicated values on sales table
WITH salesCTE AS 
     (SELECT *, ROW_NUMBER ()
     OVER (PARTITION BY row_id ORDER BY row_id) AS index1
     FROM sales)
  SELECT * FROM salesCTE WHERE index1 > 1
-- add a temp column as primary key to clean the data
  ALTER TABLE sales ADD index1 int NOT NULL AUTO_INCREMENT  PRIMARY KEY FIRST;
-- make the index1 from 1000 to ignore union confusion 
 ALTER TABLE sales
 AUTO_INCREMENT = 1000;
-- let see the data onece 
SELECT * FROM sales
-- now move to delete all the duplicate values
DELETE FROM sales WHERE index1 IN (
SELECT index1 FROM (SELECT index1,ROW_NUMBER() OVER (PARTITION BY row_id)AS frequency FROM sales)AS temp
WHERE frequency > 1 )
-- now all duplicated rows are deleted 
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/* now its time to connect all the table, i will delete all the tempory column which 
 * i created and also delete those unwanted colum.  
 */
-- work with super store
ALTER TABLE superstore DROP COLUMN index1 
ALTER TABLE superstore DROP COLUMN row_id
SELECT * FROM superstore
-- let introduce another column which will work as key 
 ALTER TABLE superstore ADD index1 int NOT NULL AUTO_INCREMENT  PRIMARY KEY FIRST;
-- ===============================================================================
-- work with products
ALTER TABLE products DROP COLUMN index1 
ALTER TABLE products DROP COLUMN row_id
SELECT * FROM products
-- let introduce another column which will work as key 
 ALTER TABLE products ADD index1 int NOT NULL AUTO_INCREMENT  PRIMARY KEY FIRST;
-- let connect products table with superstore table by foreign key
ALTER TABLE products 
ADD FOREIGN KEY (index1)REFERENCES superstore(index1)
-- now superstore table and products table are connected
-- ===============================================================================
-- work with customers table
ALTER TABLE customers DROP COLUMN index1 
ALTER TABLE customers DROP COLUMN row_id
SELECT * FROM customers
-- let introduce another column which will work as key 
 ALTER TABLE customers ADD index1 int NOT NULL AUTO_INCREMENT  PRIMARY KEY FIRST;
-- let connect customers table with superstore table by foreign key
ALTER TABLE customers 
ADD FOREIGN KEY (index1)REFERENCES superstore(index1)
-- now superstore table and customers table are connected
-- =================================================================
-- work with sales table
ALTER TABLE sales DROP COLUMN index1 
ALTER TABLE sales DROP COLUMN row_id
SELECT * FROM sales
-- let introduce another column which will work as key 
 ALTER TABLE sales ADD index1 int NOT NULL AUTO_INCREMENT  PRIMARY KEY FIRST;
-- let connect sales table with superstore table by foreign key
ALTER TABLE sales 
ADD FOREIGN KEY (index1)REFERENCES superstore(index1)
-- now superstore table and sales table are connected

-- confirmation of Mapping 
SELECT count(*) FROM superstore -- 9994
SELECT count(*) FROM products -- 9994
SELECT count(*) FROM customers -- 9994
SELECT count(*) FROM sales -- 9994
-- now the data set is all connected and cleaned .. 

-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@2
-- let jump in to analyse ! 

-- As i need to see all the table frequently thats why I use stored Proecedure
delimiter &&
 CREATE PROCEDURE superstore_tbl()
 BEGIN 
 SELECT * FROM codeone.superstore;
 END&&
delimiter ;
  
CALL superstore_tbl() -- let see the RESULT BY this FUNCTION 

delimiter &&
 CREATE PROCEDURE products_tbl()
 BEGIN 
 SELECT * FROM codeone.products;
 END&&
delimiter ;
 
CALL products_tbl()
  
delimiter &&
 CREATE PROCEDURE customers_tbl()
 BEGIN 
 SELECT * FROM codeone.customers;
 END&&
delimiter ;
CALL customers_tbl()
  
delimiter &&
 CREATE PROCEDURE sales_tbl()
 BEGIN 
 SELECT * FROM codeone.sales;
 END&&
delimiter ;
CALL sales_tbl() 
 -- to 10 customers name by sales 
-- top 10 
CALL sales_tbl()

-- top ten customer with maximum sales value 
delimiter //
CREATE PROCEDURE top_ten_customer_sales(IN lim int )
BEGIN 
SELECT DISTINCT  customer_id, customer_name FROM customers 
WHERE row_id IN (SELECT row_id FROM sales WHERE sales > 
(SELECT avg(sales)FROM sales) 
ORDER BY sales DESC )
END // 
delimiter ; -- > back TO defult delimiter(;)
 
CALL top_ten_customer_sales(10)

-- let see top three customers with maximum sales 
CALL top_ten_customer_sales(3)

-- let view some important variable in a virtual table ( by View)
CREATE VIEW customer_sales_details AS 
SELECT c.customer_name,p.product_name,s.sales 
FROM customers AS c INNER JOIN products AS p 
ON c.row_id = p.row_id
INNER JOIN sales AS s
ON c.row_id=s.row_id
ORDER BY s.sales DESC 

-- let display the virtual table 
SELECT * FROM customer_sales_details

 -- long name make it shorter 
RENAME TABLE customer_sales_details TO sales_details

-- to list all the views name 
SHOW FULL TABLES
WHERE table_type='VIEW' 

 -- row number
WITH superstoreCTE AS 
     (SELECT *, ROW_NUMBER ()
     OVER (PARTITION BY row_id ORDER BY row_id) AS index1
     FROM superstore)
  SELECT * FROM superstoreCTE WHERE index1 > 1

 
 
