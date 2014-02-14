--Mike Mucci
--Spring 2014
--Lab 4
--2/13/14

--1
select city
from agents
where aid in (
		select aid
		from orders
		where cid in (
				select cid
				from customers
				where name = 'Basics'))

--2
select distinct pid
from orders
where aid in (
		select aid
		from orders
		where cid in (
				select cid
				from customers
				where city = 'Kyoto'))
--3
select cid, name
from customers
where cid not in (
		select cid
		from orders
		where aid = 'a03')

--4
select cid, name
from customers
where cid in (
		select cid
		from (
			select cid 
			from orders
			where pid = 'p01')
			as cid
			where cid in (
					select distinct cid
					from orders
					where pid = 'p07'))
--5
select distinct pid
from orders
where cid in (
		select cid
		from orders
		where aid = 'a03')

--6
select name, discount
from customers
where cid in (
		select distinct cid
		from orders
		where aid in (
				select aid
				from agents
				where city in ('Duluth','Dallas')))

--7
select *
from customers
where discount in (
			select discount
			from customers
			where city in ('Dallas', 'Kyoto'))