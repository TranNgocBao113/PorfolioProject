--DATA CLEANING--

--Open and look through the data

select *
from [Porfolio Project]..[Nashville Housing Data];

--Populate property address data
select * 
from [Porfolio Project]..[Nashville Housing Data]
--where PropertyAddress is null
--where ParcelID = '026 05 0 017.00'
where UniqueID = '45290'
order by ParcelID;

--I've already check and change the data type when I insert the data into Database
-----------------------------------------------------------------------------------------------------------------------------------------------------

--Check the PropertyAddress's null value and fill it with the right Property Address
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from [Porfolio Project]..[Nashville Housing Data] a
join [Porfolio Project]..[Nashville Housing Data]b
on
	a.ParcelID = b.ParcelID
	and a.UniqueID <> b. UniqueID
where a.PropertyAddress is null;


--Update the correct address to the table
update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from [Porfolio Project]..[Nashville Housing Data] a
join [Porfolio Project]..[Nashville Housing Data]b
on
	a.ParcelID = b.ParcelID
	and a.UniqueID <> b. UniqueID
where a.PropertyAddress is null;

--Check the original table again
select *
from [Porfolio Project]..[Nashville Housing Data]
where PropertyAddress is null;

-----------------------------------------------------------------------------------------------------------------------------------------------------

--Split the Address column into individual columns (Address, city, state)

-----Split the property address into individual columns (address, city)
select 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as PropertySplitAddress,
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress)) as PropertySplitCity 
from [Porfolio Project]..[Nashville Housing Data]

-----create 2 columns (PropertySplitAddress, PropertySplitCity) in the original table
alter table
[Porfolio Project]..[Nashville Housing Data]
add PropertySplitAddress nvarchar(255);

alter table 
[Porfolio Project]..[Nashville Housing Data]
add PropertySplitCity nvarchar(255);

-----Insert data into 2 new columns
update 
[Porfolio Project]..[Nashville Housing Data]
set PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

update 
[Porfolio Project]..[Nashville Housing Data]
set PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress));

-----Check the table
select *
from [Porfolio Project]..[Nashville Housing Data]


-----Split the Owner address into individual columns (address, city, state) using parsename
select
PARSENAME (replace(OwnerAddress, ',', '.'), 3),
PARSENAME (replace(OwnerAddress, ',', '.'), 2),
PARSENAME (replace(OwnerAddress, ',', '.'), 1)
from [Porfolio Project]..[Nashville Housing Data];

-----Create 2 columns (OwnerSplitAddress, OwnerSplitCity, OwnerSplitState) in table
alter table
[Porfolio Project]..[Nashville Housing Data]
add OwnerSplitAddress nvarchar(255);

alter table 
[Porfolio Project]..[Nashville Housing Data]
add OwnerSplitCity nvarchar(255);

alter table 
[Porfolio Project]..[Nashville Housing Data]
add OwnerSplitState nvarchar(255);

-----Insert data into 2 new columns

update 
[Porfolio Project]..[Nashville Housing Data]
set OwnerSplitAddress = PARSENAME (replace(OwnerAddress, ',', '.'), 3);

update 
[Porfolio Project]..[Nashville Housing Data]
set OwnerSplitCity = PARSENAME (replace(OwnerAddress, ',', '.'), 2);

update 
[Porfolio Project]..[Nashville Housing Data]
set OwnerSplitState = PARSENAME (replace(OwnerAddress, ',', '.'), 1);

-----Check the table
select *
from [Porfolio Project]..[Nashville Housing Data]


-----------------------------------------------------------------------------------------------------------------------------------------------------
--Change the Y and N to Yes and No in "SoldAsVacant"
-----Check the values in the "SoldAsVacant" field
select SoldAsVacant, COUNT(SoldAsVacant)
from [Porfolio Project]..[Nashville Housing Data]
group by SoldAsVacant
order by 2;

-----Change the Y and N to Yes and No
select SoldAsVacant,
Case 
when SoldAsVacant = 'Y'then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
from [Porfolio Project]..[Nashville Housing Data];

-----update the "SoldAsVacant" field
update [Porfolio Project]..[Nashville Housing Data]
set SoldAsVacant = Case 
when SoldAsVacant = 'Y'then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end

-----Check the table
select SoldAsVacant, COUNT(SoldAsVacant)
from [Porfolio Project]..[Nashville Housing Data]
group by SoldAsVacant
order by 2;


----------------------------------------------------------------------------------------------------------------------------------------------------
--Remove duplicates
-----Count individuals UniqueID and compare to the total row of the table to check whether the UniqueID has duplicate or not 
select count(distinct(UniqueID))
from [Porfolio Project]..[Nashville Housing Data];

select *
from [Porfolio Project]..[Nashville Housing Data]

-----Query all rows has more than 1 observation and delet them.
-----I don't want to delete the data in the original data, so I'll delete them in CTE.

WITH RowNumCTE AS (
    SELECT *, 
           ROW_NUMBER() OVER (PARTITION BY 
                               ParcelID,
                               SaleDate,
                               LegalReference,
                               PropertyAddress,
                               SalePrice 
                              ORDER BY 
                               SaleDate) AS row_num
    FROM [Porfolio Project]..[Nashville Housing Data]
)
delete 
FROM RowNumCTE
WHERE row_num > 1;



-----Delete the unused columns
alter table
[Porfolio Project]..[Nashville Housing Data]
drop column PropertyAddress, OwnerAddress

select *
from [Porfolio Project]..[Nashville Housing Data]