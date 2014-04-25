--Mike Mucci
--4/25/14
--Database Project
--Alan Labouseur

---Create Statements---

DROP TABLE IF EXISTS "Dark Souls Bosses".locations;
DROP TABLE IF EXISTS "Dark Souls Bosses".races;
DROP TABLE IF EXISTS "Dark Souls Bosses".elements;
DROP TABLE IF EXISTS "Dark Souls Bosses".bosses;
DROP TABLE IF EXISTS "Dark Souls Bosses".weaknesses;
DROP TABLE IF EXISTS "Dark Souls Bosses".resistances;
DROP TABLE IF EXISTS "Dark Souls Bosses".items;
DROP TABLE IF EXISTS "Dark Souls Bosses".offensiveItems;
DROP TABLE IF EXISTS "Dark Souls Bosses".defensiveItems;
DROP TABLE IF EXISTS "Dark Souls Bosses".bossDrops;

CREATE TABLE "Dark Souls Bosses".locations(
	lid			SERIAL,
	name			TEXT NOT NULL UNIQUE,
	PRIMARY KEY(lid)
);

CREATE TABLE "Dark Souls Bosses".races(
	raceID			SERIAL,
	name			TEXT NOT NULL UNIQUE,
	description		TEXT NOT NULL,
	PRIMARY KEY (raceID)
);

CREATE TABLE "Dark Souls Bosses".damageType(
	tid			SERIAL,
	name			TEXT NOT NULL UNIQUE,
	PRIMARY KEY (tid)
);

CREATE TABLE "Dark Souls Bosses".bosses(
	bid 			SERIAL,
	bossName		TEXT NOT NULL UNIQUE,
	raceID			INTEGER REFERENCES "Dark Souls Bosses".races(raceID),
	lid			INTEGER REFERENCES "Dark Souls Bosses".locations(lid),
	health			INTEGER NOT NULL,
	soulsForDefeat		INTEGER NOT NULL,
	armorSetObtainable	BOOLEAN NOT NULL,
	defeatRequired		BOOLEAN NOT NULL,
	tailCut			BOOLEAN NOT NULL,
	PRIMARY KEY(bid)
);

CREATE TABLE "Dark Souls Bosses".weaknesses(
	bid			INTEGER REFERENCES "Dark Souls Bosses".bosses(bid),
	tid			INTEGER REFERENCES "Dark Souls Bosses".damageType(tid),
	PRIMARY KEY(bid,tid)
);

CREATE TABLE "Dark Souls Bosses".resistances(
	bid			INTEGER REFERENCES "Dark Souls Bosses".bosses(bid),
	tid			INTEGER REFERENCES "Dark Souls Bosses".damageType(tid),
	PRIMARY KEY(bid,tid)
);

CREATE TABLE "Dark Souls Bosses".items(
	itemID			SERIAL,
	name			TEXT NOT NULL UNIQUE,
	notes			TEXT NOT NULL,
	PRIMARY KEY(itemID)
);


CREATE TABLE "Dark Souls Bosses".offensiveItems(
	itemID			INTEGER REFERENCES "Dark Souls Bosses".items(itemID),
	damage			INTEGER NOT NULL,
	durability		INTEGER NOT NULL,
	weight			REAL NOT NULL,
	requiresTailCut		BOOLEAN NOT NULL,
	notes			TEXT NOT NULL,
	PRIMARY KEY(itemID)
);

CREATE TABLE "Dark Souls Bosses".defensiveItems(
	itemID			INTEGER REFERENCES "Dark Souls Bosses".items(itemID),
	physicalDefense		INTEGER NOT NULL,
	elementalDefense	INTEGER NOT NULL,
	poise			INTEGER NOT NULL,
	durability		INTEGER NOT NULL,
	weight			REAL NOT NULL,
	requiresTailCut		BOOLEAN NOT NULL,
	notes			TEXT NOT NULL,
	PRIMARY KEY(itemID)
);

CREATE TABLE "Dark Souls Bosses".bossDrops(
	bid			INTEGER REFERENCES "Dark Souls Bosses".bosses(bid),
	itemID			INTEGER REFERENCES "Dark Souls Bosses".items(itemID),
	PRIMARY KEY (bid,itemID)
);

CREATE VIEW "Dark Souls Bosses".importantBossInformation AS
SELECT 	B.bossName, L.name, B.health, B.soulsForDefeat,
	B.defeatRequired, COALESCE(D1.name,'None') AS weakness,
	COALESCE(D2.name,'None') AS resistant

FROM	"Dark Souls Bosses".bosses as B
LEFT JOIN "Dark Souls Bosses".weaknesses AS W
ON 	B.bid = W.bid
LEFT JOIN "Dark Souls Bosses".resistances AS R	
ON 	B.bid = R.bid
LEFT JOIN "Dark Souls Bosses".damageType AS D1
ON	W.tid = D1.tid
LEFT JOIN "Dark Souls Bosses".damageType AS D2
ON	R.tid = D2.tid
LEFT JOIN "Dark Souls Bosses".locations AS L
ON	B.lid = L.lid
ORDER BY B.bossName ASC;

CREATE VIEW "Dark Souls Bosses".bossItemDropInformation AS
SELECT B.bossName, I.name
FROM "Dark Souls Bosses".bossDrops AS D
LEFT JOIN "Dark Souls Bosses".bosses AS B
ON D.bid = B.BID
LEFT JOIN "Dark Souls Bosses".items as I
on D.itemID = I.itemID;

CREATE VIEW "Dark Souls Bosses".offensiveItemInformation AS
SELECT I.name,I.notes,O.damage,O.durability,O.weight,O.requiresTailCut,O.notes as offensiveNotes
FROM "Dark Souls Bosses".items AS I
JOIN "Dark Souls Bosses".offensiveItems AS O
ON O.itemID = I.itemID;

CREATE VIEW "Dark Souls Bosses".defensiveItemInformation AS
SELECT I.name,I.notes,D.physicalDefense,D.elementalDefense,D.poise,D.durability,D.weight,
D.requiresTailCut,D.notes as defenseiveNotes
FROM "Dark Souls Bosses".items AS I
JOIN "Dark Souls Bosses".defensiveItems AS D
ON D.itemID = I.itemID;


--An item can be added to offensive/defensive/general item table.
--To be added to the Offensive and Defensive table, additional parameters must be passed in
--			       |optional->
--addItem(name:TEXT,notes:TEXT,[offensive:ARRAY[2]or NULL,defensive:ARRAY[4]or NULL,weight:REAL,tailCut:BOOLEAN,additionalNotes:TEXT])
CREATE OR REPLACE FUNCTION addItem (	a_name TEXT, a_notes TEXT DEFAULT '', --required
					off_arr INTEGER[] DEFAULT NULL, --optional
					def_arr INTEGER[] DEFAULT NULL, --optional
					a_weight REAL DEFAULT NULL, --needed if any array is passed in
					a_requiresTailCut BOOLEAN DEFAULT NULL, --needed if any array is passed in
					a_additionalNotes TEXT DEFAULT '')--optional
returns BOOL AS 
$$
DECLARE
	curs REFCURSOR;
	newItemID INTEGER;
BEGIN
	IF off_arr IS NULL THEN
		IF def_arr IS NULL THEN --Meaning regular item
			INSERT INTO "Dark Souls Bosses".items (name,notes)
			VALUES (a_name,a_notes);
			RETURN TRUE;
		ELSE --Meaning defensive item
			IF array_length(def_arr,1) = 4 THEN
				IF a_weight IS NULL OR a_requiresTailCut IS NULL THEN
					RAISE 'weight or tailcut args not given';
					RETURN FALSE;
				ELSE
					INSERT INTO "Dark Souls Bosses".items (name,notes)
					VALUES (a_name,a_notes);

					OPEN curs FOR
						SELECT itemID FROM "Dark Souls Bosses".items
						WHERE name = a_name;
					FETCH curs INTO newItemID;

					INSERT INTO "Dark Souls Bosses".defensiveItems (itemID, physicalDefense,
											elementalDefense, poise,
											durability, weight,
											requiresTailCut,notes)
					VALUES (CAST(newItemID AS INTEGER),def_arr[1],def_arr[2],def_arr[3],def_arr[4],
						a_weight,a_requiresTailCut,a_additionalNotes);
					RETURN TRUE;
				END IF;
			END IF;
		END IF;
	ELSE --Meaning offensive item
		IF array_length(off_arr,1) = 2 THEN
				IF a_weight IS NULL OR a_requiresTailCut IS NULL THEN
					RAISE 'weight or tailcut args not given';
					RETURN FALSE;
				ELSE
					INSERT INTO "Dark Souls Bosses".items (name,notes)
					VALUES (a_name,a_notes);

					OPEN curs FOR
						SELECT itemID FROM "Dark Souls Bosses".items
						WHERE name = a_name;

					FETCH curs INTO newItemID;

					INSERT INTO "Dark Souls Bosses".offensiveItems (itemID, damage,
											durability, weight,
											requiresTailCut, notes)
					VALUES (CAST(newItemID AS INTEGER),off_arr[1],off_arr[2],a_weight,a_requiresTailCut,a_additionalNotes);
					RETURN TRUE;
				END IF;
		END IF;
	END IF;
