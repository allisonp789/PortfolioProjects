/* 


Animal Shelter Project: Data Cleaning


*/


SELECT *
FROM AnimalShelterProject..AnimalIntakes


SELECT *
FROM AnimalShelterProject..AnimalOutcomes


--------------------------------------------------------------------------------------------------------------------------------

-- Date Formatting

-- Standardizing DateTime Columns


SELECT DateTime, CONVERT(datetime, DateTime)
FROM AnimalShelterProject..AnimalIntakes


ALTER TABLE AnimalShelterProject..AnimalIntakes
ADD DateTimeConverted datetime;

UPDATE AnimalShelterProject..AnimalIntakes
SET DateTimeConverted = CONVERT(datetime, DateTime)



SELECT DateTime, CONVERT(datetime, DateTime)
FROM AnimalShelterProject..AnimalOutcomes


ALTER TABLE AnimalShelterProject..AnimalOutcomes
ADD DateTimeConverted datetime;

UPDATE AnimalShelterProject..AnimalOutcomes
SET DateTimeConverted = CONVERT(datetime, DateTime)


-- Standardizing MonthYear Columns


SELECT MonthYear, CAST(MonthYear AS Date)
FROM AnimalShelterProject..AnimalIntakes


ALTER TABLE AnimalShelterProject..AnimalIntakes
ADD MonthYearConverted Date;

UPDATE AnimalShelterProject..AnimalIntakes
SET MonthYearConverted = CAST(MonthYear AS Date)



SELECT MonthYear, CAST(MonthYear AS Date)
FROM AnimalShelterProject..AnimalOutcomes


ALTER TABLE AnimalShelterProject..AnimalOutcomes
ADD MonthYearConverted Date;

UPDATE AnimalShelterProject..AnimalOutcomes
SET MonthYearConverted = CAST(MonthYear AS Date)


-- Standardizing Date of Birth Column


SELECT "Date of Birth", CAST("Date of Birth" AS Date)
FROM AnimalShelterProject..AnimalOutcomes


ALTER TABLE AnimalShelterProject..AnimalOutcomes
ADD DOBConverted Date;

UPDATE AnimalShelterProject..AnimalOutcomes
SET DOBConverted = CAST("Date of Birth" AS Date)


--------------------------------------------------------------------------------------------------------------------------------

-- Animals' Ages

-- Adding Column with Animal's Age in Years Upon Outcome


SELECT MonthYearConverted, DOBConverted, DATEDIFF(year, DOBConverted, MonthYearConverted) AS AgeInYears
FROM AnimalShelterProject..AnimalOutcomes


ALTER TABLE AnimalShelterProject..AnimalOutcomes
ADD AgeInYears numeric;

UPDATE AnimalShelterProject..AnimalOutcomes
SET AgeInYears = DATEDIFF(year, DOBConverted, MonthYearConverted)


-- Using CTE to find Age of Animal Upon Intake


WITH DOBCTE AS
(
SELECT DISTINCT "Animal ID", Name, DOBConverted
FROM AnimalShelterProject..AnimalOutcomes
)

SELECT 
    a."Animal ID"
    , a.Name
    , a.DateTimeConverted
    , a.MonthYearConverted
    , b.DOBConverted
    , DATEDIFF(year, b.DOBConverted, a.MonthYearConverted) AS AgeInYears
    , a."Found Location"
    , a."Intake Type"
    , a."Intake Condition"
    , a."Animal Type"
    , a."Sex upon Intake"
    , a."Age upon Intake"
    , a.Breed
    , a.Color
FROM AnimalShelterProject..AnimalIntakes AS a
LEFT JOIN DOBCTE AS b
    ON a."Animal ID" = b."Animal ID"
    AND a."Name" = b."Name"


-- Creating View and Temp Table to find Age of Animal Upon Intake


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
SELECT 
    a."Animal ID"
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


--------------------------------------------------------------------------------------------------------------------------------

-- Checking Distinct Categories within Text Columns


SELECT DISTINCT "Intake Type"
FROM AnimalShelterProject..AnimalIntakes


SELECT DISTINCT "Intake Condition"
FROM AnimalShelterProject..AnimalIntakes


SELECT DISTINCT "Animal Type"
FROM AnimalShelterProject..AnimalIntakes


SELECT DISTINCT "Sex upon Intake"
FROM AnimalShelterProject..AnimalIntakes


SELECT * 
FROM AnimalShelterProject..AnimalIntakes
WHERE "Sex upon Intake" = 'NULL'

UPDATE AnimalShelterProject..AnimalIntakes
SET "Sex upon Intake" = 'Unknown'
WHERE "Sex upon Intake" = 'NULL'


SELECT DISTINCT "Outcome Type"
FROM AnimalShelterProject..AnimalOutcomes


SELECT DISTINCT "Outcome Subtype"
FROM AnimalShelterProject..AnimalOutcomes


