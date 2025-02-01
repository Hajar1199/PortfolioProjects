-- Nashville Housing Project, Data Cleaning in SQL Queries 

SELECT * FROM nashville_housing_project.nashville_housing;

-- Standardize Date Format--------------------

Select STR_TO_DATE(SaleDate, '%m/%d/%Y')
FROM nashville_housing_project.nashville_housing;

Update nashville_housing_project.nashville_housing
SET SaleDate = STR_TO_DATE(SaleDate, '%m/%d/%Y');

-- There's null values in PropertyAddress column, which can be filled by using the same ParcelID for the null rows to Populate the PropertyAddress ----
Select *
FROM nashville_housing_project.nashville_housing
Where PropertyAddress = ''
order by ParcelID;

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From nashville_housing_project.nashville_housing a
JOIN nashville_housing_project.nashville_housing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress = '';

Update nashville_housing_project.nashville_housing a
JOIN nashville_housing_project.nashville_housing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = b.PropertyAddress
Where a.PropertyAddress = '';

-- checking there's no null left in the PropertyAddress column------- 
Select *
FROM nashville_housing_project.nashville_housing
Where PropertyAddress = ''
order by ParcelID;


-- Breaking out PropertyAddress into Individual Columns (Address, City)

Select PropertyAddress
FROM nashville_housing_project.nashville_housing;

SELECT
SUBSTRING_INDEX(PropertyAddress, ',', 1) as Address
,SUBSTRING_INDEX(PropertyAddress, ',', -1) as Address
FROM nashville_housing_project.nashville_housing;

ALTER TABLE nashville_housing_project.nashville_housing
Add PropertySplitAddress Nvarchar(255);

Update nashville_housing_project.nashville_housing
SET PropertySplitAddress = SUBSTRING_INDEX(PropertyAddress, ',', 1);


ALTER TABLE nashville_housing_project.nashville_housing
Add PropertySplitCity Nvarchar(255);

Update nashville_housing_project.nashville_housing
SET PropertySplitCity = SUBSTRING_INDEX(PropertyAddress, ',', -1);

-- Breaking out the OwnerAddress into Individual Columns (Address, City, State)------
Select * 
FROM nashville_housing_project.nashville_housing;

Select
SUBSTRING_INDEX(OwnerAddress, ',', 1) as Address,
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) as City,
SUBSTRING_INDEX(OwnerAddress, ',', -1) as State
FROM nashville_housing_project.nashville_housing;


ALTER TABLE nashville_housing_project.nashville_housing
Add OwnerSplitAddress Nvarchar(255);

Update nashville_housing_project.nashville_housing
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);

ALTER TABLE nashville_housing_project.nashville_housing
Add OwnerSplitCity Nvarchar(255);

Update nashville_housing_project.nashville_housing
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1);

ALTER TABLE nashville_housing_project.nashville_housing
Add OwnerSplitState Nvarchar(255);

Update nashville_housing_project.nashville_housing
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1);


-- Change Y and N to Yes and No in "Sold as Vacant" field --------------------------------------------
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From nashville_housing_project.nashville_housing
Group by SoldAsVacant
order by 2;

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From nashville_housing_project.nashville_housing;


Update nashville_housing_project.nashville_housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END;

-- Remove Duplicates ---------------------------------------------------
ALTER TABLE nashville_housing_project.nashville_housing ADD row_num INT;

CREATE TABLE nashville_housing_project.nashville_housing_DuplicatesRemoved
(`UniqueID` int,
`ParcelID` text,
`LandUse` text,
`PropertyAddress` text,
`SaleDate` text,
`SalePrice` int,
`LegalReference` text,
`SoldAsVacant` text,
`OwnerName` text,
`OwnerAddress` text,
`Acreage` double,
`TaxDistrict` text,
`LandValue` int,
`BuildingValue` int,
`TotalValue` int,
`YearBuilt` int,
`Bedrooms` int,
`FullBath` int,
`HalfBath` int,
`PropertySplitAddress` varchar(255),
`PropertySplitCity` varchar(255),
`OwnerSplitAddress` varchar(255),
`OwnerSplitCity` varchar(255),
`OwnerSplitState` varchar(255),
`row_num` int);

INSERT INTO nashville_housing_project.nashville_housing_DuplicatesRemoved
(UniqueID,
ParcelID,
LandUse,
PropertyAddress,
SaleDate,
SalePrice,
LegalReference,
SoldAsVacant,
OwnerName,
OwnerAddress,
Acreage,
TaxDistrict,
LandValue,
BuildingValue,
TotalValue,
YearBuilt,
Bedrooms,
FullBath,
HalfBath,
PropertySplitAddress,
PropertySplitCity,
OwnerSplitAddress,
OwnerSplitCity,
OwnerSplitState,
row_num)
SELECT UniqueID,
ParcelID,
LandUse,
PropertyAddress,
SaleDate,
SalePrice,
LegalReference,
SoldAsVacant,
OwnerName,
OwnerAddress,
Acreage,
TaxDistrict,
LandValue,
BuildingValue,
TotalValue,
YearBuilt,
Bedrooms,
FullBath,
HalfBath,
PropertySplitAddress,
PropertySplitCity,
OwnerSplitAddress,
OwnerSplitCity,
OwnerSplitState,
ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From nashville_housing_project.nashville_housing;
-- Checking that we only deleting the Duplicates----- 
select * from nashville_housing_project.nashville_housing_DuplicatesRemoved
WHERE row_num >1;

DELETE FROM nashville_housing_project.nashville_housing_DuplicatesRemoved
WHERE row_num >1;

-- Delete Unused Columns-----------------------

ALTER TABLE nashville_housing_project.nashville_housing_DuplicatesRemoved
DROP COLUMN OwnerAddress, DROP COLUMN TaxDistrict, DROP COLUMN PropertyAddress;

