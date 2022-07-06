/* 


Animal Shelter Project: Data Analysis


*/


--------------------------------------------------------------------------------------------------------------

-- Some animals entered shelter multiple times. Create table with distinct Animal IDs 


DROP TABLE IF EXISTS NoRepeatedIds
CREATE TABLE NoRepeatedIds 
(
AnimalId nvarchar(255)
, Name nvarchar(255)
, AnimalType nvarchar(255)
, SexUponIntake nvarchar(255)
, row_num numeric
);

WITH RowNumCTE AS 
(
SELECT "Animal ID"
    , Name
	, "Animal Type"
	, "Sex upon Intake"
	, ROW_NUMBER() OVER(PARTITION BY "Animal ID" ORDER BY "DateTimeConverted") AS row_num
FROM AnimalShelterProject..AnimalIntakes
)

INSERT INTO NoRepeatedIds
SELECT *
FROM RowNumCTE
WHERE row_num = 1


--------------------------------------------------------------------------------------------------------------

-- Finding Number of Animals that Entered Shelter Per Animal Type


SELECT DISTINCT AnimalType
    , COUNT(*) AS NumOfAnimals
	, ROUND(CONVERT(FLOAT, COUNT(*))/CONVERT(FLOAT
	    , (SELECT COUNT(*) FROM NoRepeatedIds)) * 100, 2) AS Percentage
FROM NoRepeatedIds
GROUP BY AnimalType
ORDER BY NumOfAnimals DESC


--------------------------------------------------------------------------------------------------------------


-- Finding Number of Males Vs. Females that Entered Shelter


WITH AnimalsPerSexCTE AS (
SELECT *
    , CASE WHEN SexUponIntake = 'Intact Male' THEN 'Male'
    WHEN SexUponIntake = 'Neutered Male' THEN 'Male'
	WHEN SexUponIntake = 'Intact Female' THEN 'Female'
	WHEN SexUponIntake = 'Spayed Female' THEN 'Female'
	ELSE 'Unknown'
	END AS Sex
FROM NoRepeatedIds
)

SELECT DISTINCT Sex
    , COUNT (*) AS NumOfAnimals
	, ROUND (CONVERT(FLOAT, COUNT(*)) / CONVERT(FLOAT
	    , (SELECT COUNT(*) FROM NoRepeatedIds)) * 100, 2) AS Percentage
FROM AnimalsPerSexCTE
GROUP BY Sex
ORDER BY NumOfAnimals DESC


-- Comparing Percentage of Animals Neutered/Spayed vs. Intact, Upon Intake and Upon Outcome

DROP TABLE IF EXISTS SpayNeuterIntake
CREATE TABLE SpayNeuterIntake
(
SexDetails nvarchar(255)
, NumUponIntake INT
, PercentageUponIntake FLOAT
);

WITH SpayNeuterIntakeCTE AS 
(
SELECT *
    , CASE WHEN "Sex Upon Intake" = 'Intact Male' THEN 'Intact'
    WHEN "Sex Upon Intake" = 'Neutered Male' THEN 'Neutered/Spayed'
	WHEN "Sex Upon Intake" = 'Intact Female' THEN 'Intact'
	WHEN "Sex Upon Intake" = 'Spayed Female' THEN 'Neutered/Spayed'
	ELSE 'Unknown'
	END AS SexDetails
FROM AnimalShelterProject..AnimalIntakes
)

INSERT INTO SpayNeuterIntake
SELECT DISTINCT SexDetails
    , COUNT (*) AS NumUponIntake
	, ROUND (CONVERT(FLOAT, COUNT(*)) / CONVERT(FLOAT
	    , (SELECT COUNT(*) FROM AnimalShelterProject..AnimalIntakes)) * 100, 2) AS PercentageUponIntake
FROM SpayNeuterIntakeCTE
GROUP BY SexDetails



DROP TABLE IF EXISTS SpayNeuterOutcomes
CREATE TABLE SpayNeuterOutcomes
(
SexDetails nvarchar(255)
, NumUponOutcome INT
, PercentageUponOutcome FLOAT
);

WITH SpayNeuterOutcomesCTE AS (
SELECT *
    , CASE WHEN "Sex upon Outcome" = 'Intact Male' THEN 'Intact'
    WHEN "Sex upon Outcome" = 'Neutered Male' THEN 'Neutered/Spayed'
	WHEN "Sex upon Outcome" = 'Intact Female' THEN 'Intact'
	WHEN "Sex upon Outcome" = 'Spayed Female' THEN 'Neutered/Spayed'
	ELSE 'Unknown'
	END AS SexDetails
FROM AnimalShelterProject..AnimalOutcomes
)

INSERT INTO SpayNeuterOutcomes
SELECT DISTINCT SexDetails
    , COUNT (*) AS NumUponOutcome
	, ROUND (CONVERT(FLOAT, COUNT(*)) / CONVERT(FLOAT
	    , (SELECT COUNT(*) FROM AnimalShelterProject..AnimalOutcomes)) * 100, 2) AS PercentageUponOutcome
FROM SpayNeuterOutcomesCTE
GROUP BY SexDetails



SELECT a.SexDetails, a.NumUponIntake, a.PercentageUponIntake, b.NumUponOutcome, b.PercentageUponOutcome
FROM SpayNeuterIntake AS a
JOIN SpayNeuterOutcomes AS b
ON a.SexDetails = b.SexDetails


--------------------------------------------------------------------------------------------------------------

-- Finding Average Age Upon Intake and Upon Outcome


USE AnimalShelterProject
GO

CREATE VIEW AnimalDateOfBirth AS
SELECT DISTINCT("Animal ID"), Name, DOBConverted
FROM AnimalShelterProject..AnimalOutcomes;


DROP TABLE IF EXISTS AnimalIntakesAge
CREATE TABLE AnimalIntakesAge
(
AnimalId nvarchar(255)
, Name nvarchar(255)
, DateTimeConverted datetime
, MonthYearConverted date
, DOBConverted date
, AgeInYears numeric
, FoundLocation nvarchar(255)
, IntakeType nvarchar(255)
, IntakeCondition nvarchar(255)
, AnimalType nvarchar(255)
, SexUponIntake nvarchar(255)
, AgeUponIntake nvarchar(255)
, Breed nvarchar(255)
, Color nvarchar(255)
);

INSERT INTO AnimalIntakesAge
SELECT a."Animal ID"
    , a.Name
	, a.DateTimeConverted
	, a.MonthYearConverted
	, b.DOBConverted
	, DATEDIFF(year, b.DOBConverted, a.MonthYearConverted) 
	, a."Found Location"
	, a."Intake Type"
	, a."Intake Condition"
	, a."Animal Type"
	, a."Sex upon Intake"
	, a."Age upon Intake"
	, a.Breed
	, a.Color
FROM AnimalShelterProject..AnimalIntakes AS a
LEFT JOIN AnimalShelterProject..AnimalDateOfBirth AS b
ON a."Animal ID" = b."Animal ID"
AND a.Name = b.Name


SELECT ROUND(AVG(AgeInYears), 2) AS AvgAgeUponIntake
FROM AnimalIntakesAge



SELECT ROUND(AVG(AgeInYears), 2) AS AvgAgeUponOutcome
FROM AnimalShelterProject..AnimalOutcomes


--------------------------------------------------------------------------------------------------------------

-- Finding Number of Animals Per Outcome Type


SELECT "Outcome Type"
    , COUNT(*) AS Num
	, CONVERT(FLOAT, COUNT(*)) / CONVERT(FLOAT 
    , (SELECT COUNT(*) 
	   FROM AnimalShelterProject..AnimalOutcomes)) * 100 AS Percentage
FROM AnimalShelterProject..AnimalOutcomes
GROUP BY "Outcome Type"
ORDER BY Num DESC


--------------------------------------------------------------------------------------------------------------

-- Finding Number of Animals that Entered Shelter More than Once


WITH RowNumCTE AS (
SELECT *
	, ROW_NUMBER() OVER (
	PARTITION BY "Animal ID"
				 , "Name"
					ORDER BY "DateTimeConverted") AS row_num
FROM AnimalShelterProject..AnimalIntakes
)

SELECT DISTINCT "Animal ID", MAX(row_num) AS NumTimesAtShelter
FROM RowNumCTE
WHERE row_num > 1
GROUP BY "Animal ID"
ORDER BY NumTimesAtShelter DESC


--Finding Average Number of Times Animal Enters Shelter


WITH RowNumCTE2 AS
(
SELECT DISTINCT "Animal ID", COUNT(*) AS num
FROM AnimalShelterProject..AnimalIntakes
GROUP BY "Animal ID"
)

SELECT ROUND(AVG(CONVERT(FLOAT, num)), 2) AS AvgTimesAtShelter
FROM RowNumCTE2


--------------------------------------------------------------------------------------------------------------


-- Number of Animal Intakes

-- Finding Month with Highest Number of Animal Intakes


WITH IntakeMonthCTE AS 
(
SELECT *, MONTH(DateTimeConverted) AS MonthNum, FORMAT(DateTimeConverted, 'MMMM') AS MonthName
FROM AnimalShelterProject..AnimalIntakes
)

SELECT DISTINCT(MonthName), COUNT("Animal ID") AS NumOfIntakes
FROM IntakeMonthCTE
GROUP BY MonthName
ORDER BY NumOfIntakes DESC


-- Finding Number of Animal Intakes per Year


WITH IntakeYearCTE AS (
SELECT *, YEAR(DateTimeConverted) AS Year
FROM AnimalShelterProject..AnimalIntakes
)

SELECT DISTINCT(Year), COUNT("Animal ID") AS NumIntakes
FROM IntakeYearCTE
GROUP BY Year


--------------------------------------------------------------------------------------------------------------

-- Animal Adoptions

-- Finding Number of Animal Adoptions Per Year


DROP TABLE IF EXISTS AdoptionsPerYear
CREATE TABLE AdoptionsPerYear
(Year INT
, NumAdoptions INT);

WITH AdoptionCTE AS
(
SELECT *, YEAR(DateTime) AS Year
FROM AnimalShelterProject..AnimalOutcomes
WHERE "Outcome Type" = 'Adoption'
)

INSERT INTO AdoptionsPerYear
SELECT DISTINCT Year, COUNT(*) AS NumAdoptions
FROM AdoptionCTE
GROUP BY Year
ORDER BY Year


-- Finding Adoption Rate per Year


USE AnimalShelterProject
GO

CREATE VIEW AnimalsPerYear AS

WITH IntakeYearCTE AS 
(
SELECT *, YEAR(DateTimeConverted) AS Year
FROM AnimalShelterProject..AnimalIntakes
)

SELECT DISTINCT(Year), COUNT("Animal ID") AS NumIntakes
FROM IntakeYearCTE
GROUP BY Year


SELECT a.Year
    , b.NumIntakes
	, a.NumAdoptions
	, CONVERT(FLOAT, a.NumAdoptions) / CONVERT(FLOAT, b.NumIntakes) * 100 AS AdoptionRate
FROM AdoptionsPerYear AS a
JOIN AnimalsPerYear AS b
ON a.Year = b.Year
ORDER BY Year


-- Finding percentage of animals adopted per animal type


DROP TABLE IF EXISTS NumAnimalsType
CREATE TABLE NumAnimalsType
(AnimalType nvarchar(255)
, NumOfAnimals float);

INSERT INTO NumAnimalsType
SELECT DISTINCT "Animal Type", COUNT(*) AS NumOfAnimals
FROM AnimalShelterProject..AnimalOutcomes
GROUP BY "Animal Type"


DROP TABLE IF EXISTS AnimalsAdoptedPerType
CREATE TABLE AnimalsAdoptedPerType
(AnimalType nvarchar(255)
, NumAdopted float);

INSERT INTO AnimalsAdoptedPerType
SELECT DISTINCT "Animal Type", COUNT(*) AS NumAdopted
FROM AnimalShelterProject..AnimalOutcomes
WHERE "Outcome Type" = 'Adoption'
GROUP BY "Animal Type"


SELECT a.AnimalType, a.NumAdopted, b. NumOfAnimals, ROUND(a.NumAdopted/b.NumOfAnimals * 100, 2) AS PercentageAdopted
FROM AnimalsAdoptedPerType AS a
JOIN NumAnimalsType AS b
    ON a.AnimalType = b.AnimalType
ORDER BY PercentageAdopted DESC


-- Finding Average Age of Adopted Animals


SELECT ROUND(AVG(AgeInYears), 2) AS AvgAdoptedAge
FROM AnimalShelterProject..AnimalOutcomes
WHERE "Outcome Type" = 'Adoption'


-- Finding Number of Animals Adopted Per Age Group


DROP TABLE IF EXISTS AnimalsAdoptedPerAgeGroup
CREATE TABLE AnimalsAdoptedPerAgeGroup
(AgeRange nvarchar(255)
, NumAdopted INT);

WITH AgeRangeCTE AS
(
SELECT *
    , CASE WHEN AgeInYears <= 3 THEN '0-3 Years'
	WHEN AgeInYears <= 6 THEN '4-6 Years'
	WHEN AgeInYears <= 10 THEN '7-10 Years'
	WHEN AgeInYears <= 15 THEN '11-15 Years'
	ELSE '16+ Years' 
	END AS AgeRange
FROM AnimalShelterProject..AnimalOutcomes
WHERE "Outcome Type" = 'Adoption'
)

INSERT INTO AnimalsAdoptedPerAgeGroup
SELECT DISTINCT AgeRange, COUNT(*) AS NumAdopted
FROM AgeRangeCTE
GROUP BY AgeRange


-- Finding Percentage of Animals Adopted Per Age Group


DROP TABLE IF EXISTS AnimalsPerAgeGroup
CREATE TABLE AnimalsPerAgeGroup
(AgeRange nvarchar(255)
, NumOfAnimals INT);

WITH AgeRangeCTE AS
(
SELECT *
    , CASE WHEN AgeInYears <= 3 THEN '0-3 Years'
	WHEN AgeInYears <= 6 THEN '4-6 Years'
	WHEN AgeInYears <= 10 THEN '7-10 Years'
	WHEN AgeInYears <= 15 THEN '11-15 Years'
	ELSE '16+ Years' 
	END AS AgeRange
FROM AnimalShelterProject..AnimalOutcomes
)

INSERT INTO AnimalsPerAgeGroup
SELECT DISTINCT AgeRange, COUNT(*) AS NumOfAnimals
FROM AgeRangeCTE
GROUP BY AgeRange


SELECT a.AgeRange
    , a.NumAdopted
	, b.NumOfAnimals
	, CONVERT(FLOAT, NumAdopted) / CONVERT(FLOAT, NumOfAnimals) * 100 AS PercentageAdopted 
FROM AnimalsAdoptedPerAgeGroup AS a
JOIN AnimalsPerAgeGroup AS b
ON a.AgeRange = b.AgeRange
ORDER BY NumAdopted DESC


