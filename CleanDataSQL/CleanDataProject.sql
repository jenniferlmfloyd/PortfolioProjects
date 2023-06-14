/*
Cleaning Data in SQL Queries
*/


Select *
From CleanDataProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select SaleDateConverted, CONVERT(Date,SaleDate)
From CleanDataProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
from CleanDataProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
from CleanDataProject.dbo.NashvilleHousing a
join CleanDataProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from CleanDataProject.dbo.NashvilleHousing a
join CleanDataProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
from CleanDataProject.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select
SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) -1 ) as Address
, SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) + 1, LEN(propertyaddress)) as Address
from CleanDataProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) -1 )

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) + 1, LEN(propertyaddress))

Select *
from CleanDataProject.dbo.NashvilleHousing



Select OwnerAddress
from CleanDataProject.dbo.NashvilleHousing

select
PARSENAME(Replace(owneraddress, ',', '.'),3)
,PARSENAME(Replace(owneraddress, ',', '.'),2)
,PARSENAME(Replace(owneraddress, ',', '.'),1)
from CleanDataProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(owneraddress, ',', '.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(owneraddress, ',', '.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(owneraddress, ',', '.'),1)

Select *
from CleanDataProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldasVacant)
from CleanDataProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
,	case when soldasvacant = 'Y' Then 'Yes'
		when soldasvacant = 'N' Then 'No'
		Else Soldasvacant
		End
from CleanDataProject.dbo.NashvilleHousing


update NashvilleHousing
Set SoldAsVacant = case when soldasvacant = 'Y' Then 'Yes'
		when soldasvacant = 'N' Then 'No'
		Else Soldasvacant
		End
from CleanDataProject.dbo.NashvilleHousing


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

With RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	Partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order BY UniqueID
					) row_num

from CleanDataProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
Delete
From rowNumCTE
where row_num > 1


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
from CleanDataProject.dbo.NashvilleHousing

Alter TABLE CleanDataProject.dbo.NashvilleHousing
DROP Column SaleDate, OwnerAddress, TaxDistrict, PropertyAddress