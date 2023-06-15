/*
Cleaning Data using SQL Queries
*/

SELECT *
FROM [Portfolio Project].dbo.NasvilleHousing

-- Standardize Date Format
SELECT Convert(Date,SaleDate)
FROM [Portfolio Project].dbo.NasvilleHousing

ALTER TABLE NasVilleHousing
Add ConvertedSaleDate Date;

UPDATE NasvilleHousing
SET ConvertedSaleDate=CONVERT(Date,SaleDate)



-- Populate Property Address data
SELECT *
FROM [Portfolio Project].dbo.NasvilleHousing
where PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID,b.ParcelID,a.PropertyAddress,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Portfolio Project].dbo.NasvilleHousing a
JOIN [Portfolio Project].dbo.NasvilleHousing b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Portfolio Project].dbo.NasvilleHousing a
JOIN [Portfolio Project].dbo.NasvilleHousing b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL




-- Splitting Address into Address, City,state
SELECT PropertyAddress
FROM [Portfolio Project].dbo.NasvilleHousing
--where PropertyAddress is null
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)as Address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))as Address
FROM [Portfolio Project].dbo.NasvilleHousing


ALTER TABLE NasvilleHousing
Add SplitPropertyAddress nvarchar(255)


UPDATE NasvilleHousing
SET SplitPropertyAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE NasvilleHousing
Add SplitPropertyCity nvarchar(255)

UPDATE NasvilleHousing
SET SplitPropertyCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT OwnerAddress
FROM [Portfolio Project].dbo.NasvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM [Portfolio Project].dbo.NasvilleHousing

ALTER TABLE NasvilleHousing
Add OwnerPropertyAddress nvarchar(255)

UPDATE NasvilleHousing
SET OwnerPropertyAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NasvilleHousing
Add OwnerPropertyCity nvarchar(255)

UPDATE NasvilleHousing
SET OwnerPropertyCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NasvilleHousing
Add OwnerPropertyState nvarchar(255)

UPDATE NasvilleHousing
SET OwnerPropertyState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM [Portfolio Project].dbo.NasvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT SoldAsVacant,COUNT(SoldAsVacant)
FROM [Portfolio Project].dbo.NasvilleHousing
Group By SoldAsVacant
Order By Count(SoldAsVacant)

SELECT SoldAsVacant
,CASE  When SoldAsVacant='Y' THEN 'Yes'
	  WHEN SoldAsVacant='N' THEN 'NO'
	  ELSE SoldAsVacant
	  END
FROM [Portfolio Project].dbo.NasvilleHousing


Update NasVilleHousing
SET SoldAsVacant= CASE When SoldAsVacant='Y' THEN 'Yes'
	  WHEN SoldAsVacant='N' THEN 'NO'
	  ELSE SoldAsVacant
	  END


--Deleting Unused rows
SELECT *
FROM [Portfolio Project].dbo.NasvilleHousing

ALTER TABLE NasvilleHousing
DROP COLUMN OwnerAddress,SaleDate,PropertyAddress,TaxDistrict

--Removing Duplicates