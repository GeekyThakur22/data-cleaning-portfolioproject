---------------------------------------------------------------------------
--cleaning data in sql Queries

select*
from [housing society]

---------------------------------------------------------------------------
--standardize date format

select SaleDateConverted,CONVERT(date,SaleDate)
from [housing society]

update [housing society]
set SaleDate=CONVERT(date,SaleDate)

alter table [housing society]
add saleDateConverted date;

update [housing society]
set saleDateConverted =CONVERT(date,SaleDate)

----------------------------------------------------------------------------
--Populate Proprty Address data

select*
from [housing society]
where PropertyAddress is null
order by ParcelID

select A.ParcelID,A.PropertyAddress,B.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from [housing society] A
join [housing society] B
on A.ParcelID=B.ParcelID
and A.[UniqueID ]<>B.[UniqueID ]
where A.PropertyAddress is null

update A
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from [housing society] A
join [housing society] B
on A.ParcelID=B.ParcelID
and A.[UniqueID ]<>B.[UniqueID ]
where A.PropertyAddress is null

-------------------------------------------------------------------------------------
--Sorting out address into separate columns( Address,City,State)

select PropertyAddress
from [housing society]
--where PropertyAddress is null
--order by ParcelID

select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,len(PropertyAddress)) as Address
from [housing society]

alter table [housing society]
add  PropertySplitAddress nvarchar(255);

update [housing society]
set PropertySplitAddress =SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table [housing society]
add PropertySplitCity nvarchar(255);

update [housing society]
set PropertySplitCity =SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,len(PropertyAddress))


select 
parsename(replace(OwnerAddress,',','.'),3),
parsename(replace(OwnerAddress,',','.'),2),
parsename(replace(OwnerAddress,',','.'),1)
from [housing society]

alter table [housing society]
add  OwnerSplitAddress nvarchar(255);

update [housing society]
set OwnerSplitAddress =parsename(replace(OwnerAddress,',','.'),3)




alter table [housing society]
add OwnerSplitCity nvarchar(255);

update [housing society]
set OwnerSplitCity =parsename(replace(OwnerAddress,',','.'),2)



alter table [housing society]
add OwnerSplitstate nvarchar(255);

update [housing society]
set OwnerSplitstate =parsename(replace(OwnerAddress,',','.'),1)


select*
from [housing society]

---------------------------------------------------------------------------------------------------------------------------------------------------------
--Change Y and N to yes and no in "Solid as vacant"field

select distinct(SoldAsVacant),count(SoldAsVacant)
from [housing society]
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant  = 'Y' then 'yes'
     when SoldAsVacant  = 'N' then 'no'
     else SoldAsVacant
     end
from [housing society]


update [housing society]
set SoldAsVacant=case when SoldAsVacant  = 'Y' then 'yes'
     when SoldAsVacant  = 'N' then 'no'
     else SoldAsVacant
     end


--------------------------------------------------------------------------------------------------------------------------------------
--Remove duplicates 
WITH RowNumCTE as(
select*,
row_number()over(
partition by parcelID,
             propertyAddress,
             salePrice,
             LegalReference
            Order by 
             uniqueID
			 )row_num
from [housing society]
)
select*
from RowNumCTE
where row_num>1
order by propertyaddress


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Delete unused Columns

select*
from portfolioProject..[housing society]

alter table portfolioProject..[housing society]
drop column owneraddress,taxdistrict,propertyaddress

alter table portfolioProject..[housing society]
drop column SaleDate
