-- Replace 'â€”' misencoding with the appropriate character
UPDATE stg_company_data
SET industry = REPLACE(industry, 'â€"', '—')  -- Correcting the common encoding issue
WHERE industry LIKE '%â€%';

select * from stg_company_data WHERE industry LIKE '%â€%';



INSERT INTO INDUSTRY (industryName, created_by, updated_by)
SELECT DISTINCT industry AS industryName, 'nreddy' AS created_by, 'nreddy' AS updated_by
FROM stg_company_data
WHERE industry IS NOT NULL;


INSERT INTO SECTOR (sectorName, industryId, created_by, updated_by)
SELECT DISTINCT cd.sector AS sectorName, i.industryId, 'nreddy' AS created_by, 'nreddy' AS updated_by
FROM stg_company_data cd
JOIN INDUSTRY i ON cd.industry = i.industryName
WHERE cd.sector IS NOT NULL;

INSERT INTO COUNTRY (countryName, created_by, updated_by)
SELECT DISTINCT country AS countryName, 'nreddy' AS created_by, 'nreddy' AS updated_by
FROM stg_company_data
WHERE country IS NOT NULL;

INSERT INTO REGION (regionName, countryId, created_by, updated_by)
SELECT DISTINCT cd.region AS regionName, c.countryId, 'nreddy' AS created_by, 'nreddy' AS updated_by
FROM stg_company_data cd
JOIN COUNTRY c ON cd.country = c.countryName
WHERE cd.region IS NOT NULL;

INSERT INTO COMPANY (companyName, industryId, sectorId, regionId, zipCode, created_by, updated_by)
SELECT cd."company_name" AS companyName, 
       i.industryId, 
       s.sectorId, 
       r.regionId, 
       cd."zip_code" AS zipCode, 
       'nreddy' AS created_by, 
       'nreddy' AS updated_by
FROM stg_company_data cd
JOIN INDUSTRY i ON cd."industry" = i.industryName
JOIN SECTOR s ON cd."sector" = s.sectorName AND s.industryId = i.industryId
JOIN REGION r ON cd."region" = r.regionName
WHERE cd."company_name" IS NOT NULL;


INSERT INTO COMPLIANCE_RULES (
    ruleDescription, 
    companyId,
    industryId, 
    sectorId, 
    countryId, 
    regionId, 
    ruleType, 
    effectiveDate, 
    effectiveEndDate, 
    created_by, 
    updated_by
)
SELECT 
    TRIM(sc.compliance_details) AS ruleDescription,               -- Use regulation from stg_compliance_data
    c.companyId,                                                -- Include companyId
    c.industryId,                                               -- Get industryId from the COMPANY table
    c.sectorId,                                                 -- Get sectorId from the COMPANY table
    r.countryId,                                                -- Get countryId from the REGION table
    r.regionId,                                                 -- Get regionId from the REGION table
    TRIM(sc.compliance_type) AS ruleType,                       -- Use compliance_type from stg_compliance_data
    CURRENT_TIMESTAMP AS effectiveDate,                         -- Set effectiveDate to current timestamp
    NULL AS effectiveEndDate,                                   -- Leave effectiveEndDate as NULL
    'nreddy' AS created_by,                                     -- Set created_by to 'nreddy'
    'nreddy' AS updated_by                                      -- Set updated_by to 'nreddy'
FROM stg_compliance_data sc
JOIN COMPANY c ON sc.company = c.companyName                    -- Join on company name
JOIN REGION r ON c.regionId = r.regionId                        -- Join to get countryId and regionId from REGION table
WHERE sc.compliance_details IS NOT NULL;

