-- Cleaning data using sql

select *
from [portfolio project]..housing

--standardize date format

alter table [portfolio project]..housing
add sale_date_only date
update [portfolio project]..housing
set sale_date_only= convert(date,SaleDate)


--populate property address data

select a.PropertyAddress, a.ParcelID, b.PropertyAddress, b.ParcelID, ISNULL(a.PropertyAddress,b.PropertyAddress)
from [portfolio project]..housing as a
join [portfolio project]..housing as b
on a.ParcelID=b.ParcelID and
a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
from [portfolio project]..housing as a
join [portfolio project]..housing as b
on a.ParcelID=b.ParcelID and
a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


--Breaking out address into individual columns

-- Property address

select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address1,
SUBSTRING(PropertyAddress,CHARINDEX(',' ,PropertyAddress) +1, len(PropertyAddress)) as Address2
from [portfolio project]..housing

alter table [portfolio project]..housing
add address nvarchar(255)
update [portfolio project]..housing
set address= convert(nvarchar,SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1))

alter table [portfolio project]..housing
add city nvarchar(255)
update [portfolio project]..housing
set city= convert(nvarchar,SUBSTRING(PropertyAddress,CHARINDEX(',' ,PropertyAddress) +1, len(PropertyAddress)))

-- Owner address

select parsename(replace(OwnerAddress,',','.'),3),
parsename(replace(OwnerAddress,',','.'),2),
parsename(replace(OwnerAddress,',','.'),1)
from [portfolio project]..housing

alter table [portfolio project]..housing
add ownersplitaddress nvarchar(255)
update [portfolio project]..housing
set ownersplitaddress = parsename(replace(OwnerAddress,',','.'),3)

alter table [portfolio project]..housing
add ownersplitcity nvarchar(255)
update [portfolio project]..housing
set ownersplitcity = parsename(replace(OwnerAddress,',','.'),2)

alter table [portfolio project]..housing
add ownersplitstate nvarchar(255)
update [portfolio project]..housing
set ownersplitstate = parsename(replace(OwnerAddress,',','.'),1)

--change Y and N to 'Yes' and 'No' in soldasvacant field

update [portfolio project]..housing
set soldasvacant = case when soldasvacant = 'Y' then 'Yes'
when soldasvacant = 'N' then 'No'
else soldasvacant
end

--Remove duplicates

with rownum_cte as (
select *,
  ROW_NUMBER() over (
  partition by parcelid,
               propertyaddress,
			   saledate, 
			   saleprice,
			   legalreference
			   order by uniqueid) as row_num
from [portfolio project]..housing
)
delete
from rownum_cte
where row_num>1

--Delete unused columns

alter table [portfolio project]..housing
drop column propertyaddress,saledate,taxdistrict,owneraddress

select *
from [portfolio project]..housing
