--Cleaning data with SQL Queries

Select * 
from nashvilleHousing

--Converting Sales date to standardize format

Select saledate
from nashvilleHousing

alter table nashvilleHousing 
add saleDateConverted date

update nashvilleHousing
set saleDateConverted = convert(date,saledate)

select saleDateConverted
from nashvilleHousing

--populate property address data

select *
from nashvilleHousing
where propertyaddress is null

--isolating the null value
select a.parcelID, a.propertyaddress, b.parcelID, b.propertyaddress, ISNULL(a.propertyaddress,b.propertyaddress)
from nashvilleHousing a
join nashvilleHousing b
on a.parcelID = b.parcelID
and a.uniqueID <> b.uniqueID
where a.propertyaddress is null



--replacing the null value
update a
set propertyAddress = ISNULL(a.propertyaddress,b.propertyaddress)
from nashvilleHousing a
join nashvilleHousing b
on a.parcelID = b.parcelID
and a.uniqueID <> b.uniqueID
where a.propertyaddress is null


--breaking the address to (address, city, state)


select propertyaddress
from nashvilleHousing

select
SUBSTRING(propertyaddress, 1, CHARINDEX(',',propertyaddress) -1) as Address
,SUBSTRING(propertyaddress, CHARINDEX(',',propertyaddress) + 1, LEN(propertyaddress)) as Address
from nashvilleHousing


alter table nashvilleHousing 
add propertySplitAddress varchar(255)

update nashvilleHousing
set propertySplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',',propertyaddress) -1) 

alter table nashvilleHousing 
add propertySplitCity varchar(255)

update nashvilleHousing
set propertySplitCity = SUBSTRING(propertyaddress, 1, CHARINDEX(',',propertyaddress) -1)


select owneraddress
from nashvilleHousing

select
PARSENAME(replace(owneraddress,',','.'),3),
PARSENAME(replace(owneraddress,',','.'),2),
PARSENAME(replace(owneraddress,',','.'),1)
from nashvilleHousing


alter table nashvilleHousing 
add ownerSplitAddress varchar(255)

update nashvilleHousing
set ownerSplitAddress = PARSENAME(replace(owneraddress,',','.'),3)


alter table nashvilleHousing 
add ownerSplitCity varchar(255)

update nashvilleHousing
set ownerSplitCity = PARSENAME(replace(owneraddress,',','.'),2)


alter table nashvilleHousing 
add ownerSplitState varchar(255)

update nashvilleHousing
set ownerSplitState = PARSENAME(replace(owneraddress,',','.'),1)

select * 
from nashvilleHousing




--Change Y and N to Yes and No in "Sold as Vacant" field


select distinct(soldAsVacant), count(soldAsVacant)
from nashvilleHousing
group by soldAsVacant
order by 2 desc


select soldAsVacant,
CASE when soldAsVacant = 'Y' then 'YES'
	 when soldAsVacant = 'N' then 'NO'
	 ELSE soldAsVacant
	 END
from nashvilleHousing


update nashvilleHousing
set soldAsVacant = CASE when soldAsVacant = 'Y' then 'YES'
	 when soldAsVacant = 'N' then 'NO'
	 ELSE soldAsVacant
	 END




--Remove Duplicates

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

From nashvilleHousing
)

delete 
From RowNumCTE
Where row_num > 1


--delete unused columns

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
from nashvilleHousing


Select *
From PortfolioProject.dbo.NashvilleHousing



















