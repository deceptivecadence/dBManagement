DROP TABLE IF EXISTS engineers;
DROP TABLE IF EXISTS astronauts;
DROP TABLE IF EXISTS flightControlOperators;
DROP TABLE IF EXISTS spacecrafts;
DROP TABLE IF EXISTS crew;
DROP TABLE IF EXISTS systems;
DROP TABLE IF EXISTS parts;
DROP TABLE IF EXISTS suppliers;
DROP TABLE IF EXISTS supplierCatalog;


CREATE TABLE engineers(
	eid			TEXT NOT NULL,
	firstName		TEXT,
	lastName		TEXT,
	degree			TEXT,
	age			NUMERIC(3,0),
	favoriteVideoGame 	TEXT,
	PRIMARY KEY(eid)
);

CREATE TABLE astronauts(
	aid			TEXT NOT NULL,
	firstName		TEXT,
	lastName		TEXT,
	yearsFlying		NUMERIC(2,0),
	age			NUMERIC(3,0),
	golfHandicap	 	NUMERIC(2,0),
	PRIMARY KEY(aid)
);

CREATE TABLE flightControlOperators(
	fcoID			TEXT NOT NULL,
	firstName		TEXT,
	lastName		TEXT,
	chairPreference		TEXT,
	age			NUMERIC(3,0),
	preferredDrink	 	TEXT,
	PRIMARY KEY(fcoID)
);

CREATE TABLE spacecrafts(
	craftID			TEXT NOT NULL,
	name			TEXT,
	tailNumber		TEXT,
	weightTons		NUMERIC(3,0),
	fuelType		TEXT,
	crewCapacity	 	NUMERIC(3,0),
	PRIMARY KEY(craftID)
);


CREATE TABLE crew(
	aid			TEXT REFERENCES astronauts(aid),
	craftID			TEXT REFERENCES spacecrafts(craftID),
	PRIMARY KEY(aid, craftID)
);


CREATE TABLE systems(
	craftID			TEXT REFERENCES astronauts(aid),
	name			TEXT NOT NULL UNIQUE,
	description		TEXT,
	PRIMARY KEY(craftID, name)
);

CREATE TABLE parts(
	craftID			TEXT REFERENCES spacecrafts(craftID),
	systemName		TEXT 	REFERENCES systems(name) UNIQUE,
	name			TEXT UNIQUE,
	description		TEXT,
	qty			INTEGER,
	PRIMARY KEY(craftID, systemName, name)
);


CREATE TABLE suppliers(
	sid			TEXT NOT NULL,
	name			TEXT,
	address			TEXT,
	paymentType		TEXT,
	PRIMARY KEY(sid)
);

CREATE TABLE supplierCatalog(
	sid			TEXT REFERENCES suppliers(sid),
	craftID			TEXT REFERENCES spacecrafts(craftID),
	systemName		TEXT REFERENCES systems(name),
	partName		TEXT REFERENCES parts(name)
);

INSERT INTO astronauts (aid,firstName,lastName,yearsFlying,age,golfHandicap)
VALUES ('1','John','Smith',20,50,5);

INSERT INTO spacecrafts (craftID,name,tailNumber,weightTons,fuelType,crewCapacity)
VALUES ('1','Dat Rover','432',7,'Super',5);

INSERT INTO crew (aid,craftID)
VALUES ('1','1');

INSERT INTO systems (craftID,name,description)
VALUES ('1','SuperSystem','So super, it is super charged!');

INSERT INTO parts (craftID, systemName, name, description, qty)
VALUES ('1','SuperSystem','Flux Capacitor','Allows travel through spacetime','1');

INSERT INTO suppliers (sid,name,address,paymentType)
VALUES ('1','Bob Lynch','207 Boulevard Road, MiddleOfNowhere','Cash');

INSERT INTO supplierCatalog (sid, craftID, systemName, partName)
VALUES ('1','1','SuperSystem','Flux Capacitor');




