SELECT * 
FROM [Portfolio project]..housing;

--Change the saledate column

SELECT SaleDate, convert(Date, SaleDate) 
FROM [Portfolio project]..housing;

ALTER table housing
ADD SaleDateConverted Date;

Update [Portfolio project]..housing
SET SaleDateConverted = convert(Date, SaleDate);

---Populate the PropertyAddress column
SELECT PropertyAddress
FROM [Portfolio project]..housing
WHERE PropertyAddress IS NULL;

SELECT COUNT(*)
FROM [Portfolio project]..housing;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio project]..housing a
JOIN [Portfolio project]..housing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio project]..housing a
JOIN [Portfolio project]..housing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;


--Splitting PropertyAddress column into Address, city, state
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
FROM [Portfolio project]..housing;

ALTER TABLE [Portfolio project]..housing
ADD PropertySplitAddress Nvarchar(255)

UPDATE [Portfolio project]..housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1);

ALTER TABLE [Portfolio project]..housing
ADD PropertySplitCity Nvarchar(255)

UPDATE [Portfolio project]..housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress));

SELECT * 
FROM [Portfolio project]..housing;

--Splitting OwnerAddress column into Address, city, state
SELECT 
PARSENAME(Replace(OwnerAddress, ',', '.'),3),
PARSENAME(Replace(OwnerAddress, ',', '.'),2),
PARSENAME(Replace(OwnerAddress, ',', '.'),1)
FROM [Portfolio project]..housing;

ALTER TABLE [Portfolio project]..housing
ADD OwnerSplitAddress VARCHAR(255)

UPDATE [Portfolio project]..housing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'),3);

ALTER TABLE [Portfolio project]..housing
ADD OwnerSplitCity VARCHAR(255)

UPDATE [Portfolio project]..housing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'),2);

ALTER TABLE [Portfolio project]..housing
ADD OwnerSplitState VARCHAR(255)

UPDATE [Portfolio project]..housing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'),1);

SELECT count(*) 
FROM [Portfolio project]..housing;

---Change Y and N as Yes and No

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Portfolio project]..housing
GROUP BY SoldAsVacant
ORDER BY 2;


SELECT SoldAsVacant,
CASE WHEN  SoldAsVacant = 'Y' THEN 'Yes'
     WHEN  SoldAsVacant = 'N' THEN 'No'
	 ELSE  SoldAsVacant
	 END
FROM [Portfolio project]..housing;

UPDATE [Portfolio project]..housing
SET SoldAsVacant = CASE WHEN  SoldAsVacant = 'Y' THEN 'Yes'
     WHEN  SoldAsVacant = 'N' THEN 'No'
	 ELSE  SoldAsVacant
	 END;

---Remove duplicates
WITH RowNumCTE AS (
SELECT *,
ROW_NUMBER () OVER (
Partition by ParcelID,
PropertyAddress, 
SalePrice,
SaleDate,
LegalReference
ORDER BY 
 UniqueID 
) row_num
FROM [Portfolio project]..housing
)



DELETE
FROM RowNumCTE
WHERE row_num > 1

SELECT *
FROM RowNumCTE
WHERE row_num > 1

--Delete unused columns
SELECT * 
FROM [Portfolio project]..housing;

ALTER TABLE [Portfolio project]..housing
DROP COLUMN PropertyAddress, SaleDate, TaxDistrict, OwnerAddress