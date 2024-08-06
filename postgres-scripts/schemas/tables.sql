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


--Updated Audit Tables

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




