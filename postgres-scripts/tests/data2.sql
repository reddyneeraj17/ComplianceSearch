ALTER SEQUENCE industry_industryid_seq RESTART WITH 1;
ALTER SEQUENCE sector_sectorid_seq RESTART WITH 1;
ALTER SEQUENCE country_countryid_seq RESTART WITH 1;
ALTER SEQUENCE region_regionid_seq RESTART WITH 1;
ALTER SEQUENCE company_companyid_seq RESTART WITH 1;
ALTER SEQUENCE compliance_rules_ruleid_seq RESTART WITH 1;


INSERT INTO INDUSTRY (industryName, created_by, updated_by) VALUES 
('Oil & Gas', 'admin', 'admin');

-- Reset and Insert sectors related to Oil & Gas
INSERT INTO SECTOR (sectorName, industryId, created_by, updated_by) VALUES 
('Upstream', 1, 'admin', 'admin'),
('Midstream', 1, 'admin', 'admin'),
('Downstream', 1, 'admin', 'admin'),
('Refining', 1, 'admin', 'admin'),
('Logistics', 1, 'admin', 'admin');


-- Reset and Insert major oil & gas producing countries
INSERT INTO COUNTRY (countryName, created_by, updated_by) VALUES 
('USA', 'admin', 'admin'),
('Saudi Arabia', 'admin', 'admin'),
('Russia', 'admin', 'admin'),
('Canada', 'admin', 'admin'),
('UAE', 'admin', 'admin');

-- Reset and Insert regions for oil & gas production and logistics
INSERT INTO REGION (regionName, countryId, created_by, updated_by) VALUES 
('Texas', 1, 'admin', 'admin'),
('Alberta', 4, 'admin', 'admin'),
('Eastern Province', 2, 'admin', 'admin'),
('Western Siberia', 3, 'admin', 'admin'),
('Abu Dhabi', 5, 'admin', 'admin');

-- Reset and Insert Oil & Gas companies including Enterprise Products
INSERT INTO COMPANY (companyName, industryId, sectorId, regionId, zipCode, created_by, updated_by) VALUES 
('ExxonMobil', 1, 1, 1, '77001', 'admin', 'admin'),
('Saudi Aramco', 1, 1, 3, '31952', 'admin', 'admin'),
('Gazprom', 1, 2, 4, '630000', 'admin', 'admin'),
('Enterprise Products', 1, 2, 1, '77002', 'admin', 'admin'),  -- Midstream company
('ADNOC', 1, 3, 5, '51133', 'admin', 'admin'),
('Shell', 1, 5, 1, '77003', 'admin', 'admin');

-- Reset and Insert compliance rules for oil & gas sectors
INSERT INTO COMPLIANCE_RULES (ruleDescription, industryId, sectorId, countryId, regionId, ruleType, effectiveDate, effectiveEndDate, created_by, updated_by) VALUES 
('Emissions Regulations for Upstream Activities', 1, 1, 1, 1, 'Environmental', '2023-01-01', '2024-01-01', 'admin', 'admin'),
('Pipeline Safety Standards', 1, 2, 1, 1, 'Safety', '2023-01-01', '2025-01-01', 'admin', 'admin'),
('Downstream Refining Emissions', 1, 3, 3, 3, 'Environmental', '2023-02-01', '2025-01-01', 'admin', 'admin'),
('Midstream Oil Transportation Compliance', 1, 2, 1, 1, 'Logistics', '2023-05-01', '2024-05-01', 'admin', 'admin'),  -- For Enterprise Products
('Flare Gas Emission Reductions', 1, 1, 2, 1, 'Environmental', '2023-03-01', '2025-03-01', 'admin', 'admin');









-- Thank you for the clarification! Since **Enterprise Products** is a midstream oil and gas company, we'll integrate it into the **Oil & Gas** industry and treat it as a company under the **Midstream** sector. Here's the updated dataset and relevant queries.

-- ### Step 1: Reset Auto-Increment IDs

-- ```sql
-- -- Reset sequence for primary key auto-increment IDs
-- ALTER SEQUENCE industry_industryid_seq RESTART WITH 1;
-- ALTER SEQUENCE sector_sectorid_seq RESTART WITH 1;
-- ALTER SEQUENCE country_countryid_seq RESTART WITH 1;
-- ALTER SEQUENCE region_regionid_seq RESTART WITH 1;
-- ALTER SEQUENCE company_companyid_seq RESTART WITH 1;
-- ALTER SEQUENCE compliance_rules_ruleid_seq RESTART WITH 1;
-- ```

