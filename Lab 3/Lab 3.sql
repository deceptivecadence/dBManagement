--Mike Mucci
--Spring 2014
--2/7/14

﻿--1
SELECT name, city
FROM agents
WHERE name = 'Smith';

--2
SELECT pid, name, quantity
FROM products
WHERE priceusd > 1.25;

--3
SELECT ordno, aid
FROM orders;

--4
SELECT name, city
FROM customers
WHERE city = 'Dallas';

--5
SELECT name
FROM agents
WHERE city <> 'New York' AND city <> 'Newark';

--6
SELECT *
FROM products
WHERE city <> 'New York' AND city <> 'Newark' AND priceusd >= 1;

--7
SELECT *
FROM orders
WHERE mon = 'jan' OR mon = 'mar';

--8
SELECT *
FROM orders
WHERE mon = 'feb' AND dollars < 100;

--9
SELECT *
FROM orders
WHERE cid = 'c001';
