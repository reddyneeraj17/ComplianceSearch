--Search Compliance Rules by Company Name
SELECT 
    cr.ruleId, 
    cr.ruleDescription, 
    cr.ruleType, 
    cr.effectiveDate, 
    cr.effectiveEndDate,
    c.companyName, 
    i.industryName, 
    s.sectorName, 
    r.regionName, 
    ct.countryName
FROM COMPLIANCE_RULES cr
JOIN COMPANY c ON cr.companyId = c.companyId
JOIN INDUSTRY i ON c.industryId = i.industryId
JOIN SECTOR s ON c.sectorId = s.sectorId
JOIN REGION r ON c.regionId = r.regionId
JOIN COUNTRY ct ON r.countryId = ct.countryId
WHERE c.companyName = 'Exxon Mobil Corporation';  -- Filter by company name

---Search Compliance Rules by Rule Type
SELECT 
    cr.ruleId, 
    cr.ruleDescription, 
    cr.ruleType, 
    cr.effectiveDate, 
    cr.effectiveEndDate,
    c.companyName, 
    i.industryName, 
    s.sectorName, 
    r.regionName, 
    ct.countryName
FROM COMPLIANCE_RULES cr
JOIN COMPANY c ON cr.companyId = c.companyId
JOIN INDUSTRY i ON c.industryId = i.industryId
JOIN SECTOR s ON c.sectorId = s.sectorId
JOIN REGION r ON c.regionId = r.regionId
JOIN COUNTRY ct ON r.countryId = ct.countryId
WHERE cr.ruleType = 'Environmental Protection';  -- Filter by rule type

---Search Compliance Rules by Industry and Sector
SELECT 
    cr.ruleId, 
    cr.ruleDescription, 
    cr.ruleType, 
    cr.effectiveDate, 
    cr.effectiveEndDate,
    c.companyName, 
    i.industryName, 
    s.sectorName, 
    r.regionName, 
    ct.countryName
FROM COMPLIANCE_RULES cr
JOIN COMPANY c ON cr.companyId = c.companyId
JOIN INDUSTRY i ON c.industryId = i.industryId
JOIN SECTOR s ON c.sectorId = s.sectorId
JOIN REGION r ON c.regionId = r.regionId
JOIN COUNTRY ct ON r.countryId = ct.countryId
WHERE i.industryName = 'Oil and Gas'  -- Filter by industry
AND s.sectorName = 'Upstream';        -- Filter by sector

--Search Compliance Rules by Region and Country
SELECT 
    cr.ruleId, 
    cr.ruleDescription, 
    cr.ruleType, 
    cr.effectiveDate, 
    cr.effectiveEndDate,
    c.companyName, 
    i.industryName, 
    s.sectorName, 
    r.regionName, 
    ct.countryName
FROM COMPLIANCE_RULES cr
JOIN COMPANY c ON cr.companyId = c.companyId
JOIN INDUSTRY i ON c.industryId = i.industryId
JOIN SECTOR s ON c.sectorId = s.sectorId
JOIN REGION r ON c.regionId = r.regionId
JOIN COUNTRY ct ON r.countryId = ct.countryId
WHERE r.regionName = 'Texas'         -- Filter by region
AND ct.countryName = 'United States';  -- Filter by country

--Search Compliance Rules by Date Range
SELECT 
    cr.ruleId, 
    cr.ruleDescription, 
    cr.ruleType, 
    cr.effectiveDate, 
    cr.effectiveEndDate,
    c.companyName, 
    i.industryName, 
    s.sectorName, 
    r.regionName, 
    ct.countryName
FROM COMPLIANCE_RULES cr
JOIN COMPANY c ON cr.companyId = c.companyId
JOIN INDUSTRY i ON c.industryId = i.industryId
JOIN SECTOR s ON c.sectorId = s.sectorId
JOIN REGION r ON c.regionId = r.regionId
JOIN COUNTRY ct ON r.countryId = ct.countryId
WHERE cr.effectiveDate BETWEEN '2023-01-01' AND '2023-12-31';  -- Filter by date range

--Search for the Latest Compliance Rule for a Specific Company
SELECT 
    cr.ruleId, 
    cr.ruleDescription, 
    cr.ruleType, 
    cr.effectiveDate, 
    cr.effectiveEndDate,
    c.companyName
FROM COMPLIANCE_RULES cr
JOIN COMPANY c ON cr.companyId = c.companyId
WHERE c.companyName = 'Chevron Corporation'  -- Replace with company name
ORDER BY cr.effectiveDate DESC
LIMIT 1;  -- Retrieve the latest rule

--Search for Rules with Upcoming Expiry
SELECT 
    cr.ruleId, 
    cr.ruleDescription, 
    cr.ruleType, 
    cr.effectiveDate, 
    cr.effectiveEndDate,
    c.companyName, 
    i.industryName, 
    s.sectorName, 
    r.regionName, 
    ct.countryName
FROM COMPLIANCE_RULES cr
JOIN COMPANY c ON cr.companyId = c.companyId
JOIN INDUSTRY i ON c.industryId = i.industryId
JOIN SECTOR s ON c.sectorId = s.sectorId
JOIN REGION r ON c.regionId = r.regionId
JOIN COUNTRY ct ON r.countryId = ct.countryId
WHERE cr.effectiveEndDate BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days';  -- Expiring in next 30 days


---Dynamic Query Using Parameters:
SELECT 
    cr.ruleId, 
    cr.ruleDescription, 
    cr.ruleType, 
    cr.effectiveDate, 
    cr.effectiveEndDate,
    c.companyName, 
    i.industryName, 
    s.sectorName, 
    r.regionName, 
    ct.countryName
FROM COMPLIANCE_RULES cr
JOIN COMPANY c ON cr.companyId = c.companyId
JOIN INDUSTRY i ON c.industryId = i.industryId
JOIN SECTOR s ON c.sectorId = s.sectorId
JOIN REGION r ON c.regionId = r.regionId
JOIN COUNTRY ct ON r.countryId = ct.countryId
WHERE (c.companyName = :companyName OR :companyName IS NULL)
AND (i.industryName = :industryName OR :industryName IS NULL)
AND (s.sectorName = :sectorName OR :sectorName IS NULL)
AND (r.regionName = :regionName OR :regionName IS NULL)
AND (ct.countryName = :countryName OR :countryName IS NULL)
AND (cr.ruleType = :ruleType OR :ruleType IS NULL)
AND (cr.effectiveDate BETWEEN :startDate AND :endDate OR (:startDate IS NULL AND :endDate IS NULL));
