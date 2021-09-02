-- Standardize Date Format



ALTER TABLE NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT saledateconverted, CONVERT(Date, SaleDate)
FROM [SQL Project].dbo.NashvilleHousing

--Populate Property Address Data


SELECT PropertyAddress
FROM [SQL Project].dbo.NashvilleHousing
WHERE PropertyAddress is null

-- Why are there null values? Let's select
-- everything where property values are null.

SELECT*
FROM [SQL Project].dbo.NashvilleHousing
WHERE PropertyAddress is null

-- Let's look at everything ordered by parcel ID

SELECT *
FROM NashvilleHousing
Order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--Breaking out Address Info Into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM NashvilleHousing

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
 SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, Len(PropertyAddress)) as Address

FROM NashvilleHousing

-- Add split addresses to table

ALTER TABLE NashvilleHousing
Add PropertySplitAddress NVARCHAR(255)

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity NVARCHAR(255)

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, Len(PropertyAddress))


SELECT*
FROM [SQL Project].dbo.NashvilleHousing



SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress NVARCHAR(255)

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity NVARCHAR(255)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState NVARCHAR(255)

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--SELECT *
--FROM [SQL Project].dbo.NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT SoldAsVacant, Count(SoldAsVacant)
FROM NashvilleHousing
GROUP by SoldAsVacant
Order by 2

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant 
		 END
FROM NashvilleHousing

--Update Table with new Yes and No fields in Sold as Vacant


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant 
		 END

SELECT SoldAsVacant, Count(SoldAsVacant)
FROM NashvilleHousing
GROUP by SoldAsVacant
Order by 2


-- Now let's remove the duplicates using a CTE

WITH RowNumCTE AS (
SELECT*,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelId,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM [SQL Project].dbo.NashvilleHousing
)
DELETE
From RowNumCTE
WHERE row_num > 1
--ORDER by PropertyAddress

--Check to see if duplicates are removed

WITH RowNumCTE AS (
SELECT*,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelId,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM [SQL Project].dbo.NashvilleHousing
)
SELECT*
From RowNumCTE
WHERE row_num > 1
ORDER by PropertyAddress

-- And they are!

-- Now Let's Delete Unused Columns

SELECT*
FROM [SQL Project].dbo.NashvilleHousing

ALTER TABLE [SQL Project].dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


ALTER TABLE [SQL Project].dbo.NashvilleHousing
DROP COLUMN SaleDate

SELECT*
FROM [SQL Project].dbo.NashvilleHousing


-- Now the data is in a far more useable state.






