--Mike Mucci
--Lab 5
--2/21/14

--1
SELECT agents.city
FROM agents,
     customers,
     orders
WHERE customers.cid = orders.cid
AND   customers.name = 'Basics'
AND   agents.aid = orders.aid

--2 ? 
SELECT aid
FROM customers,
     orders
WHERE customers.city = 'Kyoto'
AND   customers.cid = orders.cid

--3
SELECT name
FROM customers
WHERE cid NOT IN (SELECT cid
		  FROM orders)

--4
SELECT customers.name
FROM customers
LEFT OUTER JOIN orders
ON orders.cid = customers.cid
WHERE orders.ordno is NULL


--7
SELECT customers.name, customers.city
FROM customers
WHERE customers.city = (SELECT MIN(products.city) FROM products)



select distinct pid
from orders
where aid in (
select aid
from orders
where cid in (
select cid
from customers
where city = 'Kyoto'))