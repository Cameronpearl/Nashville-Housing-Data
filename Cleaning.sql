-- Standardize data format

Select CleanSalesDate
from Sheet1$

alter table Sheet1$
add CleanSalesDate Date

update Sheet1$
set CleanSalesDate = CONVERT(date, SaleDate)

-- Populate Null Property Address

Select PropertyAddress
from Sheet1$
where PropertyAddress is null

--this query compares where parcelID is the same and uniqueid is different since the address will be the same and checks where propertyaddress is null
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from Sheet1$ a
join Sheet1$ b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- updates the null columns with the correct address
update a
set PropertyAddress  = ISNULL(a.propertyaddress, b.propertyaddress)
from Sheet1$ a
join Sheet1$ b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- seperate address into seperate columns

select PropertyAddress
from Sheet1$

-- using the comma as a delimiter seperate the address and the city
Select 
SUBSTRING(propertyaddress, 1, CHARINDEX(',',propertyaddress)-1) as Address
from Sheet1$

Select 
SUBSTRING(propertyaddress, CHARINDEX(',',propertyaddress)+2,LEN(propertyaddress)) as City
from Sheet1$

Alter table sheet1$
add Address varchar(255),
City varchar(100)

update Sheet1$
set Address = SUBSTRING(propertyaddress, 1, CHARINDEX(',',propertyaddress)-1),
city = SUBSTRING(propertyaddress, CHARINDEX(',',propertyaddress)+2,LEN(propertyaddress))

select *
from Sheet1$

-- same but for the owner address

Select TOP 100 *
from Sheet1$


Select 
SUBSTRING(OwnerAddress, 1, CHARINDEX(',',OwnerAddress)-1) as ownerAddressclean
from Sheet1$


Select 
SUBSTRING(OwnerAddress, CHARINDEX(',',OwnerAddress)+2,LEN(propertyaddress)) as City
from Sheet1$

Select 
SUBSTRING(OwnerCity, CHARINDEX(',',OwnerCity)+1,LEN(OwnerCity)) as State
from Sheet1$


Alter table sheet1$
add OwnerStreetAddress varchar(255),
OwnerCity varchar(100),
OwnerState varchar(50)

update Sheet1$
set OwnerStreetAddress = SUBSTRING(OwnerAddress, 1, CHARINDEX(',',OwnerAddress)-1)

update Sheet1$
set OwnerState = SUBSTRING(OwnerCity,CHARINDEX(',',OwnerCity)+2,LEN(OwnerCity))

update Sheet1$
set OwnerCity = SUBSTRING(OwnerCity, 1,CHARINDEX(',',OwnerCity)-1)


--soldasvacant has values: Y, Yes, N, No and must be standardized to Yes and No

Select soldasvacant,
case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant end
from Sheet1$

update Sheet1$
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant end
from Sheet1$

select Distinct soldasvacant
from Sheet1$


-- Remove Duplicates (not standard practice but using CTE to showcase )

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Sheet1$
)
Delete
From RowNumCTE
Where row_num > 1



-- Delete Unused columns

select *
from Sheet1$

alter table sheet1$
drop column owneraddress, taxdistrict, propertyaddress, saledate
