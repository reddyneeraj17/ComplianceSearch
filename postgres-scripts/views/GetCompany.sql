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
