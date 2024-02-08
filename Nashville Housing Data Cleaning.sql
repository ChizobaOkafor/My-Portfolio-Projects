--CLEANING NASHVILLE HOUSING DATA WITH SQL

/* Skills used in this project: String Functions, Data Type Conversion, Null constraints,etc.
First, have a look at your table:*/

SELECT *
FROM dbo.NashvilleHousing;

--Standardize your date format
SELECT SaleDate, CAST(SaleDate AS date)
FROM dbo.NashvilleHousing

--You could also use CONVERT
SELECT SaleDateConverted, CONVERT(date,SaleDate)
FROM dbo.NashvilleHousing

--Update the table

ALTER TABLE dbo.NashvilleHousing
ADD SaleDateConverted date


UPDATE dbo.NashvilleHousing
SET SaleDateConverted = CAST(SaleDate AS date);

--Populate property address data
SELECT COUNT(*)
FROM dbo.NashvilleHousing
WHERE PropertyAddress IS NULL;

SELECT *
FROM dbo.NashvilleHousing
ORDER BY ParcelID;

SELECT 
	nh1.ParcelID, 
	nh1.PropertyAddress, 
	nh2.ParcelID, 
	nh2.PropertyAddress,
	ISNULL(nh1.PropertyAddress,nh2.PropertyAddress)
FROM dbo.NashvilleHousing AS nh1
  JOIN dbo.NashvilleHousing AS nh2
    ON nh1.ParcelID = nh2.ParcelID
	  AND nh1.UniqueID <> nh2.UniqueID
WHERE nh1.PropertyAddress IS NULL;

UPDATE nh1
SET PropertyAddress = ISNULL(nh1.PropertyAddress,nh2.PropertyAddress)
FROM dbo.NashvilleHousing AS nh1
  JOIN dbo.NashvilleHousing AS nh2
    ON nh1.ParcelID = nh2.ParcelID
	  AND nh1.UniqueID <> nh2.UniqueID
WHERE nh1.PropertyAddress IS NULL;

SELECT PropertyAddress
FROM dbo.NashvilleHousing
--ORDER BY ParcelID;

SELECT
	SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)) AS Address,
	CHARINDEX(',', PropertyAddress)
FROM dbo.NashvilleHousing;

SELECT
	SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress) -1) AS Address,
	SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM dbo.NashvilleHousing;

ALTER TABLE dbo.NashvilleHousing
ADD PropertySplitAddress nvarchar(255)
UPDATE dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress) -1) 

ALTER TABLE dbo.NashvilleHousing
ADD PropertySplitCity nvarchar(255)
UPDATE dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT 
	PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)
UPDATE dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE dbo.NashvilleHousing
ADD OwnerSplitCity nvarchar(255)
UPDATE dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE dbo.NashvilleHousing
ADD OwnerSplitState nvarchar(255)
UPDATE dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--Correcting the Case in the sentences
CREATE FUNCTION [dbo].[InitCap] ( @InputString varchar(4000) ) 
RETURNS VARCHAR(4000)
AS
BEGIN

DECLARE @Index          INT
DECLARE @Char           CHAR(1)
DECLARE @PrevChar       CHAR(1)
DECLARE @OutputString   VARCHAR(255)

SET @OutputString = LOWER(@InputString)
SET @Index = 1

WHILE @Index <= LEN(@InputString)
BEGIN
    SET @Char     = SUBSTRING(@InputString, @Index, 1)
    SET @PrevChar = CASE WHEN @Index = 1 THEN ' '
                         ELSE SUBSTRING(@InputString, @Index - 1, 1)
                    END

    IF @PrevChar IN (' ', ';', ':', '!', '?', ',', '.', '_', '-', '/', '&', '''', '(')
    BEGIN
        IF @PrevChar != '''' OR UPPER(@Char) != 'S'
            SET @OutputString = STUFF(@OutputString, @Index, 1, UPPER(@Char))
    END

    SET @Index = @Index + 1
END

RETURN @OutputString

END
GO

UPDATE dbo.NashvilleHousing
SET LandUse = dbo.InitCap(LandUse)

UPDATE dbo.NashvilleHousing
SET OwnerName = dbo.InitCap(OwnerName)

UPDATE dbo.NashvilleHousing
SET PropertySplitAddress = dbo.InitCap(PropertySplitAddress)

UPDATE dbo.NashvilleHousing
SET PropertySplitCity = dbo.InitCap(PropertySplitCity)

UPDATE dbo.NashvilleHousing
SET OwnerSplitCity = dbo.InitCap(OwnerSplitCity)

UPDATE dbo.NashvilleHousing
SET OwnerSplitAddress = dbo.InitCap(OwnerSplitAddress)


--Change 'Y' and 'N' to 'Yes' and 'No' in 'SoldAsVacant' field
SELECT 
	DISTINCT SoldAsVacant, 
	COUNT(*) AS count
FROM dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY count;

SELECT 
	SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant END
FROM dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant END

--Removing Duplicates
WITH RowNumCTE AS (
SELECT
	*,
	ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
                      ORDER BY UniqueID) AS row_num
FROM dbo.NashvilleHousing)

DELETE 
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress;

SELECT *
FROM NashvilleHousing;

--Delete Unused Columns
ALTER TABLE dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict,PropertyAddress

ALTER TABLE dbo.NashvilleHousing
DROP COLUMN SaleDate

