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

--2 
SELECT DISTINCT o2.pid
FROM customers 
JOIN orders AS o1
ON customers.cid = o1.cid
RIGHT JOIN orders AS o2
ON o2.aid = o1.aid
WHERE customers.city = 'Kyoto'
ORDER BY o2.pid ASC

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

--5
SELECT DISTINCT customers.name AS "Customer Name" , city_cid.name AS "Agent Name"
FROM customers
JOIN (
	SELECT agents.name, agents.city, orders.cid
	FROM agents
	JOIN orders
	ON agents.aid = orders.aid) as city_cid
ON customers.cid = city_cid.cid
AND customers.city = city_cid.city

--6
SELECT customers.name, agents.name, agents.city
FROM customers
JOIN agents
ON agents.city = customers.city

--7
SELECT name, city
FROM customers
WHERE city in (
		SELECT city
		FROM (
			SELECT p1.city, SUM(p1.quantity) as sum
			FROM products AS p1
			GROUP BY p1.city
			ORDER BY sum ASC
			LIMIT 1
		)AS sumTable2
)