-- ### Step 2: Expanded Data for Oil & Gas Industry

-- #### `INDUSTRY` Table:
-- We’re using the **Oil & Gas** industry.

-- ```sql
-- -- Reset and Insert data into INDUSTRY focused on Oil & Gas
-- INSERT INTO INDUSTRY (industryName, created_by, updated_by) VALUES 
-- ('Oil & Gas', 'admin', 'admin');
-- ```

-- #### `SECTOR` Table:
-- Define sectors for the Oil & Gas industry, including midstream.

-- ```sql
-- -- Reset and Insert sectors related to Oil & Gas
-- INSERT INTO SECTOR (sectorName, industryId, created_by, updated_by) VALUES 
-- ('Upstream', 1, 'admin', 'admin'),
-- ('Midstream', 1, 'admin', 'admin'),
-- ('Downstream', 1, 'admin', 'admin'),
-- ('Refining', 1, 'admin', 'admin'),
-- ('Logistics', 1, 'admin', 'admin');
-- ```

-- #### `COUNTRY` Table:
-- Countries that are major oil producers.

-- ```sql
-- -- Reset and Insert major oil & gas producing countries
-- INSERT INTO COUNTRY (countryName, created_by, updated_by) VALUES 
-- ('USA', 'admin', 'admin'),
-- ('Saudi Arabia', 'admin', 'admin'),
-- ('Russia', 'admin', 'admin'),
-- ('Canada', 'admin', 'admin'),
-- ('UAE', 'admin', 'admin');
-- ```

-- #### `REGION` Table:
-- Regions significant to oil & gas production and logistics.

-- ```sql
-- -- Reset and Insert regions for oil & gas production and logistics
-- INSERT INTO REGION (regionName, countryId, created_by, updated_by) VALUES 
-- ('Texas', 1, 'admin', 'admin'),
-- ('Alberta', 4, 'admin', 'admin'),
-- ('Eastern Province', 2, 'admin', 'admin'),
-- ('Western Siberia', 3, 'admin', 'admin'),
-- ('Abu Dhabi', 5, 'admin', 'admin');
-- ```

-- #### `COMPANY` Table:
-- Add **Enterprise Products** and other oil and gas companies.

-- ```sql
-- -- Reset and Insert Oil & Gas companies including Enterprise Products
-- INSERT INTO COMPANY (companyName, industryId, sectorId, regionId, zipCode, created_by, updated_by) VALUES 
-- ('ExxonMobil', 1, 1, 1, '77001', 'admin', 'admin'),
-- ('Saudi Aramco', 1, 1, 3, '31952', 'admin', 'admin'),
-- ('Gazprom', 1, 2, 4, '630000', 'admin', 'admin'),
-- ('Enterprise Products', 1, 2, 1, '77002', 'admin', 'admin'),  -- Midstream company
-- ('ADNOC', 1, 3, 5, '51133', 'admin', 'admin'),
-- ('Shell', 1, 5, 1, '77003', 'admin', 'admin');
-- ```

-- #### `COMPLIANCE_RULES` Table:
-- Add compliance rules for the Oil & Gas sector, including midstream-specific rules that apply to **Enterprise Products**.

-- ```sql
-- -- Reset and Insert compliance rules for oil & gas sectors
-- INSERT INTO COMPLIANCE_RULES (ruleDescription, industryId, sectorId, countryId, regionId, ruleType, effectiveDate, effectiveEndDate, created_by, updated_by) VALUES 
-- ('Emissions Regulations for Upstream Activities', 1, 1, 1, 1, 'Environmental', '2023-01-01', '2024-01-01', 'admin', 'admin'),
-- ('Pipeline Safety Standards', 1, 2, 1, 1, 'Safety', '2023-01-01', '2025-01-01', 'admin', 'admin'),
-- ('Downstream Refining Emissions', 1, 3, 3, 3, 'Environmental', '2023-02-01', '2025-01-01', 'admin', 'admin'),
-- ('Midstream Oil Transportation Compliance', 1, 2, 1, 1, 'Logistics', '2023-05-01', '2024-05-01', 'admin', 'admin'),  -- For Enterprise Products
-- ('Flare Gas Emission Reductions', 1, 1, 2, 1, 'Environmental', '2023-03-01', '2025-03-01', 'admin', 'admin');
-- ```

