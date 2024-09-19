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
CREATE OR REPLACE FUNCTION log_compliance_rules_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO COMPLIANCE_RULES_AUDIT (
            ruleId, ruleDescription, companyId, industryId, sectorId, countryId, regionId, 
            ruleType, effectiveDate, effectiveEndDate, operation, changed_by
        )
        VALUES (
            NEW.ruleId, NEW.ruleDescription, NEW.companyId, NEW.industryId, NEW.sectorId, 
            NEW.countryId, NEW.regionId, NEW.ruleType, NEW.effectiveDate, NEW.effectiveEndDate, 
            'INSERT', NEW.created_by
        );
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO COMPLIANCE_RULES_AUDIT (
            ruleId, ruleDescription, companyId, industryId, sectorId, countryId, regionId, 
            ruleType, effectiveDate, effectiveEndDate, operation, changed_by
        )
        VALUES (
            NEW.ruleId, NEW.ruleDescription, NEW.companyId, NEW.industryId, NEW.sectorId, 
            NEW.countryId, NEW.regionId, NEW.ruleType, NEW.effectiveDate, NEW.effectiveEndDate, 
            'UPDATE', NEW.updated_by
        );
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO COMPLIANCE_RULES_AUDIT (
            ruleId, ruleDescription, companyId, industryId, sectorId, countryId, regionId, 
            ruleType, effectiveDate, effectiveEndDate, operation, changed_by
        )
        VALUES (
            OLD.ruleId, OLD.ruleDescription, OLD.companyId, OLD.industryId, OLD.sectorId, 
            OLD.countryId, OLD.regionId, OLD.ruleType, OLD.effectiveDate, OLD.effectiveEndDate, 
            'DELETE', OLD.updated_by
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
