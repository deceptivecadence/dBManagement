SELECT directors.name
FROM moviesToActors
JOIN moviesToDirectors
ON moviesToActors.mId = moviesToDirectors.mId
JOIN directors
ON moviesToDirectors.dId = directors.dId
WHERE aId IN (SELECT aId FROM actors WHERE name = 'Sean Connery')

--OR--

SELECT name
FROM directors
WHERE dId IN (
		SELECT dId
		FROM moviesToDirectors
		WHERE mId IN (
				SELECT mId
				FROM moviesToActors
				WHERE aId IN (
						SELECT aId
						FROM actors
						WHERE name = 'Sean Connery')))