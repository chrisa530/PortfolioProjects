List of queries
--Standardize Data Format
--Populate Property address data and check whats NULL
--Breaking out address into individual Columns (Address, City, State) Method 1
--Breaking out address into individual Columns (Address, City, State) Parsename (Better Method)
--Change Y and N to Yes and No " field
--Removing Duplicate (Not a Standard practice)
--Removing Unwanted Columns


--Standardize Data Format

ALTER TABLE NH
ADD [Sales Date] Date;
GO

UPDATE NH
SET [Sales Date] = CONVERT(Date, SaleDate)



--Populate Property address data and check whats NULL

SELECT *
FROM NH
--WHERE PropertyAddress IS NULL
Order by ParcelID
--Looking through the data we notice that ParcelID is also linked to the address and some of the address may be missing but have the same parcel ID with the same address

--First a self join is need to see if they truly equal and check whats null

SELECT a.ParcelID, a.Propertyaddress, b.ParcelID, b.Propertyaddress--, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NH a
JOIN NH b
on a.parcelID = b.parcelID
AND a.[UniqueID] <> b.[UniqueID] --not the same row
where a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NH a
JOIN NH b
on a.parcelID = b.parcelID
AND a.[UniqueID] <> b.[UniqueID] --not the same row
where a.PropertyAddress IS NULL

SELECT * FROM NH


--Breaking out address into individual Columns (Address, City, State) Part 1
--The propertyaddress column contains the address and city
SELECT PropertyAddress FROM NH

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress)) as City
FROM NH


ALTER TABLE NH ADD PropertySplitAddress nvarchar(255);

UPDATE NH
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE NH ADD PropertySplitCity nvarchar(255);

UPDATE NH
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress)) 

SELECT * FROM NH


--Breaking out address into individual Columns (Address, City, State) Part 2
--The Owneraddress column contains the address and city
--Parsename looks for periods so you would need to convert the commas to period. 
--the positions are backwards. so it goes 3, 2, 1 inside of 1, 2, 3
SELECT OwnerAddress FROM NH

SELECT
PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
FROM NH
------------------------------------------------------------
ALTER TABLE NH ADD OwnerSplitAddress nvarchar(255);

UPDATE NH
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

ALTER TABLE NH ADD OwnerSplitCity nvarchar(255);

UPDATE NH
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)


ALTER TABLE NH ADD OwnerSplitState nvarchar(255);

UPDATE NH
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

SELECT * FROM NH


--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM NH
GROUP BY SoldAsVacant
Order BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END AS New_SoldAsVacant
FROM NH

UPDATE NH
SET SoldAsVacant =
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END 
FROM NH

SELECT * FROM NH

--Remove Duplicates (Not a standard practice to delete data from your database)
--First create a temp table then make a partition

WITH RowNumCTE2 AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID,
                         PropertyAddress,
                         SalePrice,
                         SaleDate,
                         LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM PortfolioProjec.dbo.NH
)
SELECT *
FROM RowNumCTE2
where row_num > 1
order by PropertyAddress

--DELETE the duplicate
WITH RowNumCTE2 AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID,
                         PropertyAddress,
                         SalePrice,
                         SaleDate,
                         LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM PortfolioProjec.dbo.NH
)
DELETE 
FROM RowNumCTE2
where row_num > 1


---Delete Unused Columns (Dont delete your raw data)
SELECT * FROM  NH

ALTER TABLE NH
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate






--