-- ### Step 3: Query Examples for Front-End Usage

-- #### 1. **Query All Compliance Rules for a Specific Company (e.g., Enterprise Products):**
-- This query will retrieve all compliance rules that apply to a specific company, such as **Enterprise Products**.

-- ```sql
-- SELECT 
--     c.companyName, 
--     cr.ruleDescription, 
--     cr.ruleType, 
--     cr.effectiveDate, 
--     cr.effectiveEndDate
-- FROM 
--     COMPANY c
-- JOIN 
--     COMPLIANCE_RULES cr ON c.industryId = cr.industryId AND c.sectorId = cr.sectorId
-- WHERE 
--     c.companyName = 'Enterprise Products';  -- Replace with any company name
-- ```

-- #### 2. **Query Compliance Rules by Sector (e.g., Midstream):**
-- This query will show all companies in a specific sector and their associated compliance rules.

-- ```sql
-- SELECT 
--     c.companyName, 
--     s.sectorName, 
--     cr.ruleDescription, 
--     cr.ruleType, 
--     cr.effectiveDate, 
--     cr.effectiveEndDate
-- FROM 
--     COMPANY c
-- JOIN 
--     SECTOR s ON c.sectorId = s.sectorId
-- JOIN 
--     COMPLIANCE_RULES cr ON c.industryId = cr.industryId AND c.sectorId = cr.sectorId
-- WHERE 
--     s.sectorName = 'Midstream';  -- Replace with the desired sector
-- ```

-- #### 3. **Query Compliance Rules Expiring Soon:**
-- This query will show rules that are about to expire in the next 30 days, including those for **Enterprise Products**.

-- ```sql
-- SELECT 
--     c.companyName, 
--     cr.ruleDescription, 
--     cr.effectiveEndDate
-- FROM 
--     COMPANY c
-- JOIN 
--     COMPLIANCE_RULES cr ON c.industryId = cr.industryId AND c.sectorId = cr.sectorId
-- WHERE 
--     cr.effectiveEndDate <= NOW() + INTERVAL '30 days';
-- ```

-- #### 4. **Query Compliance Rules by Region (e.g., Texas):**
-- This query will list all companies and their compliance rules for a specific region, like Texas.

-- ```sql
-- SELECT 
--     c.companyName, 
--     r.regionName, 
--     cr.ruleDescription, 
--     cr.ruleType, 
--     cr.effectiveDate, 
--     cr.effectiveEndDate
-- FROM 
--     COMPANY c
-- JOIN 
--     REGION r ON c.regionId = r.regionId
-- JOIN 
--     COMPLIANCE_RULES cr ON c.industryId = cr.industryId AND c.sectorId = cr.sectorId
-- WHERE 
--     r.regionName = 'Texas';  -- Replace with the desired region
-- ```

-- ### Step 4: Potential Views for Data Analysis

-- - **View for Compliance Rules by Sector**:
-- ```sql
-- CREATE VIEW compliance_rules_by_sector AS
-- SELECT 
--     s.sectorName, 
--     cr.ruleDescription, 
--     cr.ruleType, 
--     cr.effectiveDate, 
--     cr.effectiveEndDate
-- FROM 
--     SECTOR s
-- JOIN 
--     COMPLIANCE_RULES cr ON s.sectorId = cr.sectorId;
-- ```

-- - **View for Companies and Compliance Rules**:
-- ```sql
-- CREATE VIEW company_compliance_rules AS
-- SELECT 
--     c.companyName, 
--     cr.ruleDescription, 
--     cr.ruleType, 
--     cr.effectiveDate, 
--     cr.effectiveEndDate
-- FROM 
--     COMPANY c
-- JOIN 
--     COMPLIANCE_RULES cr ON c.industryId = cr.industryId AND c.sectorId = cr.sectorId;
-- ```

-- ### Summary

-- This setup integrates **Enterprise Products** as a **midstream oil & gas company**, alongside other oil and gas companies. It provides compliance rules specific to midstream operations and the oil and gas industry as a whole, along with query examples and views that can be used in a front-end application for querying data. Let me know if you need further expansion or additional queries!