END;
$$
LANGUAGE PLPGSQL;

CREATE VIEW "Dark Souls Bosses".allItems AS
SELECT I.itemID as I, I.name, I.notes AS inotes, O.itemID as O, O.damage, O.durability AS offensiveDurability, O.weight as offensiveWeight, O.requiresTailCut AS offensiveTailCut, O.notes AS onotes, D.itemID AS D, D.physicalDefense, D.elementalDefense, D.poise, D.durability defenseDurability, D.weight defensiveWeight, D.requiresTailCut AS defensiveTailCut, D.notes as dnotes
FROM "Dark Souls Bosses".items AS I
LEFT JOIN "Dark Souls Bosses".offensiveItems AS O
ON  I.itemID = O.itemID
LEFT JOIN "Dark Souls Bosses".defensiveItems AS D
ON  I.itemID = D.itemID
ORDER BY I.itemID;

CREATE ROLE administrator;
GRANT ALL PRIVILEGES 
ON ALL TABLES
IN SCHEMA "Dark Souls Bosses"
TO administrator;

CREATE ROLE player;
GRANT SELECT
ON ALL TABLES
IN SCHEMA "Dark Souls Bosses"
TO player;

--SELECT addItem('Function Test3','offensive',NULL,'{0,0,7,5}',2.5,FALSE,'ありがとう')


---Insert Statements---

INSERT INTO "Dark Souls Bosses".locations (name)
VALUES ('Anor Londo'),('Blighttown'),('Crystal Cave'),('Darkroot Garden'),('Demon Ruins'),(
	'Depths'),('Kiln of the First Flame'),('Lost Izalith'),('Lower Undead Burg'),(
	'Painted World of Ariamis'),('Royal Wood'),('Sanctuary Garden'),('Sen''s Fortress'),(
	'The Abyss'),('The Catacombs'),('The Duke''s Archives'),('Tomb of the Giants'),(
	'Undead Asylum'),('Undead Burg'),('Undead Parish'),('Chasm of the Abyss');



INSERT INTO "Dark Souls Bosses".races (name, description)
VALUES ('Demon',''),('Gargoyle',''),('Dragon',''),('Great Wolf',''),('Deity',''),('Inorganic',''),('Human',''),('Buttefly',''),('Crossbreed',''),('Unknown','');

INSERT INTO "Dark Souls Bosses".damageType (name)
VALUES ('Magic'),('Fire'),('Lightning'),('Occult'),('Divine'),('Bleed'),('Poison'),('Curse'),('Toxin'),('Physical'),('Slash'),('Blunt');



INSERT INTO "Dark Souls Bosses".bosses
		(bossName, 		raceID, lid, 	health, soulsForDefeat, armorSetObtainable, defeatRequired, tailCut)
