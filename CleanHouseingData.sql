/*-------------------------------------------
Cleaning Data in SQL Queries
*/-------------------------------------------

Select *
From PortfolioProject..NashvilleHousing
--------------------------------------------------
--standardize date format
Select SaleDateConverted, Convert(Date,SaleDate)
From PortfolioProject..NashvilleHousing

update NashvilleHousing
Set SaleDate = Convert(Date, SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

update NashvilleHousing
Set SaleDateConverted = convert(Date, SaleDate)

---------------------------------------------------
--populate property address data

Select *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is NULL
Order By ParcelID
--Same ParcelID have same Address, so if one of the ParcelID have Address, we can populate it into others that have same ID

Select a.ParcelID, a. PropertyAddress, b.ParcelID, b.PropertyAddress
, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL


Update a 
Set propertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL
--After update, there should not be NULL in the  PropertyAddress column 


---------------------------------------------------------------------------
--breaking out address into individual columns
--address, city, state

Select PropertyAddress
From PortfolioProject..NashvilleHousing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)- 1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, Len(PropertyAddress))  as Address
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)- 1)
 
Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, Len(PropertyAddress))

Select *
From PortfolioProject..NashvilleHousing


--Looking at the OwnerAddress
Select OwnerAddress
From PortfolioProject..NashvilleHousing

Select 
PARSENAME(Replace(OwnerAddress,',','.'), 3) 
, PARSENAME(Replace(OwnerAddress,',','.'), 2)
, PARSENAME(Replace(OwnerAddress,',','.'), 1)
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

update NashvilleHousing
Set OwnerSplitAddress= PARSENAME(Replace(OwnerAddress,',','.'), 3) 
 
Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'), 2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'), 1)

Select * 
From PortfolioProject..NashvilleHousing




----------------------------------------------------------------------
--change Y and N to YES and NO in "sold as vacant" field 

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group By SoldAsVacant
Order By 2

Select SoldAsVacant
, Case When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End
From PortfolioProject..NashvilleHousing
 

Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End



----------------------------------------------------------------
--remove duplicates
--Writing CTE 
With RowNumCTE As(
Select *, 
	Row_Number() Over (
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By 
					UniqueID
					) row_num

From PortfolioProject..NashvilleHousing
--Order By ParcelID
)
Select * 
From RowNumCTE
Where row_num > 1 
Order By PropertyAddress



With RowNumCTE As(
Select *, 
	Row_Number() Over (
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By 
					UniqueID
					) row_num

From PortfolioProject..NashvilleHousing
--Order By ParcelID
)
Delete 
From RowNumCTE
Where row_num > 1 
--Order By PropertyAddress


--------------------------------------------------

--delete unused columns

Select *
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Drop Column OwnerAddress, taxDistrict, PropertyAddress

Alter Table PortfolioProject..NashvilleHousing
Drop Column SaleDate






