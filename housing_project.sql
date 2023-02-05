--Select whole data

use portfolio_project

select * from [dbo].[NashvilleHousing]
-----------------------------------------------------------

--standerised date format

select saledate from [dbo].[NashvilleHousing]

alter table [dbo].[NashvilleHousing] add saledataConvert date

update [dbo].[NashvilleHousing] set saledataConvert=convert(date,saledate)

select saledataConvert from [dbo].[NashvilleHousing]

-------------------------------------------------------------------------------------------

--Remove null from property address
-- Here same parcelid repeated many times, but in property address column some of them has null values, so we are going to replace null values with the address
-- which have same parcelid

select a.ParcelId, a.propertyaddress, b.parcelid, b.propertyaddress from [dbo].[NashvilleHousing] as a join [dbo].[NashvilleHousing] as b
on a.parcelid=b.parcelid and a.uniqueid <> b.uniqueid where a.propertyaddress is Null

update a set a.propertyaddress=b.propertyaddress from [dbo].[NashvilleHousing] as a join [dbo].[NashvilleHousing] as b
on a.parcelid=b.parcelid and a.uniqueid <> b.uniqueid where a.propertyaddress is Null

select propertyaddress from [dbo].[NashvilleHousing]

--we successfully removed all null values from propertyaddress
-----------------------------------------------------------------------------------------------------------------
 
 --Split address and city from propertyaddress column

-- below code will split address from propertyadress column
 select propertyaddress, substring(propertyaddress,1,CHARINDEX(',',propertyaddress)-1) from [dbo].[NashvilleHousing]

 --split city
 select propertyaddress, substring(propertyaddress,charindex(',',propertyaddress)+1,len(propertyaddress)) from [dbo].[NashvilleHousing]

 -- create two column to hold these data
 alter table [dbo].[NashvilleHousing] add PropertyAddressSplit Nvarchar(255)

 alter table [dbo].[NashvilleHousing] add city Nvarchar(255)

 --update table
 update [dbo].[NashvilleHousing] set PropertyAddressSplit= substring(propertyaddress,1,CHARINDEX(',',propertyaddress)-1) 

  update [dbo].[NashvilleHousing] set city= substring(propertyaddress,charindex(',',propertyaddress)+1,len(propertyaddress))

select PropertyAddressSplit, city from [dbo].[NashvilleHousing]
-----------------------------------------------------------------------------------------------------------------

--split owner address
select owneraddress from [dbo].[NashvilleHousing]

--split address
select owneraddress, substring(owneraddress, 1, charindex(',',owneraddress)-1) from [dbo].[NashvilleHousing]

--split city
select owneraddress, PARSENAME(replace(owneraddress,',','.'),2) from [dbo].[NashvilleHousing]

--split state
select owneraddress, parsename(replace(owneraddress,',','.'),1) from [dbo].[NashvilleHousing]

--create new columns to hold these data

alter table [dbo].[NashvilleHousing] add owneraddressSplit nvarchar(255)

alter table [dbo].[NashvilleHousing] add ownercity nvarchar(255)
alter table [dbo].[NashvilleHousing] add ownerstate nvarchar(255)

-- Add values to new columns

update [dbo].[NashvilleHousing] set owneraddressSplit = substring(owneraddress, 1, charindex(',',owneraddress)-1) 
update [dbo].[NashvilleHousing] set ownercity= parsename(replace(owneraddress,',','.'),2)
update [dbo].[NashvilleHousing] set ownerstate= parsename(replace(owneraddress,',','.'),1)

select owneraddressSplit,ownercity,ownerstate from  [dbo].[NashvilleHousing]

-----------------------------------------------------------------------------------------------------
--change y to yes and n to no of SoldAsVacant field
select [SoldAsVacant] from [dbo].[NashvilleHousing]
select distinct [SoldAsVacant], count([SoldAsVacant]) from [dbo].[NashvilleHousing] group by [SoldAsVacant]

select [SoldAsVacant],
case when [SoldAsVacant]='N' then 'No'
     when [SoldAsVacant]='Y' then 'Yes'
	 else [SoldAsVacant]
end 
from [dbo].[NashvilleHousing]

-- Update SoldAsVacant column
update [dbo].[NashvilleHousing] set 
[SoldAsVacant]=case when [SoldAsVacant]='N' then 'No'
                    when [SoldAsVacant]='Y' then 'Yes'
end 
from [dbo].[NashvilleHousing]

-------------------------------------------------------------------------------
--Remove duplicate rows

--find duplicate rows
with cte as(select *, ROW_NUMBER() over(partition by parcelid,propertyaddress,saledate,saleprice,legalreference order by parcelid) 
as row_num from [dbo].[NashvilleHousing])
select * from cte where row_num >1

--Delete duplicates
with cte as(select *, ROW_NUMBER() over(partition by parcelid,propertyaddress,saledate,saleprice,legalreference order by parcelid) 
as row_num from [dbo].[NashvilleHousing])
delete from cte where row_num >1