values 	('Asylum Demon', 		1, 	18, 	813, 		2000,	FALSE, TRUE, FALSE),
	('The Bed of Chaos', 		11, 	8, 	1, 		60000,	FALSE, TRUE, FALSE),
	('Belfry Gargoyle 1', 		2, 	20, 	1000, 		5000,	TRUE, TRUE, TRUE),
	('Belfry Gargoyle 2', 		2, 	20, 	480, 		5000,	FALSE, TRUE, TRUE),
	('Black Dragon Kalameet', 	3, 	11, 	5400, 		60000,	FALSE, FALSE, TRUE),
	('Capra Demon', 		1, 	9, 	1176, 		6000,	FALSE, FALSE, FALSE),
	('Ceaseless Discharge',		11,	5,	4200,		20000,	FALSE, FALSE, FALSE),
	('Centipede Demon',		1,	5,	3434,		40000,	FALSE, FALSE, TRUE),
	('Chaos Witch Quelaag',		10,	2,	3139,		20000,	FALSE, TRUE, FALSE),
	('Crossbreed Priscilla',	10,	10,	2300,		30000,	FALSE, FALSE, TRUE),
	('Dark Sun Gwyndolin',		6,	1,	2012,		40000,	TRUE, FALSE, FALSE),
	('Demon Firesage',		1,	5,	5448,		20000,	FALSE, FALSE, FALSE),
	('Dragon Slayer Ornstein',	11,	1,	1642,		0,	FALSE, TRUE, FALSE),
	('Super Dragon Slayer Ornstein',11,	1,	2981,		25000,	TRUE, TRUE, FALSE),
	('Executioner Smough',		11,	1,	2646,		0,	FALSE, TRUE, FALSE),
	('Super Executioner Smough',	11,	1,	4094,		25000,	TRUE, TRUE, FALSE),
	('The Four Kings',		11,	14,	9416,		60000,	FALSE, TRUE, FALSE),
	('Gaping Dragon',		3,	6,	4660,		25000,	FALSE, FALSE, TRUE),
	('Gravelord Nito',		6,	17,	4317,		60000,	FALSE, TRUE, FALSE),
	('Gwyn',			6,	7,	4186,		70000,	TRUE, TRUE, FALSE),
	('Iron Golem',			7,	13,	2880,		40000,	TRUE, TRUE, FALSE),
	('Knight Artorias',		11,	11,	3750,		50000,	TRUE, FALSE, FALSE),
	('Manus',			11,	12,	6666,		60000,	FALSE, FALSE, FALSE),
	('Moonlight Butterfly',		9,	4,	1506,		10000,	FALSE, FALSE, FALSE),
	('Pinwheel',			11,	15,	1326,		15000,	FALSE, TRUE, FALSE),
	('Sanctuary Guardian',		10,	12,	2560,		30000,	FALSE, FALSE, TRUE),
	('Seath the Scaleless',		3,	3,	5534,		60000,	FALSE, TRUE, TRUE),
	('Sif',				5,	4,	3432,		40000,	FALSE, TRUE, FALSE),
	('Stray Demon',			1,	18,	5250,		20000,	FALSE, FALSE, FALSE),
	('Taurus Demon',		1,	19,	1215,		3000,	FALSE, FALSE, FALSE);


INSERT INTO "Dark Souls Bosses".items (name, notes)
VALUES	('Demon''s Great Hammer','Dropped if killed the very first time you meet him without using the escape door.'),
	('Big Pilgrim''s Key','Opens the large door in the Asylum Demon''s chamber in the Undead Asylum. Dropped only if killed after talking to Oscar, Knight of Astora'),
	('Humanity','Consumable'),
	('Lord Soul','Story Item'),
	('Twin Humanities','Consumable'),
	('Gargoyle Tail Axe',''),
	('Gargoyle''s Shield',''),
	('Gargoyle Halberd',''),
	('Gargoyle Helm',''),
	('Calamity Ring','Doubles the damage taken by enemies'),
	('Obsidian Greatsword',''),
	('Key to the Depths',''),
	('Homeward Bone',''),
	('Demon Great Machete',''),
	('Orange Charred Ring','Reduces 80% of lava damage'),
	('Soul of Quelaag',''),
	('Soul of Priscilla',''),
	('Priscilla''s Dagger',''),
	('Soul of Gwyndolin',''),
	('Demon''s Catalyst',''),
	('Soul of Ornstein',''),
	('Leo Ring','Boosts counter damage by 40%'),
	('Soul of Smough',''),
	('Bequeathed Lord Soul Shard',''),
	('Blighttown Key',''),
	('Dragon King Greataxe',''),
	('Soul of Gwyn, Lord of Cinder',''),
	('Core of an Iron Golem',''),
	('Soul of Artorias',''),
	('Soul of Manus',''),
	('Soul of the Moonlight Butterfly',''),
	('Mask of the Child','Increase stamina regen by 10 seconds'),
	('Mask of the Mother','Raises maximum HP by 10%'),
	('Mask of the Father','Raises maximum equipment load by 5%'),
	('Rite of Kindling',''),
	('Guardian Soul',''),
	('Guardian Tail',''),
	('Moonlight Greatsword',''),
	('Soul of Sif',''),
	('Covenant of Artorias',''),
	('Titanite Slab',''),
	('Demon''s Greataxe','');
		

