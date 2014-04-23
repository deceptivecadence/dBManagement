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
CREATE OR REPLACE FUNCTION addItem (	a_name TEXT,
					a_notes TEXT DEFAULT '',
					off_arr INTEGER[] DEFAULT NULL, --optional
					def_arr INTEGER[] DEFAULT NULL, --optional
					a_weight REAL DEFAULT NULL, --needed if any array is passed in
					a_requiresTailCut BOOLEAN DEFAULT NULL, --needed if any array is passed in
					a_additionalNotes TEXT DEFAULT '') returns BOOL AS --optional
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

					INSERT INTO "Dark Souls Bosses".defensiveItems (itemID,
											physicalDefense,
											elementalDefense,
											poise,
											durability,
											weight,
											requiresTailCut,
											notes)
					VALUES (CAST(newItemID AS INTEGER),def_arr[1],def_arr[2],def_arr[3],def_arr[4],a_weight,a_requiresTailCut,a_additionalNotes);
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

					INSERT INTO "Dark Souls Bosses".offensiveItems (itemID,
											damage,
											durability,
											weight,
											requiresTailCut,
											notes)
					VALUES (CAST(newItemID AS INTEGER),off_arr[1],off_arr[2],a_weight,a_requiresTailCut,a_additionalNotes);
					RETURN TRUE;
				END IF;
		END IF;
	END IF;
END;
$$
LANGUAGE PLPGSQL;

SELECT addItem('Function Test3','offensive',NULL,'{0,0,7,5}',2.5,FALSE,'ありがとう')

select * from "Dark Souls Bosses".defensiveitems










		


