Select * 
From HousingData..NashvilleHousing

--Standardize Date Format--

Alter Table HousingData..NashvilleHousing
Alter Column SaleDate date not null

--Populate Property Address--

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IsNull(a.PropertyAddress, b.PropertyAddress)
From HousingData..NashvilleHousing a
Join HousingData..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ] 
Where a.PropertyAddress is null 

Update a
Set PropertyAddress = IsNull(a.PropertyAddress, b.PropertyAddress)
From HousingData..NashvilleHousing a
Join HousingData..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ] 
Where a.PropertyAddress is null 

--Dividing Property Address into columns by Street Address and City Using Substring Method--

Select PropertyAddress
From HousingData..NashvilleHousing

Select Substring(PropertyAddress, 1, Charindex(',', PropertyAddress) -1) as 'Street Address',
Substring(PropertyAddress, Charindex(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
From HousingData..NashvilleHousing

Alter Table HousingData..NashvilleHousing
Add Street_Address nvarchar(255)

Update HousingData..NashvilleHousing
Set Street_Address = Substring(PropertyAddress, 1, Charindex(',', PropertyAddress) -1)

Alter Table HousingData..NashvilleHousing
Add City nvarchar(255)

Update HousingData..NashvilleHousing
Set City = Substring(PropertyAddress, Charindex(',', PropertyAddress) + 1, LEN(PropertyAddress))

--Dividing Owner Address into Street Address, City, and State using Parsename--

Select 
Parsename(Replace(OwnerAddress, ',', '.'), 3),
Parsename(Replace(OwnerAddress, ',', '.'), 2),
Parsename(Replace(OwnerAddress, ',', '.'), 1)
From HousingData..NashvilleHousing

Alter Table HousingData..NashvilleHousing
Add Owner_Street_Address nvarchar(255)

Update HousingData..NashvilleHousing
Set Owner_Street_Address = Parsename(Replace(OwnerAddress, ',', '.'), 3)

Alter Table HousingData..NashvilleHousing
Add Owner_City nvarchar(255)

Update HousingData..NashvilleHousing
Set Owner_city = Parsename(Replace(OwnerAddress, ',', '.'), 2)

Alter Table HousingData..NashvilleHousing
Add Owner_State nvarchar(255)

Update HousingData..NashvilleHousing
Set Owner_State = Parsename(Replace(OwnerAddress, ',', '.'), 1)

--Changing "Y" and "N" to "Yes" and "No" in SoldAsVacant Column--

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From HousingData..NashvilleHousing
Group by SoldasVacant
Order by 2

Select SoldAsVacant
, Case When SoldAsVacant = 'Y' Then 'Yes'
When SoldAsVacant = 'N' Then 'No'
Else SoldAsVacant
End
From HousingData..NashvilleHousing

Update HousingData..NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
When SoldAsVacant = 'N' Then 'No'
Else SoldAsVacant
End

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From HousingData..NashvilleHousing
Group by SoldasVacant
Order by 2

--Remove Duplicates--

With Duplicate_CTE as (
Select *,
	Row_Number() Over (
	Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	Order by UniqueID) Duplicate

From HousingData..NashvilleHousing
)

Delete
From Duplicate_CTE
Where Duplicate > 1

--Delete Unused Columns--

Alter Table HousingData..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress




