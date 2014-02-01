SELECT name, city FROM agents WHERE name = 'Smith';
SELECT pid, name, quantity FROM products WHERE priceusd > 1.25;
SELECT ordno, aid FROM orders;
SELECT name, city FROM customers WHERE city = 'Dallas';
SELECT name FROM agents WHERE city <> 'New York' AND city <> 'Newark';
SELECT * FROM products WHERE city <> 'New York' AND city <> 'Newark' AND priceusd >= 1;
SELECT * FROM orders WHERE mon = 'jan' OR mon = 'mar';
SELECT * FROM orders WHERE mon = 'feb' AND dollars < 100;
SELECT * FROM orders WHERE cid = 'c001';
