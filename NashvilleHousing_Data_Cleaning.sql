Select *

From PortfolioProject.dbo.NashvilleHousing

-- Change the sale date to make it more standard.

Select SaleDate, CONVERT(Date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add saledateconverted Date;

Update NashvilleHousing
SET saledateconverted = CONVERT(Date, SaleDate)

-- This section of code cleans the property adress data.

Select PropertyAddress

From PortfolioProject.dbo.NashvilleHousing

WHERE PropertyAddress is NULL

SELECT *

From PortfolioProject.dbo.NashvilleHousing

order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL

Update a
SET
PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL

-- This code breaks the address into different columns

Select 
substring(PropertyAddress, 1, charindex(',',PropertyAddress) -1) as Address,
substring(PropertyAddress, charindex(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address2
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add StreetAddress Nvarchar(255);

Update NashvilleHousing
SET StreetAddress = substring(PropertyAddress, 1, charindex(',',PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add CityAddress Nvarchar(255);

Update NashvilleHousing
SET CityAddress = substring(PropertyAddress, charindex(',',PropertyAddress) +1, LEN(PropertyAddress))

Select 
parsename(replace(OwnerAddress, ',' , '.') , 3),
parsename(replace(OwnerAddress, ',' , '.') , 2),
parsename(replace(OwnerAddress, ',' , '.') , 1)
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerStreet Nvarchar(255);

Update NashvilleHousing
SET OwnerStreet = parsename(replace(OwnerAddress, ',' , '.') , 3)

ALTER TABLE NashvilleHousing
Add OwnerCity Nvarchar(255);

Update NashvilleHousing
SET OwnerCity = parsename(replace(OwnerAddress, ',' , '.') , 2)

ALTER TABLE NashvilleHousing
Add OwnerState Nvarchar(255);

Update NashvilleHousing
SET OwnerState = parsename(replace(OwnerAddress, ',' , '.') , 1)

-- This code limits to variation in responses in the SoldAsVacant column

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)

From PortfolioProject.dbo.NashvilleHousing
Group By SoldAsVacant
Order By 2

SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
When SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
When SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END

-- This next code removes duplicate data.
WITH ROWNUMCTE as (
Select *, ROW_NUMBER() OVER(
PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueID ) row_num

From PortfolioProject.dbo.NashvilleHousing
)

DELETE
FROM ROWNUMCTE
WHERE row_num > 1

-- This code deletes unused columns

Select *

From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate