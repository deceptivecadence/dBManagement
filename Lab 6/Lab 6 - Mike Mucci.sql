--Mike Mucci
--Lab 6
--2/27/14

--1
SELECT name, city
FROM customers
WHERE city in (
		SELECT city
		FROM (
			SELECT city, SUM(quantity)
			FROM products
			GROUP BY city
			ORDER BY sum DESC
			LIMIT 1) as mostProdCity
	      )

--2
SELECT name, city
FROM customers
WHERE city in (
		SELECT city
		FROM (
			SELECT city, SUM(quantity)
			FROM products
			GROUP BY city
			ORDER BY SUM DESC) as mostProdCity
	      )

--3
SELECT products.*
FROM products
JOIN (SELECT AVG(priceusd) FROM products) AS average
ON products.priceusd > average.avg

--4
SELECT customers.name, orders.pid, orders.dollars
FROM orders
JOIN customers
ON orders.cid = customers.cid
ORDER BY dollars DESC

--5
SELECT customers.name, COALESCE(orderSum.sum , 0)
FROM customers 
LEFT JOIN(SELECT cid, SUM(qty) FROM orders GROUP BY cid) AS orderSum
ON orderSum.cid = customers.cid
ORDER BY customers.cid ASC

--6
SELECT customers.name, products.name, agents.name
FROM customers
JOIN orders
ON orders.cid = customers.cid
JOIN products
ON orders.pid = products.pid
JOIN agents
ON orders.aid = agents.aid
WHERE orders.aid in (SELECT aid FROM agents WHERE city = 'New York')

--7
SELECT *
FROM(
	SELECT orders.*, ((orders.qty * products.priceUSD)*(1-(customers.discount*.01))) as "realDollarAmount"
	FROM  orders
	JOIN products
	ON orders.pid = products.pid
	JOIN customers
	ON orders.cid = customers.cid) AS combo
WHERE combo.dollars <> combo."realDollarAmount"