INSERT INTO "Dark Souls Bosses".offensiveItems
	(itemID, damage, durability, weight, requiresTailCut, notes)
VALUES	(1, 138, 600, 22, FALSE, 'Dropped if killed the very first time you meet him without using the escape door.'),
	(6, 93, 150, 5, TRUE, ''),
	(7, 60, 300, 4, FALSE, ''),
	(8, 115, 200, 6, FALSE, ''),
	(11, 320, 350, 8, TRUE, ''),
	(14, 133, 600, 18, FALSE, 'Rare'),
	(17, 80, 100, 1, TRUE, ''),
	(20, 110, 300, 4, FALSE, ''),
	(26, 380, 400, 24, TRUE, ''),
	(37, 84, 250, 5, TRUE, ''),
	(38, 132, 300, 6, TRUE, ''),
	(42, 114, 600, 2, FALSE, 'Rare');

INSERT INTO "Dark Souls Bosses".defensiveItems
	(itemID, physicalDefense, elementalDefense, poise, durability, weight, requiresTailCut, notes)
VALUES	(9,15,15,8,500,3.5,FALSE,''),
	(32,6,10,0,200,1.2,FALSE,''),
	(33,6,12,0,200,1.2,FALSE,''),
	(34,6,10,0,200,1.2,FALSE,'');

INSERT INTO "Dark Souls Bosses".weaknesses (bid,tid)
VALUES	(1,2), (1,1), (1,6), (3,2), (3,3), (4,3), (6,2),
	(6,3), (7,1), (7,3), (8,1), (8,6), (9,3), (9,1),
	(10,3), (10,2), (11,2), (11,4), (11,6), (12,2),
	(12,7),	(13,2),	(13,4),	(14,2),	(14,4),	(15,3),
	(17,2),	(17,3),	(17,1),	(17,5),	(18,3),	(19,2),
	(20,2),	(20,1),	(20,4),	(21,3),	(23,3),	(24,3),
	(25,2),	(26,6),	(27,3),	(27,2),	(28,2),	(28,6),
	(29,2),	(29,3),	(29,6),	(30,3),	(30,2), (12,9),
	(28,11);

INSERT INTO "Dark Souls Bosses".resistances (bid,tid)
VALUES	(5,1), (5,2), (7,2), (9,2), (13,3), (14,3),
	(15,2), (16,3), (17,7), (17,6), (17,8),
	(17,9),	(20,3),	(21,10), (22,11), (22,12),
	(22,1),	(22,2),	(23,2),	(23,1),	(26,1),
	(26,3);

INSERT INTO "Dark Souls Bosses".bossDrops (bid,itemID)
VALUES 	(1,1), (1,2), (1,3), (2,4),
	(3,5), (3,6), (3,7), (3,8),
	(3,9), (5,10), (5,11), (6,12),
	(6,3), (6,13), (6,14), (7,3),
	(7,13), (8,15), (9,16), (9,5),
	(10,17), (10,18), (11,19), (12,20),
	(14,21), (14,22), (16,23), (17,24),
	(17,3), (18,25), (18,3), (18,13),
	(18,26), (19,4), (20,27), (21,28),
	(22,29), (22,3), (23,30), (23,3),
	(24,3), (24,31), (25,32), (25,33),
	(25,34), (25,35), (26,36), (26,37),
	(27,24), (27,38), (28,39), (28,40),
	(28,3), (28,13), (29,41), (29,3),
	(29,13), (30,3), (30,13), (30,42);
	
