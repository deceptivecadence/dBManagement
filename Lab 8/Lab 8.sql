DROP TABLE IF EXISTS moviesToActors;
DROP TABLE IF EXISTS moviesToDirectors;
DROP TABLE IF EXISTS actors;
DROP TABLE IF EXISTS movies;
DROP TABLE IF EXISTS directors;

CREATE TABLE actors(
	aId			TEXT NOT NULL,
	name			TEXT NOT NULL,
	address			TEXT,
	birthDate		DATE,
	hairColor		TEXT,
	eyeColor		TEXT,
	heightIn		FLOAT,
	weightLbs		FLOAT,
	sagAnniversaryDate	DATE,
	PRIMARY KEY(aId)
);

CREATE TABLE movies(
	mId			TEXT NOT NULL,
	name			TEXT NOT NULL,
	yearReleased		DATE,
	boxOfficeSalesDomUSD	NUMERIC(10,2),
	boxOfficeSalesForUSD	NUMERIC(10,2),
	homeVideoSalesUSD	NUMERIC(10,2),
	PRIMARY KEY(mId)
);

CREATE TABLE directors(
	dId			TEXT NOT NULL,
	name			TEXT NOT NULL,
	address			TEXT,
	filmSchool		TEXT,
	dgAnniversaryDate	DATE,
	PRIMARY KEY(dId)
);

CREATE TABLE moviesToActors(
	mId			TEXT NOT NULL REFERENCES movies(mId),
	aId			TEXT NOT NULL REFERENCES actors(aId)
);


CREATE TABLE moviesToDirectors(
	mId			TEXT NOT NULL REFERENCES movies(mId),
	dId			TEXT NOT NULL REFERENCES directors(dId)
);



--Directors--
INSERT INTO directors (dId,name,address,filmSchool,dgAnniversaryDate)
VALUES ('d001','Terence Young','dummy','data',current_date);

INSERT INTO directors (dId,name,address,filmSchool,dgAnniversaryDate)
VALUES ('d002','John McTiernan','dummy','data',current_date);

INSERT INTO directors (dId,name,address,filmSchool,dgAnniversaryDate)
VALUES ('d003','Steven Spielberg','dummy','data',current_date);

INSERT INTO directors (dId,name,address,filmSchool,dgAnniversaryDate)
VALUES ('d004','Guy Hamilton','dummy','data',current_date);

INSERT INTO directors (dId,name,address,filmSchool,dgAnniversaryDate)
VALUES ('d005','Chris Buck','dummy','data',current_date);

INSERT INTO directors (dId,name,address,filmSchool,dgAnniversaryDate)
VALUES ('d006','Jennifer Lee','dummy','data',current_date);


--Movies--
INSERT INTO movies (mId,name,yearReleased,boxOfficeSalesDomUSD,boxOfficeSalesForUSD,homeVideoSalesUSD)
VALUES ('m001','Dr. No',current_date,13333.37,21.12,4107.00);

INSERT INTO movies (mId,name,yearReleased,boxOfficeSalesDomUSD,boxOfficeSalesForUSD,homeVideoSalesUSD)
VALUES ('m002','The Hunt for Red October',current_date,13333.37,21.12,4107.00);

INSERT INTO movies (mId,name,yearReleased,boxOfficeSalesDomUSD,boxOfficeSalesForUSD,homeVideoSalesUSD)
VALUES ('m003','Indiana Jones and the Last Crusade',current_date,13333.37,21.12,4107.00);

INSERT INTO movies (mId,name,yearReleased,boxOfficeSalesDomUSD,boxOfficeSalesForUSD,homeVideoSalesUSD)
VALUES ('m004','Goldfinger',current_date,13333.37,21.12,4107.00);

INSERT INTO movies (mId,name,yearReleased,boxOfficeSalesDomUSD,boxOfficeSalesForUSD,homeVideoSalesUSD)
VALUES ('m005','Frozen',current_date,13333.37,21.12,4107.00);

--Actors--
INSERT INTO actors (aId,name,address,birthDate,hairColor,eyeColor,heightIn,weightLbs,sagAnniversaryDate)
VALUES ('a001','Sean Connery','Edinburgh, Scotland, UK','1930-8-25','white','brown',72,180,'1980-6-14');

INSERT INTO actors (aId,name,address,birthDate,hairColor,eyeColor,heightIn,weightLbs,sagAnniversaryDate)
VALUES ('a002','Will Smith','Edinburgh, NotScotland, NotUK','1968-4-28','white','brown',72,180,'1980-6-14');

INSERT INTO actors (aId,name,address,birthDate,hairColor,eyeColor,heightIn,weightLbs,sagAnniversaryDate)
VALUES ('a003','Hobbits','Isengard','2001-01-01','brown','brown',36,100,'2002-6-11');

INSERT INTO actors (aId,name,address,birthDate,hairColor,eyeColor,heightIn,weightLbs,sagAnniversaryDate)
VALUES ('a004','Alan','IfKnownMustPerish','2012-07-07','brown','bluebrown',36,100,'2002-6-11');

INSERT INTO actors (aId,name,address,birthDate,hairColor,eyeColor,heightIn,weightLbs,sagAnniversaryDate)
VALUES ('a005','Idina Menzel','Arendelle','1990-12-07','brown','bluebrown',36,100,'2002-6-11');

--Movies to Actors--
INSERT INTO moviesToActors(mId,aId)
VALUES ('m001','a001');

INSERT INTO moviesToActors(mId,aId)
VALUES ('m002','a001');

INSERT INTO moviesToActors(mId,aId)
VALUES ('m003','a001');

INSERT INTO moviesToActors(mId,aId)
VALUES ('m004','a001');

INSERT INTO moviesToActors(mId,aId)
VALUES ('m005','a005');

--Movies to Directors--
INSERT INTO moviesToDirectors(mId,dId)
VALUES ('m001','d001');

INSERT INTO moviesToDirectors(mId,dId)
VALUES ('m002','d002');

INSERT INTO moviesToDirectors(mId,dId)
VALUES ('m003','d003');

INSERT INTO moviesToDirectors(mId,dId)
VALUES ('m004','d004');

INSERT INTO moviesToDirectors(mId,dId)
VALUES ('m005','d005');

INSERT INTO moviesToDirectors(mId,dId)
VALUES ('m005','d006');




