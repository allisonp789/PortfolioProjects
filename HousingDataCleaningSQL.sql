/* 

Data Cleaning Project with SQL

*/


SELECT *
FROM PortfolioProject..NashvilleHousing


---------------------------------------------------------------------------------------------------------------------------------

-- Standardizing Date Format


SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date; 

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


---------------------------------------------------------------------------------------------------------------------------------

-- Populating Property Address Data


SELECT *
FROM PortfolioProject..NashvilleHousing
WHERE PropertyAddress IS NULL


SELECT *
FROM PortfolioProject..NashvilleHousing
ORDER BY ParcelID


SELECT a.ParcelID
    , a.PropertyAddress
	, b.ParcelID
	, b.PropertyAddress
	, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing AS a
JOIN PortfolioProject..NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing AS a
JOIN PortfolioProject..NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


---------------------------------------------------------------------------------------------------------------------------------

-- Breaking Out Address into Individual Columns (Address, City, State)

-- Breaking out Property Address


SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing


SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address
    , SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)


ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


-- Breaking out Owner Address 


SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing


SELECT 
	PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3)
	, PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2)
	, PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)
FROM PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3)


ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2)


ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),1)


---------------------------------------------------------------------------------------------------------------------------------

-- Changing Y and N to Yes and No in "Sold as Vacant" field


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject..NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END
FROM PortfolioProject..NashvilleHousing


---------------------------------------------------------------------------------------------------------------------------------

-- Removing Duplicates


WITH RowNumCTE AS 
(
SELECT *
	, ROW_NUMBER() OVER (
	PARTITION BY ParcelID
				 , PropertyAddress
				 , SalePrice
				 , SaleDate
				 , LegalReference
				 ORDER BY 
					UniqueID
					) AS row_num
FROM PortfolioProject..NashvilleHousing
)


SELECT *
FROM RowNumCTE
WHERE row_num > 1


DELETE
FROM RowNumCTE
WHERE row_num > 1


---------------------------------------------------------------------------------------------------------------------------------

-- Deleting Unused Columns


ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate










