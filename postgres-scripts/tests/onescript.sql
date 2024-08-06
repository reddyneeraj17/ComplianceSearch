
-- Drop triggers first since they depend on the tables
DROP TRIGGER IF EXISTS industry_changes ON INDUSTRY;
DROP TRIGGER IF EXISTS sector_changes ON SECTOR;
DROP TRIGGER IF EXISTS country_changes ON COUNTRY;
DROP TRIGGER IF EXISTS region_changes ON REGION;
DROP TRIGGER IF EXISTS company_changes ON COMPANY;
DROP TRIGGER IF EXISTS compliance_rules_changes ON COMPLIANCE_RULES;

-- Drop functions for audit logging
DROP FUNCTION IF EXISTS log_industry_changes();
DROP FUNCTION IF EXISTS log_sector_changes();
DROP FUNCTION IF EXISTS log_country_changes();
DROP FUNCTION IF EXISTS log_region_changes();
DROP FUNCTION IF EXISTS log_company_changes();
DROP FUNCTION IF EXISTS log_compliance_rules_changes();

-- Drop primary tables
DROP TABLE IF EXISTS INDUSTRY CASCADE;
DROP TABLE IF EXISTS SECTOR CASCADE;
DROP TABLE IF EXISTS COUNTRY CASCADE;
DROP TABLE IF EXISTS REGION CASCADE;
DROP TABLE IF EXISTS COMPANY CASCADE;
DROP TABLE IF EXISTS COMPLIANCE_RULES CASCADE;

-- Drop audit tables
DROP TABLE IF EXISTS INDUSTRY_AUDIT CASCADE;
DROP TABLE IF EXISTS SECTOR_AUDIT CASCADE;
DROP TABLE IF EXISTS COUNTRY_AUDIT CASCADE;
DROP TABLE IF EXISTS REGION_AUDIT CASCADE;
DROP TABLE IF EXISTS COMPANY_AUDIT CASCADE;
DROP TABLE IF EXISTS COMPLIANCE_RULES_AUDIT CASCADE;


-- ***********************************************************************************************************************************************************************************

-- Primary Tables

-- Industry Table
CREATE TABLE INDUSTRY (
    industryId SERIAL PRIMARY KEY,
    industryName VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100)
);

-- Sector Table (New)
CREATE TABLE SECTOR (
    sectorId SERIAL PRIMARY KEY,
    sectorName VARCHAR(100) NOT NULL,
    industryId INT REFERENCES INDUSTRY(industryId),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100)
);

-- Country Table
CREATE TABLE COUNTRY (
    countryId SERIAL PRIMARY KEY,
    countryName VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100)
);

-- Region Table
CREATE TABLE REGION (
    regionId SERIAL PRIMARY KEY,
    regionName VARCHAR(100) NOT NULL,
    countryId INT REFERENCES COUNTRY(countryId),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100)
);

-- Company Table
CREATE TABLE COMPANY (
    companyId SERIAL PRIMARY KEY,
    companyName VARCHAR(100) NOT NULL,
    industryId INT REFERENCES INDUSTRY(industryId),
    sectorId INT REFERENCES SECTOR(sectorId),
    regionId INT REFERENCES REGION(regionId),
    zipCode VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100)
);

-- Compliance Rules Table
CREATE TABLE COMPLIANCE_RULES (
    ruleId SERIAL PRIMARY KEY,
    ruleDescription VARCHAR(255) NOT NULL,
    industryId INT REFERENCES INDUSTRY(industryId),
    sectorId INT REFERENCES SECTOR(sectorId),
    countryId INT REFERENCES COUNTRY(countryId),
    regionId INT REFERENCES REGION(regionId),
    ruleType VARCHAR(50),
    effectiveDate TIMESTAMP,
    effectiveEndDate TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100)
);


-- Audit Tables

-- Industry Audit Table
CREATE TABLE INDUSTRY_AUDIT (
    auditId SERIAL PRIMARY KEY,
    industryId INT,
    industryName VARCHAR(100),
    operation VARCHAR(10), -- INSERT, UPDATE, DELETE
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(100)
);

-- Sector Audit Table (New)
CREATE TABLE SECTOR_AUDIT (
    auditId SERIAL PRIMARY KEY,
    sectorId INT,
    sectorName VARCHAR(100),
    industryId INT,
    operation VARCHAR(10), -- INSERT, UPDATE, DELETE
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(100)
);

-- Country Audit Table
CREATE TABLE COUNTRY_AUDIT (
    auditId SERIAL PRIMARY KEY,
    countryId INT,
    countryName VARCHAR(100),
    operation VARCHAR(10), -- INSERT, UPDATE, DELETE
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(100)
);

-- Region Audit Table
CREATE TABLE REGION_AUDIT (
    auditId SERIAL PRIMARY KEY,
    regionId INT,
    regionName VARCHAR(100),
    countryId INT,
    operation VARCHAR(10), -- INSERT, UPDATE, DELETE
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(100)
);

-- Company Audit Table
CREATE TABLE COMPANY_AUDIT (
    auditId SERIAL PRIMARY KEY,
    companyId INT,
    companyName VARCHAR(100),
    industryId INT,
    sectorId INT,
    regionId INT,
    zipCode VARCHAR(20),
    operation VARCHAR(10), -- INSERT, UPDATE, DELETE
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(100)
);

-- Compliance Rules Audit Table
CREATE TABLE COMPLIANCE_RULES_AUDIT (
    auditId SERIAL PRIMARY KEY,
    ruleId INT,
    ruleDescription VARCHAR(255),
    industryId INT,
    sectorId INT,
    countryId INT,
    regionId INT,
    ruleType VARCHAR(50),
    effectiveDate TIMESTAMP,
    effectiveEndDate TIMESTAMP,
    operation VARCHAR(10), -- INSERT, UPDATE, DELETE
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(100)
);




-- ********************************************************************************************************************************************************************************************


-- Function for INDUSTRY table
-- Function for INDUSTRY table
CREATE FUNCTION log_industry_changes() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO industry_audit (industryId, industryName, operation, change_date, changed_by)
        VALUES (OLD.industryId, OLD.industryName, 'DELETE', NOW(), USER);
        RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO industry_audit (industryId, industryName, operation, change_date, changed_by)
        VALUES (NEW.industryId, NEW.industryName, 'UPDATE', NOW(), USER);
        RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO industry_audit (industryId, industryName, operation, change_date, changed_by)
        VALUES (NEW.industryId, NEW.industryName, 'INSERT', NOW(), USER);
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Function for SECTOR table
CREATE FUNCTION log_sector_changes() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO sector_audit (sectorId, sectorName, industryId, operation, change_date, changed_by)
        VALUES (OLD.sectorId, OLD.sectorName, OLD.industryId, 'DELETE', NOW(), USER);
        RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO sector_audit (sectorId, sectorName, industryId, operation, change_date, changed_by)
        VALUES (NEW.sectorId, NEW.sectorName, NEW.industryId, 'UPDATE', NOW(), USER);
        RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO sector_audit (sectorId, sectorName, industryId, operation, change_date, changed_by)
        VALUES (NEW.sectorId, NEW.sectorName, NEW.industryId, 'INSERT', NOW(), USER);
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Function for COUNTRY table
CREATE FUNCTION log_country_changes() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO country_audit (countryId, countryName, operation, change_date, changed_by)
        VALUES (OLD.countryId, OLD.countryName, 'DELETE', NOW(), USER);
        RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO country_audit (countryId, countryName, operation, change_date, changed_by)
        VALUES (NEW.countryId, NEW.countryName, 'UPDATE', NOW(), USER);
        RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO country_audit (countryId, countryName, operation, change_date, changed_by)
        VALUES (NEW.countryId, NEW.countryName, 'INSERT', NOW(), USER);
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Function for REGION table
CREATE FUNCTION log_region_changes() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO region_audit (regionId, regionName, countryId, operation, change_date, changed_by)
        VALUES (OLD.regionId, OLD.regionName, OLD.countryId, 'DELETE', NOW(), USER);
        RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO region_audit (regionId, regionName, countryId, operation, change_date, changed_by)
        VALUES (NEW.regionId, NEW.regionName, NEW.countryId, 'UPDATE', NOW(), USER);
        RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO region_audit (regionId, regionName, countryId, operation, change_date, changed_by)
        VALUES (NEW.regionId, NEW.regionName, NEW.countryId, 'INSERT', NOW(), USER);
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Function for COMPANY table
CREATE FUNCTION log_company_changes() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO company_audit (companyId, companyName, industryId, sectorId, regionId, zipCode, operation, change_date, changed_by)
        VALUES (OLD.companyId, OLD.companyName, OLD.industryId, OLD.sectorId, OLD.regionId, OLD.zipCode, 'DELETE', NOW(), USER);
        RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO company_audit (companyId, companyName, industryId, sectorId, regionId, zipCode, operation, change_date, changed_by)
        VALUES (NEW.companyId, NEW.companyName, NEW.industryId, NEW.sectorId, NEW.regionId, NEW.zipCode, 'UPDATE', NOW(), USER);
        RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO company_audit (companyId, companyName, industryId, sectorId, regionId, zipCode, operation, change_date, changed_by)
        VALUES (NEW.companyId, NEW.companyName, NEW.industryId, NEW.sectorId, NEW.regionId, NEW.zipCode, 'INSERT', NOW(), USER);
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Function for COMPLIANCE_RULES table
CREATE FUNCTION log_compliance_rules_changes() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO compliance_rules_audit (ruleId, ruleDescription, industryId, sectorId, countryId, regionId, ruleType, effectiveDate, effectiveEndDate, operation, change_date, changed_by)
        VALUES (OLD.ruleId, OLD.ruleDescription, OLD.industryId, OLD.sectorId, OLD.countryId, OLD.regionId, OLD.ruleType, OLD.effectiveDate, OLD.effectiveEndDate, 'DELETE', NOW(), USER);
        RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO compliance_rules_audit (ruleId, ruleDescription, industryId, sectorId, countryId, regionId, ruleType, effectiveDate, effectiveEndDate, operation, change_date, changed_by)
        VALUES (NEW.ruleId, NEW.ruleDescription, NEW.industryId, NEW.sectorId, NEW.countryId, NEW.regionId, NEW.ruleType, NEW.effectiveDate, NEW.effectiveEndDate, 'UPDATE', NOW(), USER);
        RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO compliance_rules_audit (ruleId, ruleDescription, industryId, sectorId, countryId, regionId, ruleType, effectiveDate, effectiveEndDate, operation, change_date, changed_by)
        VALUES (NEW.ruleId, NEW.ruleDescription, NEW.industryId, NEW.sectorId, NEW.countryId, NEW.regionId, NEW.ruleType, NEW.effectiveDate, NEW.effectiveEndDate, 'INSERT', NOW(), USER);
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;




-- ********************************************************************************************************************************************************************************************

---Create Trigger Functions and Triggers


-- Trigger for INDUSTRY table
CREATE TRIGGER industry_changes
AFTER INSERT OR UPDATE OR DELETE ON INDUSTRY
FOR EACH ROW EXECUTE FUNCTION log_industry_changes();

-- Trigger for SECTOR table
CREATE TRIGGER sector_changes
AFTER INSERT OR UPDATE OR DELETE ON SECTOR
FOR EACH ROW EXECUTE FUNCTION log_sector_changes();

-- Trigger for COUNTRY table
CREATE TRIGGER country_changes
AFTER INSERT OR UPDATE OR DELETE ON COUNTRY
FOR EACH ROW EXECUTE FUNCTION log_country_changes();

-- Trigger for REGION table
CREATE TRIGGER region_changes
AFTER INSERT OR UPDATE OR DELETE ON REGION
FOR EACH ROW EXECUTE FUNCTION log_region_changes();

-- Trigger for COMPANY table
CREATE TRIGGER company_changes
AFTER INSERT OR UPDATE OR DELETE ON COMPANY
FOR EACH ROW EXECUTE FUNCTION log_company_changes();

-- Trigger for COMPLIANCE_RULES table
CREATE TRIGGER compliance_rules_changes
AFTER INSERT OR UPDATE OR DELETE ON COMPLIANCE_RULES
FOR EACH ROW EXECUTE FUNCTION log_compliance_rules_changes();



-- ********************************************************************************************************************************************************************************************


-- Insert dummy data into INDUSTRY
-- Insert dummy data into INDUSTRY
INSERT INTO INDUSTRY (industryName, created_by, updated_by) VALUES 
('Energy', 'admin', 'admin'), 
('Technology', 'admin', 'admin'), 
('Healthcare', 'admin', 'admin');

-- Insert dummy data into SECTOR
INSERT INTO SECTOR (sectorName, industryId, created_by, updated_by) VALUES 
('Oil & Gas', 1, 'admin', 'admin'), 
('Software', 2, 'admin', 'admin'), 
('Pharmaceuticals', 3, 'admin', 'admin');

-- Insert dummy data into COUNTRY
INSERT INTO COUNTRY (countryName, created_by, updated_by) VALUES 
('USA', 'admin', 'admin'), 
('Canada', 'admin', 'admin'), 
('Germany', 'admin', 'admin');

-- Insert dummy data into REGION
INSERT INTO REGION (regionName, countryId, created_by, updated_by) VALUES 
('California', 1, 'admin', 'admin'), 
('Texas', 1, 'admin', 'admin'), 
('Ontario', 2, 'admin', 'admin'), 
('Bavaria', 3, 'admin', 'admin');

-- Insert dummy data into COMPANY
INSERT INTO COMPANY (companyName, industryId, sectorId, regionId, zipCode, created_by, updated_by) VALUES 
('Company A', 1, 1, 1, '90001', 'admin', 'admin'), 
('Company B', 2, 2, 2, '73301', 'admin', 'admin'), 
('Company C', 3, 3, 3, 'M5V', 'admin', 'admin');

-- Insert dummy data into COMPLIANCE_RULES
INSERT INTO COMPLIANCE_RULES (ruleDescription, industryId, sectorId, countryId, regionId, ruleType, effectiveDate, effectiveEndDate, created_by, updated_by) VALUES 
('Rule 1', 1, 1, 1, 1, 'Type A', '2023-01-01', '2024-01-01', 'admin', 'admin'), 
('Rule 2', 2, 2, 2, 3, 'Type B', '2023-01-01', '2024-01-01', 'admin', 'admin'), 
('Rule 3', 3, 3, 3, 2, 'Type C', '2023-01-01', '2024-01-01', 'admin', 'admin');




-- ********************************************************************************************************************************************************************************************

SELECT 
    c.companyName, 
    c.zipCode, 
    cr.ruleDescription, 
    cr.ruleType, 
    cr.effectiveDate, 
    cr.effectiveEndDate
FROM 
    COMPANY c
JOIN 
    COMPLIANCE_RULES cr ON c.industryId = cr.industryId AND c.sectorId = cr.sectorId AND c.regionId = cr.regionId
WHERE 
    c.companyName = 'Company A' AND c.zipCode = '90001';




