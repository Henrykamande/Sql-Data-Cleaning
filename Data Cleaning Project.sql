/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [houseingdata].[dbo].[NashvilleHousing]

  --selecting all records from the database to have a view of what it looks like
  select *
  From houseingdata..NashvilleHousing 


  -- Standardize the date format 

  select SaleDate , CONVERT(Date, SaleDate)
  from houseingdata..NashvilleHousing

  update NashvilleHousing
  SET SaleDate= CONVERT(Date, SaleDate)

  select SaleDateConverted
  from houseingdata..NashvilleHousing

  ALTER TABLE NashvilleHousing
  Add SaleDateConverted Date;

  update NashvilleHousing
  SET SaleDateConverted = CONVERT(Date,SaleDate)

  --populating property Address

  select*
  From houseingdata..NashvilleHousing
  --where PropertyAddress is null
  order by ParcelID


  select a.ParcelID, a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
  From houseingdata..NashvilleHousing a
  JOIN houseingdata..NashvilleHousing b
	on a.ParcelID =b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

update a
SET PropertyAddress =ISNULL(a.PropertyAddress, b.PropertyAddress)
From houseingdata..NashvilleHousing a
  JOIN houseingdata..NashvilleHousing b
	on a.ParcelID =b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Breaking property address to address,city and state columns
Select PropertyAddress
from houseingdata..NashvilleHousing

SELECT 
--CHARINDEX(',' , PropertyAddress) gives us the index posation of comma delimeter. Subtractin of 1 keep the comma outside the index range.
-- SUBSTRING(PropertyAddress, -1, 18) gives the the first part of the property address
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
-- getting the Substring from the comma delimeter to the end of the string , Len(PropertyAddress) gives the length of the string
,SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) as Address
From houseingdata..NashvilleHousing


--creating new columns to add city and address

ALTER TABLE houseingdata..NashvilleHousing
add PropertySplitAddress NVARCHAR(250);

Update houseingdata..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

ALTER TABLE houseingdata..NashvilleHousing
add PropertySplitCity nvarchar(255);

update houseingdata..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))
 


select OwnerAddress
From houseingdata..NashvilleHousing

select 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

From houseingdata..NashvilleHousing


ALTER TABLE houseingdata..NashvilleHousing
add OwnerSplitAddress NVARCHAR(250);

Update houseingdata..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE houseingdata..NashvilleHousing
add OwnerSplitCity nvarchar(255);

update houseingdata..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
 
ALTER TABLE houseingdata..NashvilleHousing
add OwnerSplitState nvarchar(255);

update houseingdata..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
 

 select * 
 from houseingdata..NashvilleHousing
 -- Changes Y and N In soldAsVacant column to Yes and No

 select Distinct(SoldAsVacant), Count(SoldAsVacant)
 from houseingdata..NashvilleHousing
 Group by SoldAsVacant
 order by 2

 -- using Case statement

 select SoldAsVacant,
 CASE When SoldAsVacant ='Y' THEN 'Yes'
      When SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END

from houseingdata..NashvilleHousing

update houseingdata..NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant ='Y' THEN 'Yes'
      When SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END

-- Remove duplicate records 

WITH RowNumCTE AS (
Select *,
      ROW_NUMBER() OVER(
      PARTITION BY ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY 
						UniqueID ) row_num
FROM houseingdata..NashvilleHousing
)

select * 
From RowNumCTE
where row_num > 1
-- order by PropertyAddress

Select *
From houseingdata..NashvilleHousing 


-- Drop tables not being used

ALTER TABLE houseingdata..NashvilleHousing
DROP COLUMN OwnerAddres, TaxDistrict, PropertyAddress

ALTER TABLE houseingdata..NashvilleHousing
DROP COLUMN SaleDate