SELECT DISTINCT "Animal Type"
FROM AnimalShelterProject..AnimalOutcomes


SELECT DISTINCT "Sex upon Outcome"
FROM AnimalShelterProject..AnimalOutcomes

UPDATE AnimalShelterProject..AnimalOutcomes
SET "Sex Upon Outcome" = 'Unknown'
WHERE "Sex upon Outcome" = 'NULL'


--------------------------------------------------------------------------------------------------------------------------------

-- Trimming Text Columns


ALTER TABLE AnimalShelterProject..AnimalIntakes
ADD IntakeTypeTrimmed NVARCHAR(255);

UPDATE AnimalShelterProject..AnimalIntakes
SET IntakeTypeTrimmed = TRIM(REPLACE("Intake Type", '  ', ' '))



ALTER TABLE AnimalShelterProject..AnimalIntakes
ADD IntakeConditionTrimmed NVARCHAR(255);

UPDATE AnimalShelterProject..AnimalIntakes
SET IntakeConditionTrimmed = TRIM(REPLACE("Intake Condition", '  ', ' '))



ALTER TABLE AnimalShelterProject..AnimalIntakes
ADD AnimalTypeTrimmed NVARCHAR(255);

UPDATE AnimalShelterProject..AnimalIntakes
SET AnimalTypeTrimmed = TRIM(REPLACE("Animal Type", '  ', ' '))



ALTER TABLE AnimalShelterProject..AnimalIntakes
ADD SexUponIntakeTrimmed NVARCHAR(255);

UPDATE AnimalShelterProject..AnimalIntakes
SET SexUponIntakeTrimmed = TRIM(REPLACE("Sex upon Intake", '  ', ' '))



ALTER TABLE AnimalShelterProject..AnimalIntakes
ADD SexUponIntakeTrimmed NVARCHAR(255);

UPDATE AnimalShelterProject..AnimalIntakes
SET SexUponIntakeTrimmed = TRIM(REPLACE("Sex upon Intake", '  ', ' '))



ALTER TABLE AnimalShelterProject..AnimalOutcomes
ADD OutcomeTypeTrimmed NVARCHAR(255);

UPDATE AnimalShelterProject..AnimalOutcomes
SET OutcomeTypeTrimmed = TRIM(REPLACE("Outcome Type", '  ', ' '))



ALTER TABLE AnimalShelterProject..AnimalOutcomes
ADD OutcomeSubtypeTrimmed NVARCHAR(255);

UPDATE AnimalShelterProject..AnimalOutcomes
SET OutcomeSubtypeTrimmed = TRIM(REPLACE("Outcome Subtype", '  ', ' '))



ALTER TABLE AnimalShelterProject..AnimalOutcomes
ADD AnimalTypeTrimmed NVARCHAR(255);

UPDATE AnimalShelterProject..AnimalOutcomes
SET AnimalTypeTrimmed = TRIM(REPLACE("Animal Type", '  ', ' '))



ALTER TABLE AnimalShelterProject..AnimalOutcomes
ADD SexUponOutcomeTrimmed NVARCHAR(255);

UPDATE AnimalShelterProject..AnimalOutcomes
SET SexUponOutcomeTrimmed = TRIM(REPLACE("Sex upon Outcome", '  ', ' '))


--------------------------------------------------------------------------------------------------------------------------------

-- Removing Duplicate Rows


SELECT "Animal ID", "Name", "DateTime", "Found Location", COUNT(*)
FROM AnimalShelterProject..AnimalIntakes
GROUP BY "Animal ID", "Name", "DateTime", "Found Location"
HAVING COUNT(*) > 1
ORDER BY "Animal ID";


WITH RowDuplicatesCTE AS
(SELECT *
    , ROW_NUMBER() OVER (
        PARTITION BY 
	    "Animal ID"
	    , "Name"
	    , "DateTime"
	    , "Found Location" 
		ORDER BY "Animal ID") AS row_num
FROM AnimalShelterProject..AnimalIntakes)

DELETE FROM RowDuplicatesCTE
WHERE row_num > 1;



SELECT "Animal ID", "Name", "DateTime", "Date of Birth", "Outcome Type", "Outcome Subtype", COUNT(*)
FROM AnimalShelterProject..AnimalOutcomes
GROUP BY "Animal ID", "Name", "DateTime", "Date of Birth", "Outcome Type", "Outcome Subtype"
HAVING COUNT(*) > 1
ORDER BY "Animal ID";


WITH OutcomesRowDuplicatesCTE AS (
SELECT *
    , ROW_NUMBER() OVER (
        PARTITION BY 
	    "Animal ID"
            , "Name"
	    , "DateTime"
	    , "Date of Birth"
	    , "Outcome Type"
	    , "Outcome Subtype"
		ORDER BY "Animal ID"
		) AS row_num
FROM AnimalShelterProject..AnimalOutcomes
)

DELETE FROM OutcomesRowDuplicatesCTE
WHERE row_num > 1
