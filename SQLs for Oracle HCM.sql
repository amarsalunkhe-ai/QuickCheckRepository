--------------------------------------------------------------------------------------------------------
-- Position Details SQL
--------------------------------------------------------------------------------------------------------


SELECT
TO_CHAR(HAPFV.EFFECTIVE_START_DATE,'YYYY/MM/DD') AS "EffectiveStartDate_HCM",
'Y' "Replace_First_EffectiveStartDate",
TO_CHAR(HAPFV.EFFECTIVE_END_DATE,'YYYY/MM/DD') AS "EffectiveEndDate_HCM",
FABUV.BU_NAME AS "BusinessUnitName_HCM",
HAPFV.POSITION_CODE AS "PositionCode_HCM",
HAPFV.NAME AS "Name_HCM",
(SELECT DISTINCT MEANING FROM HCM_LOOKUPS WHERE LOOKUP_TYPE = 'ACTIVE_INACTIVE' AND LOOKUP_CODE = HAPFV.ACTIVE_STATUS) AS "ActiveStatus_HCM",
'' ActionReasonCode,
PJF.JOB_CODE AS "JobCode_HCM",
HAOTL.NAME AS "DepartmentName_HCM",
HLAFV.INTERNAL_LOCATION_CODE AS "LocationCode_HCM",
'' AssignmentCategory,
(SELECT DISTINCT MEANING FROM HCM_LOOKUPS WHERE LOOKUP_TYPE = 'PART_FULL_TIME' AND LOOKUP_CODE = HAPFV.FULL_PART_TIME) AS "FullPartTime_HCM",
(SELECT DISTINCT MEANING FROM HCM_LOOKUPS WHERE LOOKUP_TYPE = 'REGULAR_TEMPORARY' AND LOOKUP_CODE = HAPFV.PERMANENT_TEMPORARY_FLAG) AS "RegularTemporary_HCM",
(SELECT DISTINCT MEANING FROM HCM_LOOKUPS WHERE LOOKUP_TYPE = 'HIRING_STATUS' AND LOOKUP_CODE = HAPFV.HIRING_STATUS) AS "HiringStatus_HCM",
(SELECT DISTINCT MEANING FROM HCM_LOOKUPS WHERE LOOKUP_TYPE = 'POSITION_TYPE' AND LOOKUP_CODE = HAPFV.POSITION_TYPE) AS "PositionType_HCM",
'Y' CalculateFTE,
HAPFV.FTE AS "FTE_HCM",
hapf.max_persons Headcount,
hapf.Overlap_Allowed as "OverlapAllowed",
HAPF.STANDARD_WORKING_HOURS AS "StandardWorkingHours_HCM",
(SELECT DISTINCT MEANING FROM HCM_LOOKUPS WHERE LOOKUP_TYPE = 'FREQUENCY' AND LOOKUP_CODE = HAPF.STANDARD_WORKING_FREQUENCY) AS "StandardWorkingFrequency_HCM",
HAPF.WORKING_HOURS as "WorkingHours",
(SELECT DISTINCT MEANING FROM HCM_LOOKUPS WHERE LOOKUP_TYPE = 'FREQUENCY' AND LOOKUP_CODE = HAPF.FREQUENCY) 
AS "WorkingFrequency"
FROM 
HR_ALL_POSITIONS_F_VL HAPF,
HR_ALL_POSITIONS_F_VL HAPFV,
FUN_ALL_BUSINESS_UNITS_V FABUV,
HR_ORGANIZATION_UNITS_F_TL HAOTL,
PER_JOBS_F PJF,
HR_LOCATIONS_ALL_F_VL HLAFV
WHERE HAPFV.BUSINESS_UNIT_ID = FABUV.BU_ID
and HAPF.position_id = hapfv.position_id
AND HAPFV.ORGANIZATION_ID = HAOTL.ORGANIZATION_ID
AND HAOTL.LANGUAGE = 'US'
AND HAPFV.JOB_ID = PJF.JOB_ID
AND HAPFV.LOCATION_ID = HLAFV.LOCATION_ID (+)
and trunc(sysdate) between HAPF.effective_start_date and HAPF.effective_end_date
and trunc(sysdate) between HAPFV.effective_start_date and HAPFV.effective_end_date
and trunc(sysdate) between HAOTL.effective_start_date and HAOTL.effective_end_date
and trunc(sysdate) between PJF.effective_start_date and PJF.effective_end_date
and trunc(sysdate) between HLAFV.effective_start_date and HLAFV.effective_end_date
--------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------
-- Parent Position
--------------------------------------------------------------------------------------------------------
SELECT DISTINCT
HAPF.POSITION_CODE AS "PositionCode_HCM",
(SELECT DISTINCT BU_NAME FROM FUN_ALL_BUSINESS_UNITS_V WHERE BU_ID = HAPF.BUSINESS_UNIT_ID) AS "BusinessUnitName_HCM",
TO_CHAR(PPHF.EFFECTIVE_START_DATE,'YYYY/MM/DD') AS "EffectiveStartDate_HCM",
TO_CHAR(PPHF.EFFECTIVE_END_DATE,'YYYY/MM/DD') AS "EffectiveEndDate_HCM",
HAPF1.POSITION_CODE AS "ParentPositionCode_HCM",
(SELECT DISTINCT BU_NAME FROM FUN_ALL_BUSINESS_UNITS_V WHERE BU_ID = HAPF1.BUSINESS_UNIT_ID) AS "ParentBusinessUnitCode_HCM",
PPHF.CREATED_BY AS "CreatedBy_HCM",
TO_CHAR(PPHF.CREATION_DATE,'YYYY/MM/DD') AS "CreationDate_HCM",
PPHF.LAST_UPDATED_BY AS "LastUpdatedBy_HCM",
TO_CHAR(PPHF.LAST_UPDATE_DATE,'YYYY/MM/DD') AS "LastUpdateDate_HCM",
HIKM.SOURCE_SYSTEM_ID,
HIKM.SOURCE_SYSTEM_OWNER,
HAPF.POSITION_ID
FROM PER_POSITION_HIERARCHY_F PPHF,
HR_ALL_POSITIONS_F HAPF,
HR_ALL_POSITIONS_F HAPF1,HRC_INTEGRATION_KEY_MAP HIKM
WHERE PPHF.POSITION_ID = HAPF.POSITION_ID
AND PPHF.PARENT_POSITION_ID = HAPF1.POSITION_ID
AND HIKM.OBJECT_NAME = 'PositionHierarchy'
/*
AND HIKM.SOURCE_SYSTEM_OWNER = 'HRC_SQLLOADER'
AND HIKM.SOURCE_SYSTEM_ID LIKE '%M5_%'
*/
AND PPHF.POSITION_HIERARCHY_ID= HIKM.SURROGATE_ID
----------------------------------------------------


SELECT   
HAPF.POSITION_CODE AS POSITIONCODE_HCM,
HAP.NAME AS NAME_HCM,
PPE.POEI_INFORMATION1 "Stream_HCM", 
PPE.POEI_INFORMATION2 "Career Path_HCM", 
PPE.POEI_INFORMATION3 "Role Title_HCM", 
PPE.POEI_INFORMATION4 "Discipline_HCM", 
PPE.POEI_INFORMATION5 "Slim Title_HCM", 
PPE.POEI_INFORMATION6 "Floor Details_HCM"   ,
PPE.EFFECTIVE_START_DATE as "startdate_HCM",
PPE.EFFECTIVE_end_DATE as "Enddate_HCM",
HIKM.SOURCE_SYSTEM_ID AS SOURCESYSTEMID ,
HIKM.SOURCE_SYSTEM_OWNER AS SOURCESYSTEMOWNER
FROM PER_POSITION_EXTRA_INFO_F PPE, 
HR_ALL_POSITIONS_F HAPF,
HR_ALL_POSITIONS_F_TL HAP,
HRC_INTEGRATION_KEY_MAP HIKM
WHERE PPE.POSITION_ID = HAPF.POSITION_ID
AND PPE.POSITION_ID = HAP.POSITION_ID
AND PPE.POEI_INFORMATION_CATEGORY = 'GSC India Position Details'
AND HAP.LANGUAGE = 'US'
AND TRUNC(SYSDATE) BETWEEN PPE.EFFECTIVE_START_DATE AND PPE.EFFECTIVE_END_DATE
AND TRUNC(SYSDATE) BETWEEN HAPF.EFFECTIVE_START_DATE AND HAPF.EFFECTIVE_END_DATE
AND TRUNC(SYSDATE) BETWEEN HAP.EFFECTIVE_START_DATE AND HAP.EFFECTIVE_END_DATE
--AND HIKM.OBJECT_NAME = 'PositionExtraInformation'
AND HIKM.SOURCE_SYSTEM_OWNER = 'HRC_SQLLOADER'
--AND HIKM.SOURCE_SYSTEM_ID LIKE '%M5_POS%'
AND PPE.POSITION_EXTRA_INFO_ID = HIKM.SURROGATE_ID
----------------------------------------------------
----------------------------------------------------
SELECT HAPF.POSITION_CODE as "POSITION_CODE_HCM",
HAP.NAME AS "NAME_HCM",
PPE.POEI_INFORMATION1 "BMvendor_HCM", 
PPE.POEI_INFORMATION2 "BMCode_HCM",
TO_CHAR( HAPF.EFFECTIVE_START_DATE,'DD/MM/YYYY') EFFECTIVE_START_DATE_pos,
TO_CHAR(PPE.EFFECTIVE_START_DATE,'DD/MM/YYYY') EFFECTIVE_START_DATE_pos_EXTRA,
HIKM.SOURCE_SYSTEM_ID,
HIKM.SOURCE_SYSTEM_OWNER
FROM PER_POSITION_EXTRA_INFO_F PPE, 
    HR_ALL_POSITIONS_F HAPF,
    HR_ALL_POSITIONS_F_TL HAP,
HRC_INTEGRATION_KEY_MAP HIKM
WHERE 
HIKM.OBJECT_NAME = 'PositionExtraInformation'
--AND HIKM.SOURCE_SYSTEM_OWNER = 'HRC_SQLLOADER'
--AND HIKM.SOURCE_SYSTEM_ID LIKE '%M5_%'
AND PPE.POSITION_EXTRA_INFO_ID = HIKM.SURROGATE_ID
AND PPE.POSITION_ID = HAPF.POSITION_ID
AND PPE.POSITION_ID = HAP.POSITION_ID
AND PPE.POEI_INFORMATION_CATEGORY = 'SG_Pos_Benchmarking'
AND HAP.LANGUAGE = 'US'
AND TRUNC(SYSDATE) BETWEEN PPE.EFFECTIVE_START_DATE AND PPE.EFFECTIVE_END_DATE
AND TRUNC(SYSDATE) BETWEEN HAPF.EFFECTIVE_START_DATE AND HAPF.EFFECTIVE_END_DATE
AND TRUNC(SYSDATE) BETWEEN HAP.EFFECTIVE_START_DATE AND HAP.EFFECTIVE_END_DATE
--AND  HAPF.POSITION_CODE='30014712'
----------------------------------------------------
select 'METADATA|OrganizationTreeNode|TreeStructureCode|TreeCode|TreeVersionName|OrganizationName|ClassificationCode|ReferenceTreeCode|ReferenceTreeVersionName|ParentOrganizationName|ParentClassificationCode|DeleteChildNodesFlag' AA from dual
union 
select 'MERGE|OrganizationTreeNode|PER_ORG_TREE_STRUCTURE|SG_MOCK3_ORG_TREE|SG Mock 3 Org Tree V1|SOCIETE GENERALE GROUP|ENTERPRISE|||||' from dual 
union
select 'MERGE|OrganizationTreeNode|PER_ORG_TREE_STRUCTURE|SG_MOCK3_ORG_TREE|SG Mock 3 Org Tree V1|' || haotl.name || '|DEPARTMENT|||' || fss.set_name || '|FUN_BUSINESS_UNIT|' AA
FROM
HR_ORG_UNIT_CLASSIFICATIONS_F hac,
HR_ALL_ORGANIZATION_UNITS_F hao,
HR_ORGANIZATION_UNITS_F_TL haotl,
FND_SETID_SETS FSS
WHERE hao.ORGANIZATION_ID = hac.ORGANIZATION_ID 
AND hao.ORGANIZATION_ID = haotl.ORGANIZATION_ID 
AND hao.EFFECTIVE_START_DATE BETWEEN hac.EFFECTIVE_START_DATE AND hac.EFFECTIVE_END_DATE 
AND haotl.LANGUAGE = USERENV('LANG') 
AND haotl.EFFECTIVE_START_DATE = hao.EFFECTIVE_START_DATE 
AND haotl.EFFECTIVE_END_DATE = hao.EFFECTIVE_END_DATE 
AND hac.CLASSIFICATION_CODE = 'DEPARTMENT'
--and hac.SET_ID = 300000003119426 -- France
and trunc(sysdate) between hao.EFFECTIVE_START_DATE and hao.EFFECTIVE_END_DATE
AND FSS.LANGUAGE = USERENV('LANG') 
and hac.SET_ID = FSS.SET_ID
UNION 
select 'MERGE|OrganizationTreeNode|PER_ORG_TREE_STRUCTURE|SG_MOCK3_ORG_TREE|SG Mock 3 Org Tree V1|' || haotl.name || '||FUN_BUSINESS_UNIT|||SOCIETE GENERALE GROUP|ENTERPRISE|' AA
FROM
HR_ORG_UNIT_CLASSIFICATIONS_F hac,
HR_ALL_ORGANIZATION_UNITS_F hao,
HR_ORGANIZATION_UNITS_F_TL haotl
WHERE hao.ORGANIZATION_ID = hac.ORGANIZATION_ID 
AND hao.ORGANIZATION_ID = haotl.ORGANIZATION_ID 
AND hao.EFFECTIVE_START_DATE BETWEEN hac.EFFECTIVE_START_DATE AND hac.EFFECTIVE_END_DATE 
AND haotl.LANGUAGE = USERENV('LANG') 
AND haotl.EFFECTIVE_START_DATE = hao.EFFECTIVE_START_DATE 
AND haotl.EFFECTIVE_END_DATE = hao.EFFECTIVE_END_DATE 
AND hac.CLASSIFICATION_CODE = 'FUN_BUSINESS_UNIT'
and trunc(sysdate) between hao.EFFECTIVE_START_DATE and hao.EFFECTIVE_END_DATE
-------------------------------------------------------------------------------------------------
select 'MERGE|User|' || user_id|| '|' || username  || '|ADD|SG_HR_ADMIN_GENPOP_ONLY_W2_DATA' AAA
from per_users 
where username in (
'redouane.layaida@socgen.com')
union
select 'METADATA|User|UserID|Username|AddRemoveRole|RoleCommonName' AAA from dual
-------------------------------------------------------------------------------------------------
SELECT HAUFT.NAME AS BU_CODE,
HAUFT.NAME AS BU_DESCRIPTION,
HOUCF.LEGISLATION_CODE AS COUNTRY,
TO_CHAR(HAUFT.EFFECTIVE_START_DATE, 'YYYY/MM/DD') AS EFFECTIVE_START_DATE,
TO_CHAR(HAUFT.EFFECTIVE_END_DATE, 'YYYY/MM/DD') AS EFFECTIVE_END_DATE,
HOUCF.STATUS AS STATUS,
FS.SET_CODE AS SET_CODE,
FS.SET_NAME AS SET_NAME,
HAUFT.LAST_UPDATED_BY AS LAST_UPDATED_BY,
TO_CHAR(HAUFT.LAST_UPDATE_DATE, 'YYYY/MM/DD') AS LAST_UPDATE_DATE
FROM HR_ORG_UNIT_CLASSIFICATIONS_F HOUCF,
HR_ALL_ORGANIZATION_UNITS_F HAOUF,
HR_ORGANIZATION_UNITS_F_TL HAUFT,
HR_ORGANIZATION_INFORMATION_F HOIF,
FND_SETID_SETS_VL FS
WHERE HAOUF.ORGANIZATION_ID = HOUCF.ORGANIZATION_ID
AND HAOUF.ORGANIZATION_ID = HAUFT.ORGANIZATION_ID
AND HAOUF.ORGANIZATION_ID = HOIF.ORGANIZATION_ID
AND HAOUF.EFFECTIVE_START_DATE BETWEEN HOUCF.EFFECTIVE_START_DATE
AND HOUCF.EFFECTIVE_END_DATE
AND HAUFT.LANGUAGE = 'US'
AND HAUFT.EFFECTIVE_START_DATE = HAOUF.EFFECTIVE_START_DATE
AND HAUFT.EFFECTIVE_END_DATE = HAOUF.EFFECTIVE_END_DATE
AND FS.SET_ID(+) = HOIF.ORG_INFORMATION4
AND HOUCF.CLASSIFICATION_CODE = 'FUN_BUSINESS_UNIT'
select 
trim(flv.lookup_type) lookup_type,  FLV.LOOKUP_CODE, 
FLV.LANGUAGE, FLV.MEANING, FLV.DESCRIPTION, 
FLV.ENABLED_FLAG, FLV.TERRITORY_CODE , FLV.TAG, to_char(FLV.START_DATE_ACTIVE,'DD-MON-YYYY') START_DATE_ACTIVE, 
to_char(FLV.END_DATE_ACTIVE,'DD-MON-YYYY') end_DATE_ACTIVE
,FLVcs.LANGUAGE cs_language, FLVcs.MEANING cs_meaning, FLVcs.DESCRIPTION cs_description
,FLVD.LANGUAGE D_language, FLVD.MEANING D_meaning, FLVD.DESCRIPTION D_description
,FLVE.LANGUAGE E_language, FLVE.MEANING E_meaning, FLVE.DESCRIPTION E_description
,FLVF.LANGUAGE F_language, FLVF.MEANING F_meaning, FLVF.DESCRIPTION F_description
,FLVFRC.LANGUAGE FRC_language, FLVFRC.MEANING FRC_meaning, FLVFRC.DESCRIPTION FRC_description
,FLVI.LANGUAGE I_language, FLVI.MEANING I_meaning, FLVI.DESCRIPTION I_description
,FLVNL.LANGUAGE NL_language, FLVNL.MEANING NL_meaning, FLVNL.DESCRIPTION NL_description
,FLVPL.LANGUAGE PL_language, FLVPL.MEANING PL_meaning, FLVPL.DESCRIPTION PL_description
,FLVPTB.LANGUAGE PTB_language, FLVPTB.MEANING PTB_meaning, FLVPTB.DESCRIPTION PTB_description
,FLVRO.LANGUAGE RO_language, FLVRO.MEANING RO_meaning, FLVRO.DESCRIPTION RO_description
,FLVTR.LANGUAGE TR_language, FLVTR.MEANING TR_meaning, FLVTR.DESCRIPTION TR_description
from fnd_lookup_values flv
, fnd_lookup_types fl
,fnd_lookup_values flvcs
,fnd_lookup_values flvD
,fnd_lookup_values flvE
,fnd_lookup_values flvF
,fnd_lookup_values flvFRC
,fnd_lookup_values flvI
,fnd_lookup_values flvNL
,fnd_lookup_values flvPL
,fnd_lookup_values flvPTB
,fnd_lookup_values flvRO
,fnd_lookup_values flvTR
where flv.language = 'US'
and flv.lookup_type = flvcs.lookup_type
and FLV.LOOKUP_CODE = flvcs.lookup_code
and flvcs.language = 'CS'
and flv.lookup_type = flvD.lookup_type
and FLV.LOOKUP_CODE = flvD.lookup_code
and flvD.language = 'D'
and FLV.lookup_type = flvE.lookup_type
and FLV.LOOKUP_CODE = flvE.lookup_code
and flvE.language = 'E'
and FLV.lookup_type = flvF.lookup_type
and FLV.LOOKUP_CODE = flvF.lookup_code
and flvF.language = 'F'
and FLV.lookup_type = flvFRC.lookup_type
and FLV.LOOKUP_CODE = flvFRC.lookup_code
and flvFRC.language = 'FRC'
and FLV.lookup_type = flvI.lookup_type
and FLV.LOOKUP_CODE = flvI.lookup_code
and flvI.language = 'I'
and FLV.lookup_type = flvNL.lookup_type
and FLV.LOOKUP_CODE = flvNL.lookup_code
and flvNL.language = 'NL'
and FLV.lookup_type = flvPL.lookup_type
and FLV.LOOKUP_CODE = flvPL.lookup_code
and flvPL.language = 'PL'
and FLV.lookup_type = flvPTB.lookup_type
and FLV.LOOKUP_CODE = flvPTB.lookup_code
and flvPTB.language = 'PTB'
and FLV.lookup_type = flvRO.lookup_type
and FLV.LOOKUP_CODE = flvRO.lookup_code
and flvRO.language = 'RO'
and FLV.lookup_type = flvTR.lookup_type
and FLV.LOOKUP_CODE = flvTR.lookup_code
and flvTR.language = 'TR'
and fl.lookup_type = FLV.lookup_type
and fl.VIEW_APPLICATION_ID = 3
and fl.CUSTOMIZATION_LEVEL in ('E', 'U')
-- and flv.LAST_UPDATED_BY != 'SEED_DATA_FROM_APPLICATION'
/*
and flv.lookup_type in (
'PER_RELIGION', 'PER_HIGHEST_EDUCATION_LEVEL'
-- 'EVAL_SYSTEM',
-- 'DOCUMENT_CATEGORY',
-- 'DOCUMENT_STATUS',
-- 'DISABILITY_CATEGORY',
--'DISABILITY_REASON',
--'DISABILITY_STATUS'
)
*/
------------------------------------------------------------------------------------------------------------
select * from fnd_vs_values_tl
where value_id in (select distinct value_id from fnd_vs_values_b
where value_set_id in (select distinct value_set_id from FND_VS_VALUE_SETS
where VALUE_SET_CODE like '%Dismisal%'))
SELECT FVTL.LANGUAGE, FVTL.SOURCE_LANG, FVVS.value_set_code, FLVB.INDEPENDENT_VALUE, FLVB.VALUE, FLVB.ENABLED_FLAG, FVTL.TRANSLATED_VALUE, FLVB.start_date_Active, FLVB.end_date_active
FROM FND_VS_VALUES_TL FVTL, FND_VS_VALUES_B FLVB, FND_VS_VALUE_SETS FVVS
WHERE FVTL.LANGUAGE IN ('US', 'FR', 'RO')
AND FLVB.VALUE_ID = FVTL.VALUE_ID
AND FVVS.VALUE_SET_ID = FLVB.VALUE_SET_ID
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
select flv.lookup_type,  FLV.LOOKUP_CODE, 
FLV.LANGUAGE, FLV.MEANING, FLV.DESCRIPTION, 
FLV.ENABLED_FLAG, FLV.TERRITORY_CODE , FLV.TAG, to_char(FLV.START_DATE_ACTIVE,'DD-MON-YYYY') START_DATE_ACTIVE, 
to_char(FLV.END_DATE_ACTIVE,'DD-MON-YYYY') end_DATE_ACTIVE
,FLVcs.LANGUAGE cs_language, FLVcs.MEANING cs_meaning, FLVcs.DESCRIPTION cs_description
,FLVD.LANGUAGE D_language, FLVD.MEANING D_meaning, FLVD.DESCRIPTION D_description
,FLVE.LANGUAGE E_language, FLVE.MEANING E_meaning, FLVE.DESCRIPTION E_description
,FLVF.LANGUAGE F_language, FLVF.MEANING F_meaning, FLVF.DESCRIPTION F_description
,FLVFRC.LANGUAGE FRC_language, FLVFRC.MEANING FRC_meaning, FLVFRC.DESCRIPTION FRC_description
,FLVI.LANGUAGE I_language, FLVI.MEANING I_meaning, FLVI.DESCRIPTION I_description
,FLVNL.LANGUAGE NL_language, FLVNL.MEANING NL_meaning, FLVNL.DESCRIPTION NL_description
,FLVPL.LANGUAGE PL_language, FLVPL.MEANING PL_meaning, FLVPL.DESCRIPTION PL_description
,FLVPTB.LANGUAGE PTB_language, FLVPTB.MEANING PTB_meaning, FLVPTB.DESCRIPTION PTB_description
,FLVRO.LANGUAGE RO_language, FLVRO.MEANING RO_meaning, FLVRO.DESCRIPTION RO_description
,FLVTR.LANGUAGE TR_language, FLVTR.MEANING TR_meaning, FLVTR.DESCRIPTION TR_description
from fnd_lookup_values flv
, fnd_lookup_types fl
,fnd_lookup_values flvcs
,fnd_lookup_values flvD
,fnd_lookup_values flvE
,fnd_lookup_values flvF
,fnd_lookup_values flvFRC
,fnd_lookup_values flvI
,fnd_lookup_values flvNL
,fnd_lookup_values flvPL
,fnd_lookup_values flvPTB
,fnd_lookup_values flvRO
,fnd_lookup_values flvTR
where flv.language = 'US'
and flv.lookup_type = flvcs.lookup_type
and FLV.LOOKUP_CODE = flvcs.lookup_code
and flvcs.language = 'CS'
and flv.lookup_type = flvD.lookup_type
and FLV.LOOKUP_CODE = flvD.lookup_code
and flvD.language = 'D'
and FLV.lookup_type = flvE.lookup_type
and FLV.LOOKUP_CODE = flvE.lookup_code
and flvE.language = 'E'
and FLV.lookup_type = flvF.lookup_type
and FLV.LOOKUP_CODE = flvF.lookup_code
and flvF.language = 'F'
and FLV.lookup_type = flvFRC.lookup_type
and FLV.LOOKUP_CODE = flvFRC.lookup_code
and flvFRC.language = 'FRC'
and FLV.lookup_type = flvI.lookup_type
and FLV.LOOKUP_CODE = flvI.lookup_code
and flvI.language = 'I'
and FLV.lookup_type = flvNL.lookup_type
and FLV.LOOKUP_CODE = flvNL.lookup_code
and flvNL.language = 'NL'
and FLV.lookup_type = flvPL.lookup_type
and FLV.LOOKUP_CODE = flvPL.lookup_code
and flvPL.language = 'PL'
and FLV.lookup_type = flvPTB.lookup_type
and FLV.LOOKUP_CODE = flvPTB.lookup_code
and flvPTB.language = 'PTB'
and FLV.lookup_type = flvRO.lookup_type
and FLV.LOOKUP_CODE = flvRO.lookup_code
and flvRO.language = 'RO'
and FLV.lookup_type = flvTR.lookup_type
and FLV.LOOKUP_CODE = flvTR.lookup_code
and flvTR.language = 'TR'
and fl.lookup_type = FLV.lookup_type
and fl.VIEW_APPLICATION_ID = 3
and fl.CUSTOMIZATION_LEVEL in ('E', 'U')
-- and flv.LAST_UPDATED_BY != 'SEED_DATA_FROM_APPLICATION'
/*
and flv.lookup_type in (
'PER_RELIGION', 'PER_HIGHEST_EDUCATION_LEVEL'
-- 'EVAL_SYSTEM',
-- 'DOCUMENT_CATEGORY',
-- 'DOCUMENT_STATUS',
-- 'DISABILITY_CATEGORY',
--'DISABILITY_REASON',
--'DISABILITY_STATUS'
)
*/
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
select 
'METADATA|OrganizationTreeNode|TreeStructureCode|TreeCode|TreeVersionName|OrganizationName|ClassificationCode|ReferenceTreeCode|ReferenceTreeVersionName|ParentOrganizationName|ParentClassificationCode|DeleteChildNodesFlag' AA from dual
UNION
select 'MERGE|OrganizationTreeNode|PER_ORG_TREE_STRUCTURE|SG_MOCK3_ORG_TREE|SG Mock 3 Org Tree V1|SOCIETE GENERALE GROUP|ENTERPRISE|||||'  AA from dual 
union
select 'MERGE|OrganizationTreeNode|PER_ORG_TREE_STRUCTURE|SG_MOCK3_ORG_TREE|SG Mock 3 Org Tree V1|' || haotl.name || '|DEPARTMENT|||' || fss.set_name || '|FUN_BUSINESS_UNIT|' AA
FROM
HR_ORG_UNIT_CLASSIFICATIONS_F hac,
HR_ALL_ORGANIZATION_UNITS_F hao,
HR_ORGANIZATION_UNITS_F_TL haotl,
FND_SETID_SETS FSS
WHERE hao.ORGANIZATION_ID = hac.ORGANIZATION_ID 
AND hao.ORGANIZATION_ID = haotl.ORGANIZATION_ID 
AND hao.EFFECTIVE_START_DATE BETWEEN hac.EFFECTIVE_START_DATE AND hac.EFFECTIVE_END_DATE 
AND haotl.LANGUAGE = USERENV('LANG') 
AND haotl.EFFECTIVE_START_DATE = hao.EFFECTIVE_START_DATE 
AND haotl.EFFECTIVE_END_DATE = hao.EFFECTIVE_END_DATE 
AND hac.CLASSIFICATION_CODE = 'DEPARTMENT'
--and hac.SET_ID = 300000003119426 -- France
and trunc(sysdate) between hao.EFFECTIVE_START_DATE and hao.EFFECTIVE_END_DATE
AND FSS.LANGUAGE = USERENV('LANG') 
and hac.SET_ID = FSS.SET_ID
UNION 
select 'MERGE|OrganizationTreeNode|PER_ORG_TREE_STRUCTURE|SG_MOCK3_ORG_TREE|SG Mock 3 Org Tree V1|' || haotl.name || '|FUN_BUSINESS_UNIT|||SOCIETE GENERALE GROUP|ENTERPRISE|' AA
FROM
HR_ORG_UNIT_CLASSIFICATIONS_F hac,
HR_ALL_ORGANIZATION_UNITS_F hao,
HR_ORGANIZATION_UNITS_F_TL haotl
WHERE hao.ORGANIZATION_ID = hac.ORGANIZATION_ID 
AND hao.ORGANIZATION_ID = haotl.ORGANIZATION_ID 
AND hao.EFFECTIVE_START_DATE BETWEEN hac.EFFECTIVE_START_DATE AND hac.EFFECTIVE_END_DATE 
AND haotl.LANGUAGE = USERENV('LANG') 
AND haotl.EFFECTIVE_START_DATE = hao.EFFECTIVE_START_DATE 
AND haotl.EFFECTIVE_END_DATE = hao.EFFECTIVE_END_DATE 
AND hac.CLASSIFICATION_CODE = 'FUN_BUSINESS_UNIT'
and trunc(sysdate) between hao.EFFECTIVE_START_DATE and hao.EFFECTIVE_END_DATE
-----------------------
select 
flv.lookup_type,
FLV.LOOKUP_CODE,
FLV.LANGUAGE, 
FLV.MEANING, 
FLV.DESCRIPTION, 
FLV.ENABLED_FLAG, 
FLV.TERRITORY_CODE , 
FLV.TAG, to_char(FLV.START_DATE_ACTIVE,'DD-MON-YYYY') START_DATE_ACTIVE, 
to_char(FLV.END_DATE_ACTIVE,'DD-MON-YYYY') END_DATE_ACTIVE,
flv.LAST_UPDATED_BY,
flv.LAST_UPDATED_date
, FLVcs.MEANING    Czech_meaning,                 FLVcs.DESCRIPTION Czech_description
, FLVD.MEANING     German_meaning,                FLVD.DESCRIPTION German_description
, FLVE.MEANING     Spanish_meaning,               FLVE.DESCRIPTION Spanish_description
, FLVF.MEANING     French_meaning,                FLVF.DESCRIPTION French_description
, FLVFRC.MEANING   Canadian_French_meaning,       FLVFRC.DESCRIPTION Canadian_French_description
, FLVI.MEANING     Italian_meaning,               FLVI.DESCRIPTION Italian_description
, FLVNL.MEANING    Dutch_meaning,                 FLVNL.DESCRIPTION Dutch_description
, FLVPL.MEANING    Polish_meaning,                FLVPL.DESCRIPTION Polish_description
, FLVPTB.MEANING   Brazilian_Portuguese_meaning,  FLVPTB.DESCRIPTION Brazilian_Portuguese_description
, FLVRO.MEANING    Romanian_meaning,              FLVRO.DESCRIPTION Romanian_description
, FLVTR.MEANING    Turkish_meaning,               FLVTR.DESCRIPTION Turkish_description
from fnd_lookup_values flv
, fnd_lookup_types fl
,fnd_lookup_values flvcs
,fnd_lookup_values flvD
,fnd_lookup_values flvE
,fnd_lookup_values flvF
,fnd_lookup_values flvFRC
,fnd_lookup_values flvI
,fnd_lookup_values flvNL
,fnd_lookup_values flvPL
,fnd_lookup_values flvPTB
,fnd_lookup_values flvRO
,fnd_lookup_values flvTR
where flv.language = 'US'
and flv.lookup_type = flvcs.lookup_type
and FLV.LOOKUP_CODE = flvcs.lookup_code
and flvcs.language = 'CS'
and flv.lookup_type = flvD.lookup_type
and FLV.LOOKUP_CODE = flvD.lookup_code
and flvD.language = 'D'
and FLV.lookup_type = flvE.lookup_type
and FLV.LOOKUP_CODE = flvE.lookup_code
and flvE.language = 'E'
and FLV.lookup_type = flvF.lookup_type
and FLV.LOOKUP_CODE = flvF.lookup_code
and flvF.language = 'F'
and FLV.lookup_type = flvFRC.lookup_type
and FLV.LOOKUP_CODE = flvFRC.lookup_code
and flvFRC.language = 'FRC'
and FLV.lookup_type = flvI.lookup_type
and FLV.LOOKUP_CODE = flvI.lookup_code
and flvI.language = 'I'
and FLV.lookup_type = flvNL.lookup_type
and FLV.LOOKUP_CODE = flvNL.lookup_code
and flvNL.language = 'NL'
and FLV.lookup_type = flvPL.lookup_type
and FLV.LOOKUP_CODE = flvPL.lookup_code
and flvPL.language = 'PL'
and FLV.lookup_type = flvPTB.lookup_type
and FLV.LOOKUP_CODE = flvPTB.lookup_code
and flvPTB.language = 'PTB'
and FLV.lookup_type = flvRO.lookup_type
and FLV.LOOKUP_CODE = flvRO.lookup_code
and flvRO.language = 'RO'
and FLV.lookup_type = flvTR.lookup_type
and FLV.LOOKUP_CODE = flvTR.lookup_code
and flvTR.language = 'TR'
and fl.lookup_type = FLV.lookup_type
and fl.VIEW_APPLICATION_ID = 3
and fl.CUSTOMIZATION_LEVEL in ('E', 'U')
-- and flv.LAST_UPDATED_BY != 'SEED_DATA_FROM_APPLICATION'
/*
and flv.lookup_type in (
'PER_RELIGION', 'PER_HIGHEST_EDUCATION_LEVEL'
-- 'EVAL_SYSTEM',
-- 'DOCUMENT_CATEGORY',
-- 'DOCUMENT_STATUS',
-- 'DISABILITY_CATEGORY',
--'DISABILITY_REASON',
--'DISABILITY_STATUS'
)
*/
--------------------------
select 'METADATA|User|PersonNumber' AA from Dual
UNION
select 'MERGE|User|'  ||  papf.person_number AA 
from per_users pu, per_all_people_f papf
where pu.person_id = papf.person_id
and trunc(sysdate) between papf.effective_start_date and papf.effective_end_date
and pu.username in (
-- Enter usernames here
'benjamin.dupont-ext@socgen.com',
'jean---marc.myt@socgen.com',
'julien.champigny-ext@socgen.com',
'juliette.beylle@socgen.com',
'heidi.feyssaguet-ext@socgen.com',
'emma.amigues-ext@socgen.com',
'maxime.bayle-ext@socgen.com',
'pierric.millet-ext@socgen.com ',
'justine.verdeyrout-ext@socgen.com',
'stephane.zalucki-ext@socgen.com'
)
UNION
select 'METADATA|UserRole|PersonNumber|AddRemoveRole|RoleCommonName' AAA from dual
union
select 'MERGE|UserRole|' ||  
--  user_id|| '|' || 
papf.person_number
-- || '|' || username
|| '|ADD|HUMAN_RESOURCE_ANALYST_CUSTOM_VIEW_ALL_DATA' AAA
from per_users pu , per_all_people_f papf
where pu.person_id = papf.person_id
and trunc(sysdate) between papf.effective_start_date and papf.effective_end_date
and pu.username 
 in (
-- Enter usernames here
'benjamin.dupont-ext@socgen.com',
'jean---marc.myt@socgen.com',
'julien.champigny-ext@socgen.com',
'juliette.beylle@socgen.com',
'heidi.feyssaguet-ext@socgen.com',
'emma.amigues-ext@socgen.com',
'maxime.bayle-ext@socgen.com',
'pierric.millet-ext@socgen.com ',
'justine.verdeyrout-ext@socgen.com',
'stephane.zalucki-ext@socgen.com'
)
----------------------------------------------------
select 'METADATA|User|PersonNumber' AA from Dual
UNION
select 'MERGE|User|'  ||  papf.person_number AA 
from per_users pu, per_all_people_f papf
where pu.person_id = papf.person_id
and trunc(sysdate) between papf.effective_start_date and papf.effective_end_date
and pu.username in (
-- Enter usernames here
'benjamin.dupont-ext@socgen.com',
'stephane.zalucki-ext@socgen.com'
)
UNION
select 'METADATA|UserRole|PersonNumber|AddRemoveRole|RoleCommonName' AAA from dual
union
select 'MERGE|UserRole|' ||  
--  user_id|| '|' || 
papf.person_number
-- || '|' || username
|| '|ADD|HUMAN_RESOURCE_ANALYST_CUSTOM_VIEW_ALL_DATA' AAA
from per_users pu , per_all_people_f papf
where pu.person_id = papf.person_id
and trunc(sysdate) between papf.effective_start_date and papf.effective_end_date
and pu.username 
 in (
-- Enter usernames here
'benjamin.dupont-ext@socgen.com',
'stephane.zalucki-ext@socgen.com'
)
-------------------------------------------------
select 
flt.MEANING Lookup_Name,
flt.DESCRIPTION Lookup_Description,
flv.lookup_type lookup_type,  FLV.LOOKUP_CODE,
FLV.MEANING English_Meaning, FLV.DESCRIPTION English_Description,
FLV.ENABLED_FLAG , FLV.TAG, to_char(FLV.START_DATE_ACTIVE,'DD-MON-YYYY') START_DATE_ACTIVE, 
to_char(FLV.END_DATE_ACTIVE,'DD-MON-YYYY') end_DATE_ACTIVE
, FLVcs.MEANING Czech_meaning, FLVcs.DESCRIPTION Czech_description
, FLVD.MEANING German_meaning, FLVD.DESCRIPTION German_description
, FLVE.MEANING Spanish_meaning, FLVE.DESCRIPTION Spanish_description
, FLVF.MEANING French_meaning, FLVF.DESCRIPTION French_description
, FLVFRC.MEANING Canadian_French_meaning, FLVFRC.DESCRIPTION Canadian_French_description
, FLVI.MEANING Italian_meaning, FLVI.DESCRIPTION Italian_description
, FLVNL.MEANING Dutch_meaning, FLVNL.DESCRIPTION Dutch_description
, FLVPL.MEANING Polish_meaning, FLVPL.DESCRIPTION Polish_description
, FLVPTB.MEANING Brazilian_Portuguese_meaning, FLVPTB.DESCRIPTION Brazilian_Portuguese_description
, FLVRO.MEANING Romanian_meaning, FLVRO.DESCRIPTION Romanian_description
, FLVTR.MEANING Turkish_meaning, FLVTR.DESCRIPTION Turkish_description,
flv.LAST_UPDATED_BY, flv.LAST_UPDATE_date, flv.Creation_date, flv.Created_by
from fnd_lookup_values flv
, fnd_lookup_types fl
, fnd_lookup_types_tl flt
,fnd_lookup_values flvcs
,fnd_lookup_values flvD
,fnd_lookup_values flvE
,fnd_lookup_values flvF
,fnd_lookup_values flvFRC
,fnd_lookup_values flvI
,fnd_lookup_values flvNL
,fnd_lookup_values flvPL
,fnd_lookup_values flvPTB
,fnd_lookup_values flvRO
,fnd_lookup_values flvTR
where flv.language = 'US'
and flt.language = 'US'
and flv.lookup_type = flvcs.lookup_type
and FLV.LOOKUP_CODE = flvcs.lookup_code
and flvcs.language = 'CS'
and flv.lookup_type = flvD.lookup_type
and FLV.LOOKUP_CODE = flvD.lookup_code
and flvD.language = 'D'
and FLV.lookup_type = flvE.lookup_type
and FLV.LOOKUP_CODE = flvE.lookup_code
and flvE.language = 'E'
and FLV.lookup_type = flvF.lookup_type
and FLV.LOOKUP_CODE = flvF.lookup_code
and flvF.language = 'F'
and FLV.lookup_type = flvFRC.lookup_type
and FLV.LOOKUP_CODE = flvFRC.lookup_code
and flvFRC.language = 'FRC'
and FLV.lookup_type = flvI.lookup_type
and FLV.LOOKUP_CODE = flvI.lookup_code
and flvI.language = 'I'
and FLV.lookup_type = flvNL.lookup_type
and FLV.LOOKUP_CODE = flvNL.lookup_code
and flvNL.language = 'NL'
and FLV.lookup_type = flvPL.lookup_type
and FLV.LOOKUP_CODE = flvPL.lookup_code
and flvPL.language = 'PL'
and FLV.lookup_type = flvPTB.lookup_type
and FLV.LOOKUP_CODE = flvPTB.lookup_code
and flvPTB.language = 'PTB'
and FLV.lookup_type = flvRO.lookup_type
and FLV.LOOKUP_CODE = flvRO.lookup_code
and flvRO.language = 'RO'
and FLV.lookup_type = flvTR.lookup_type
and FLV.LOOKUP_CODE = flvTR.lookup_code
and flvTR.language = 'TR'
and fl.lookup_type = FLV.lookup_type
and fl.lookup_type = FLt.lookup_type
and fl.VIEW_APPLICATION_ID = 3
and fl.CUSTOMIZATION_LEVEL in ('E', 'U')
-- and flv.LAST_UPDATED_BY != 'SEED_DATA_FROM_APPLICATION'
and flv.lookup_type in ( 'XX_LOOKUP_TYPE'
--,'PER_RELIGION', 'PER_HIGHEST_EDUCATION_LEVEL'
-- 'EVAL_SYSTEM',
-- 'DOCUMENT_CATEGORY',
-- 'DOCUMENT_STATUS',
-- 'DISABILITY_CATEGORY',
--'DISABILITY_REASON',
--'DISABILITY_STATUS'
)
---------------------------------------------------------------------------
SELECT 
       pnsv.legislation_code,
       pnsv.NAME_STYLE,
       pensv.display_sequence,
       pensv.column_name,
       pensv.prompt,
       pensv.required_flag,
       pensv.SEEDED_REQUIRED_FLAG,
pnsv.CREATED_BY,
pnsv.CREATION_DATE,
pnsv.LAST_UPDATED_BY,
pnsv.LAST_UPDATE_DATE
FROM PER_EDIT_NAME_SETUP_VL pensv, PER_NAME_STYLES_VL pnsv
WHERE pensv.name_style_id = pnsv.name_style_id
ORDER BY 1,3
select 
 PENSB.EDIT_NAME_SETUP_ID
,PENSB.NAME_STYLE_ID
,PENSB.DISPLAY_SEQUENCE
,PENSB.COLUMN_NAME
,PENSB.REQUIRED_FLAG
,PENSB.ACTIVE_FLAG
,PENSB.CREATED_BY
,PENSB.CREATION_DATE
,PENSB.LAST_UPDATED_BY
,PENSB.LAST_UPDATE_DATE
,PENSB.SEEDED_REQUIRED_FLAG
,PENST.PROMPT
,PENST.language Prompt_Language
,PNST.SOURCE_LANG Prompt_Source_Language
,PNSB.LEGISLATION_CODE 
,PNSB.ALTERNATE_NAME_REQUIRED
,PNST.NAME_STYLE
,PNST.LANGUAGE
,PNST.SOURCE_LANG
FROM
PER_EDIT_NAME_SETUP_B PENSB,
PER_EDIT_NAME_SETUP_TL PENST, 
PER_NAME_STYLES_B PNSB, PER_NAME_STYLES_TL PNST
WHERE PENSB.EDIT_NAME_SETUP_ID = PENST.EDIT_NAME_SETUP_ID
AND PNSB.NAME_STYLE_ID=PNST.NAME_STYLE_ID
AND PENSB.NAME_STYLE_ID = PNSB.NAME_STYLE_ID
and PNST.language = PENST.language
---------------------------------
Select B.NAME_STYLE_ID,
B.LEGISLATION_CODE,
B.ENTERPRISE_ID,
B.ALTERNATE_NAME_REQUIRED,
T.NAME_STYLE,
B.MODULE_ID,
B.OBJECT_VERSION_NUMBER,
B.CREATED_BY,
B.CREATION_DATE,
B.LAST_UPDATED_BY,
B.LAST_UPDATE_DATE,
B.LAST_UPDATE_LOGIN
FROM PER_NAME_STYLES_B B, PER_NAME_STYLES_TL T
WHERE B.NAME_STYLE_ID=T.NAME_STYLE_ID
AND T.LANGUAGE = userenv('LANG')
SELECT
B.EDIT_NAME_SETUP_ID,
B.NAME_STYLE_ID,
B.ENTERPRISE_ID,
B.DISPLAY_SEQUENCE,
B.COLUMN_NAME,
B.REQUIRED_FLAG,
T.PROMPT,
B.COLUMN_LOOKUP,
B.MODULE_ID,
B.OBJECT_VERSION_NUMBER,
B.CREATED_BY,
B.CREATION_DATE,
B.LAST_UPDATED_BY,
B.LAST_UPDATE_DATE,
B.LAST_UPDATE_LOGIN,
B.SEEDED_REQUIRED_FLAG,
B.SGUID SGUID,
B.ACTIVE_FLAG
FROM
PER_EDIT_NAME_SETUP_B B,
PER_EDIT_NAME_SETUP_TL T
WHERE
B.EDIT_NAME_SETUP_ID = T.EDIT_NAME_SETUP_ID
AND T.LANGUAGE = USERENV('LANG')
-----------------------------------------------------------------------------------
select 
'METADATA|WorkTerms|AssignmentId|ActionCode|EffectiveStartDate|EffectiveEndDate|EffectiveLatestChange|EffectiveSequence|PeriodOfServiceId|PrimaryWorkTermsFlag' AA
from dual
Union
select 
'METADATA|Assignment|AssignmentId|ActionCode|WorkTermsAssignmentId|EffectiveStartDate|EffectiveEndDate|EffectiveLatestChange|EffectiveSequence|PeriodOfServiceId|PrimaryFlag|PrimaryAssignmentFlag' AA
from Dual
Union
select ASGT.AA from 
(
select 
Assignment_number,
'MERGE|WorkTerms|'||assignment_ID || '|' ||
Action_code  || '|' ||
to_char(effective_start_date, 'YYYY/MM/DD') || '|' ||
to_char(effective_end_date, 'YYYY/MM/DD') || '|' ||
effective_latest_change || '|' ||  effective_sequence  || '|' ||
period_of_service_id || '|' ||Primary_work_terms_flag
AA
from per_all_assignments_M
where  primary_work_terms_flag = 'Y'
Union
select 
Assignment_number, 
'MERGE|Assignment|'||assignment_ID || '|' || Action_code  || '|' ||
Work_terms_assignment_id || '|' ||
to_char(effective_start_date, 'YYYY/MM/DD') || '|' || to_char(effective_end_date, 'YYYY/MM/DD') || '|' ||
effective_latest_change || '|' ||  effective_sequence  || '|' || period_of_service_id || '|' ||
primary_flag || '|' || Primary_assignment_flag
AA
from per_all_assignments_M pma
where 
 primary_work_terms_flag = 'N'
 ) ASGT
 where 
 asgt.assignment_number like '%20900002319%'
 ---------------------------------------------------------------
 select distinct aa.department
from 
(select papf.person_number, 
(select HAOTL.NAME from HR_ORGANIZATION_UNITS_F_TL haotl where haotl.organization_id =
paam.organization_id 
and trunc(sysdate) between haotl.effective_start_date and haotl.effective_end_date
and haotl.language = 'US'
) Department, 
paam.assignment_number
from 
per_all_assignments_m paam, per_all_people_f papf
where papf.person_id = paam.person_id
and trunc(sysdate) between paam.effective_start_date and paam.effective_end_date
and trunc(sysdate) between papf.effective_start_date and papf.effective_end_date
and paam.ASSIGNMENT_TYPE in ('E', 'C')
and papf.person_number in (
'XXXXXXXXX'
)
) AA
--where aa.department is null
---------------------------------------------------------------
Get Assignment number from person number
---------------------------------------------------------------
SELECT PAPF.PERSON_NUMBER, PAAM.ASSIGNMENT_NUMBER 
FROM PER_ALL_PEOPLE_F PAPF, PER_ALL_ASSIGNMENTS_M PAAM
WHERE PAPF.PERSON_ID = PAAM.PERSON_ID
AND TRUNC(SYSDATE) BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.EFFECTIVE_END_DATE
AND TRUNC(SYSDATE) BETWEEN PAAM.EFFECTIVE_START_DATE AND PAAM.EFFECTIVE_END_DATE
AND PAAM.PRIMARY_FLAG = 'Y'
AND PAPF.PERSON_NUMBER IN (
'80900002216'
)
---------------------------------------------------------------
---------------------------------------------------------------
-- Loaded AOR in the INSTANCE
---------------------------------------------------------------
Select 'MERGE' METADATA, 'AreasOfResponsibility' AreasOfResponsibility, '' ResponsibilityName , 'SG Security Access' ResponsibilityType,
'N' WorkContactsFlag, 'Active' Status, :OrganizationTreeCode, :OrganizationHierarchyVersionName, 'FUN_BUSINESS_UNIT' TopOrganizationClassificationCode,
'Y' IncludeTopHierNode,papf.person_number,  paam.assignment_number, to_char(ppos.date_start,'YYYY/MM/DD') date_start ,:Country_Code
SELECT PAR.*
FROM PER_ALL_PEOPLE_F PAPF, PER_ALL_ASSIGNMENTS_M PAAM, PER_PERIODS_OF_SERVICE PPOS , PER_ASG_RESPONSIBILITIES PAR
WHERE PAPF.PERSON_ID = PPOS.PERSON_ID
AND PAR.PERSON_ID = PPOS.PERSON_ID
AND PAAM.ASSIGNMENT_ID = PAR.ASSIGNMENT_ID
AND  PPOS.PERIOD_OF_SERVICE_ID = PAAM.PERIOD_OF_SERVICE_ID
AND  PAAM.ASSIGNMENT_STATUS_TYPE = 'ACTIVE'
AND  PAAM.EFFECTIVE_LATEST_CHANGE = 'Y'
AND  PAAM.PRIMARY_FLAG = 'Y'
AND  PAPF.PERSON_NUMBER IN (:PERSON_NUMBER) 
AND TRUNC(SYSDATE)  BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.EFFECTIVE_END_DATE
AND TRUNC(SYSDATE)  BETWEEN PAAM.EFFECTIVE_START_DATE AND PAAM.EFFECTIVE_END_DATE
---------------------------------------------------------------------
SELECT HAOTL.NAME tOP_oRG_NAME, PAR.*
FROM PER_ALL_PEOPLE_F PAPF, PER_ALL_ASSIGNMENTS_M PAAM, PER_PERIODS_OF_SERVICE PPOS , PER_ASG_RESPONSIBILITIES PAR, HR_ORGANIZATION_UNITS_F_TL HAOTL 
WHERE PAPF.PERSON_ID = PPOS.PERSON_ID
AND PAR.PERSON_ID = PPOS.PERSON_ID
AND PAAM.ASSIGNMENT_ID = PAR.ASSIGNMENT_ID
AND  PPOS.PERIOD_OF_SERVICE_ID = PAAM.PERIOD_OF_SERVICE_ID
AND  PAAM.ASSIGNMENT_STATUS_TYPE = 'ACTIVE'
AND  PAAM.EFFECTIVE_LATEST_CHANGE = 'Y'
AND  PAAM.PRIMARY_FLAG = 'Y'
AND  PAPF.PERSON_NUMBER IN (:PERSON_NUMBER) 
AND TRUNC(SYSDATE)  BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.EFFECTIVE_END_DATE
AND TRUNC(SYSDATE)  BETWEEN PAAM.EFFECTIVE_START_DATE AND PAAM.EFFECTIVE_END_DATE
and trunc(sysdate) between HAOTL.effective_start_date and HAOTL.effective_end_date
AND HAOTL.LANGUAGE = 'US'
and HAOTL.organization_id = PAR.TOP_ORGANIZATION_ID 
select 
HAOTL.NAME
from 
HR_ORGANIZATION_UNITS_F_TL HAOTL 
where 
and trunc(sysdate) between HAOTL.effective_start_date and HAOTL.effective_end_date
AND HAOTL.LANGUAGE = 'US'
and HAOTL.organization_id = PAR.TOP_ORGANIZATION_ID 
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
select papf.person_number , pu.user_id, pu.username
from per_users pu , per_all_people_f papf
where pu.person_id = papf.person_id
and trunc(sysdate) between papf.effective_start_date and papf.effective_end_date
and papf.person_number in 
(
'20000146650'
)
select 'METADATA|User|UserID|Username' AAA from dual
union
select 'MERGE|User|' || pu.user_id|| '|' || pu.username
from per_users pu , per_all_people_f papf
where pu.person_id = papf.person_id
and trunc(sysdate) between papf.effective_start_date and papf.effective_end_date
and papf.person_number in 
(
'20000101051'
)
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
select 
flt.MEANING Lookup_Name,
flt.DESCRIPTION Lookup_Description,
flv.lookup_type lookup_type,  FLV.LOOKUP_CODE,
FLV.MEANING English_Meaning, FLV.DESCRIPTION English_Description,
FLV.ENABLED_FLAG , FLV.TAG, to_char(FLV.START_DATE_ACTIVE,'DD-MON-YYYY') START_DATE_ACTIVE, 
to_char(FLV.END_DATE_ACTIVE,'DD-MON-YYYY') end_DATE_ACTIVE
, FLVcs.MEANING Czech_meaning, FLVcs.DESCRIPTION Czech_description
, FLVD.MEANING German_meaning, FLVD.DESCRIPTION German_description
, FLVE.MEANING Spanish_meaning, FLVE.DESCRIPTION Spanish_description
, FLVF.MEANING French_meaning, FLVF.DESCRIPTION French_description
, FLVFRC.MEANING Canadian_French_meaning, FLVFRC.DESCRIPTION Canadian_French_description
, FLVI.MEANING Italian_meaning, FLVI.DESCRIPTION Italian_description
, FLVNL.MEANING Dutch_meaning, FLVNL.DESCRIPTION Dutch_description
, FLVPL.MEANING Polish_meaning, FLVPL.DESCRIPTION Polish_description
, FLVPTB.MEANING Brazilian_Portuguese_meaning, FLVPTB.DESCRIPTION Brazilian_Portuguese_description
, FLVRO.MEANING Romanian_meaning, FLVRO.DESCRIPTION Romanian_description
, FLVTR.MEANING Turkish_meaning, FLVTR.DESCRIPTION Turkish_description,
flv.LAST_UPDATED_BY, flv.LAST_UPDATE_date, flv.Creation_date, flv.Created_by
from fnd_lookup_values flv
, fnd_lookup_types fl
, fnd_lookup_types_tl flt
,fnd_lookup_values flvcs
,fnd_lookup_values flvD
,fnd_lookup_values flvE
,fnd_lookup_values flvF
,fnd_lookup_values flvFRC
,fnd_lookup_values flvI
,fnd_lookup_values flvNL
,fnd_lookup_values flvPL
,fnd_lookup_values flvPTB
,fnd_lookup_values flvRO
,fnd_lookup_values flvTR
where flv.language = 'US'
and flt.language = 'US'
and flv.lookup_type = flvcs.lookup_type
and FLV.LOOKUP_CODE = flvcs.lookup_code
and flvcs.language = 'CS'
and flv.lookup_type = flvD.lookup_type
and FLV.LOOKUP_CODE = flvD.lookup_code
and flvD.language = 'D'
and FLV.lookup_type = flvE.lookup_type
and FLV.LOOKUP_CODE = flvE.lookup_code
and flvE.language = 'E'
and FLV.lookup_type = flvF.lookup_type
and FLV.LOOKUP_CODE = flvF.lookup_code
and flvF.language = 'F'
and FLV.lookup_type = flvFRC.lookup_type
and FLV.LOOKUP_CODE = flvFRC.lookup_code
and flvFRC.language = 'FRC'
and FLV.lookup_type = flvI.lookup_type
and FLV.LOOKUP_CODE = flvI.lookup_code
and flvI.language = 'I'
and FLV.lookup_type = flvNL.lookup_type
and FLV.LOOKUP_CODE = flvNL.lookup_code
and flvNL.language = 'NL'
and FLV.lookup_type = flvPL.lookup_type
and FLV.LOOKUP_CODE = flvPL.lookup_code
and flvPL.language = 'PL'
and FLV.lookup_type = flvPTB.lookup_type
and FLV.LOOKUP_CODE = flvPTB.lookup_code
and flvPTB.language = 'PTB'
and FLV.lookup_type = flvRO.lookup_type
and FLV.LOOKUP_CODE = flvRO.lookup_code
and flvRO.language = 'RO'
and FLV.lookup_type = flvTR.lookup_type
and FLV.LOOKUP_CODE = flvTR.lookup_code
and flvTR.language = 'TR'
and fl.lookup_type = FLV.lookup_type
and fl.lookup_type = FLt.lookup_type
and fl.VIEW_APPLICATION_ID = 3
and fl.CUSTOMIZATION_LEVEL in ('E', 'U')
-- and flv.LAST_UPDATED_BY != 'SEED_DATA_FROM_APPLICATION'
and flv.lookup_type in ( 'XX_LOOKUP_TYPE',
)
-------------------------------------------------------------------------------------------------------------
select  parb.action_reason_code, 
part.action_reason English_Action_Reason, 
partF.action_reason French_Action_Reason,
partRO.action_reason Romanian_Action_Reason,
partD.action_reason German_Action_Reason,
partE.action_reason Spanish_Action_Reason,
partFRC.action_reason Canadian_French_Action_Reason,
partI.action_reason Italian_Action_Reason,
partNL.action_reason Dutch_Action_Reason,
partPTB.action_reason Brazilian_Portuguese_Action_Reason,
partTR.action_reason Turkish_Action_Reason,
parb.start_date Reason_start_date, 
parb.end_date reason_end_date,
part.CREATED_BY Reason_CREATED_BY, 
part.CREATION_DATE Reason_CREATION_DATE, 
part.LAST_UPDATED_BY Reason_LAST_UPDATED_BY, 
part.LAST_UPDATE_DATE Reason_LAST_UPDATE_DATE
from per_action_reasons_b parb, 
per_action_reasons_tl part,
per_action_reasons_tl partf,
per_action_reasons_tl partRO,
per_action_reasons_tl partD,
per_action_reasons_tl partE,
per_action_reasons_tl partFRC,
per_action_reasons_tl partI,
per_action_reasons_tl partNL,
per_action_reasons_tl partPTB,
per_action_reasons_tl partTR
where parb.action_reason_id = part.action_reason_id
and part.language ='US'
and parb.action_reason_id = partF.action_reason_id
and partF.language ='F'
and parb.action_reason_id = partRO.action_reason_id
and partRO.language ='RO'
and parb.action_reason_id = partD.action_reason_id
and partD.language ='D'
and parb.action_reason_id = partE.action_reason_id
and partE.language ='E'
and parb.action_reason_id = partFRC.action_reason_id
and partFRC.language ='FRC'
and parb.action_reason_id = partI.action_reason_id
and partI.language ='I'
and parb.action_reason_id = partNL.action_reason_id
and partNL.language ='NL'
and parb.action_reason_id = partPTB.action_reason_id
and partPTB.language ='PTB'
and parb.action_reason_id = partTR.action_reason_id
and partTR.language ='TR'
----------------------------------------------------------------------------------------------------------
SELECT 
PATB.ACTION_TYPE_ID, PATB.ACTION_TYPE_CODE, PATT.MEANING ACTION_TYPE, PAT.ACTION_ID, PAB.ACTION_CODE,
PAT.ACTION_NAME ENGLISH_ACTION_NAME,
patF.action_name French_Action_name,
patRO.action_name Romanian_Action_name,
patD.action_name German_Action_name,
patE.action_name Spanish_Action_name,
patFRC.action_name Canadian_French_Action_name,
patI.action_name Italian_Action_name,
patNL.action_name Dutch_Action_name,
patPTB.action_name Brazilian_Portuguese_Action_name,
patTR.action_name Turkish_Action_name,
PAB.START_DATE ACTION_START_DATE, PAB.END_DATE ACTION_END_DATE, 
PAT.CREATED_BY ACTION_CREATED_BY, PAT.CREATION_DATE ACTION_CREATION_DATE, PAT.LAST_UPDATED_BY ACTION_LAST_UPDATED_BY, PAT.LAST_UPDATE_DATE ACTION_LAST_UPDATE_DATE
FROM PER_ACTION_TYPES_B PATB, PER_ACTION_TYPES_TL PATT, PER_ACTIONS_B PAB, 
PER_ACTIONS_TL PAT,
PER_ACTIONS_TL PATF,
PER_ACTIONS_TL PATRO,
PER_ACTIONS_TL PATD,
PER_ACTIONS_TL PATE,
PER_ACTIONS_TL PATFRC,
PER_ACTIONS_TL PATI,
PER_ACTIONS_TL PATNL,
PER_ACTIONS_TL PATPTB,
PER_ACTIONS_TL PATTR
WHERE PATB.ACTION_TYPE_ID = PATT.ACTION_TYPE_ID
AND PATB.ACTION_TYPE_ID = PAB.ACTION_TYPE_ID
AND PATT.LANGUAGE = 'US'
AND PAB.ACTION_ID = PAT.ACTION_ID
AND PAT.LANGUAGE = 'US'
and PAB.action_id = patF.action_id
and patF.language ='F'
and PAB.action_id = patRO.action_id
and patRO.language ='RO'
and PAB.action_id = patD.action_id
and patD.language ='D'
and PAB.action_id = patE.action_id
and patE.language ='E'
and PAB.action_id = patFRC.action_id
and patFRC.language ='FRC'
and PAB.action_id = patI.action_id
and patI.language ='I'
and PAB.action_id = patNL.action_id
and patNL.language ='NL'
and PAB.action_id = patPTB.action_id
and patPTB.language ='PTB'
and PAB.action_id = patTR.action_id
and patTR.language ='TR'
----------------------------------------------------------------------------------------------------------
select 
--count (*) MultipleLang
aa.language, action_type_code,Action_type, action_code,action_name, Action_Start_date, Action_end_date, action_reason_code, action_reason, Reason_start_date , reason_end_date
from 
(
select pat.language, patb.action_type_id, PATB.action_type_code, PATT.meaning Action_type, pat.action_id, pab.action_code, Pat.action_name, pab.start_date Action_Start_date, pab.end_date Action_end_date
from per_action_types_b patb, per_action_types_tl patt, per_actions_b pab, per_actions_tl pat
where patb.action_type_id = patt.action_type_id
and patb.action_type_id = pab.action_type_id
and pab.action_id = pat.action_id
and patt.language = pat.language
--and pat.language = 'US'
and pat.language in ('US','F','RO','D','E','FRC','I','NL','PTB','TR')
) AA,
(
select part.language, paru.action_id, parb.action_reason_id, parb.action_reason_code, part.action_reason, paru.start_date Reason_start_date , paru.end_date reason_end_date
from per_action_reasons_b parb, per_action_reasons_tl part, per_action_reason_usages paru
where parb.action_reason_id = part.action_reason_id
and paru.action_reason_id = part.action_reason_id
--and part.language = 'US'
and part.language in ('US','F','RO','D','E','FRC','I','NL','PTB','TR')
) BB
where aa.action_id =bb.action_id(+)
and aa.language = bb.language
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
-- Minimalistic Codes CHECK
----------------------------------------------------------------------------------------------------------
SELECT 
PATB.ACTION_TYPE_ID,
PATB.ACTION_TYPE_CODE, 
PAB.ACTION_ID, 
PAB.ACTION_CODE, 
PAB.START_DATE ACTION_START_DATE, 
PAB.END_DATE ACTION_END_DATE
FROM PER_ACTION_TYPES_B PATB, PER_ACTIONS_B PAB
WHERE PATB.ACTION_TYPE_ID = PAB.ACTION_TYPE_ID
------------------------
-- New Union Query 
SELECT PATB.ACTION_TYPE_ID, PAB.ACTION_ID,
PATB.ACTION_TYPE_CODE,
PATT.MEANING ACTION_TYPE, 
PAB.ACTION_CODE, 
PAT.ACTION_NAME, 
PAB.START_DATE ACTION_START_DATE, 
PAB.END_DATE ACTION_END_DATE,
parb.action_reason_id, 
parb.action_reason_code, 
part.action_reason, 
paru.start_date Reason_start_date , 
paru.end_date reason_end_date
FROM PER_ACTION_TYPES_B PATB, PER_ACTION_TYPES_TL PATT, PER_ACTIONS_B PAB, PER_ACTIONS_TL PAT,
per_action_reasons_b parb, per_action_reasons_tl part, per_action_reason_usages paru
WHERE PATB.ACTION_TYPE_ID = PATT.ACTION_TYPE_ID
AND PATB.ACTION_TYPE_ID = PAB.ACTION_TYPE_ID
AND PAB.ACTION_ID = PAT.ACTION_ID
AND PATT.LANGUAGE = PAT.LANGUAGE
AND PAT.LANGUAGE = 'US'
and paru.action_id = PAB.ACTION_ID
AND parb.action_reason_id = part.action_reason_id
and paru.action_reason_id = part.action_reason_id
and part.language = 'US'
UNION
SELECT PATB.ACTION_TYPE_ID, PAB.ACTION_ID,
PATB.ACTION_TYPE_CODE,
PATT.MEANING ACTION_TYPE, 
PAB.ACTION_CODE, 
PAT.ACTION_NAME, 
PAB.START_DATE ACTION_START_DATE, 
PAB.END_DATE ACTION_END_DATE,
null action_reason_id, 
'#NULL' action_reason_code, 
'#NULL' action_reason, 
PAB.START_DATE Reason_start_date , 
PAB.END_DATE Reason_end_date
FROM PER_ACTION_TYPES_B PATB, PER_ACTION_TYPES_TL PATT, PER_ACTIONS_B PAB, PER_ACTIONS_TL PAT
WHERE PATB.ACTION_TYPE_ID = PATT.ACTION_TYPE_ID
AND PATB.ACTION_TYPE_ID = PAB.ACTION_TYPE_ID
AND PAB.ACTION_ID = PAT.ACTION_ID
AND PATT.LANGUAGE = PAT.LANGUAGE
AND PAT.LANGUAGE = 'US'
------------------------
SELECT PATB.ACTION_TYPE_ID, PAB.ACTION_ID,
PATB.ACTION_TYPE_CODE,
PATT.MEANING ACTION_TYPE, 
PAB.ACTION_CODE, 
PAT.ACTION_NAME, 
PAB.START_DATE ACTION_START_DATE, 
PAB.END_DATE ACTION_END_DATE
FROM PER_ACTION_TYPES_B PATB, PER_ACTION_TYPES_TL PATT, PER_ACTIONS_B PAB, PER_ACTIONS_TL PAT
WHERE PATB.ACTION_TYPE_ID = PATT.ACTION_TYPE_ID
AND PATB.ACTION_TYPE_ID = PAB.ACTION_TYPE_ID
AND PAB.ACTION_ID = PAT.ACTION_ID
AND PATT.LANGUAGE = PAT.LANGUAGE
AND PAT.LANGUAGE = 'US'
-----------------------------------------------
SELECT PATB.ACTION_TYPE_ID, PAB.ACTION_ID,
PATB.ACTION_TYPE_CODE,
PATT.MEANING ACTION_TYPE, 
PAB.ACTION_CODE, 
PAT.ACTION_NAME, 
PAB.START_DATE ACTION_START_DATE, 
PAB.END_DATE ACTION_END_DATE,
parb.action_reason_id, 
parb.action_reason_code, 
part.action_reason, 
paru.start_date Reason_start_date , 
paru.end_date reason_end_date,
paru.COUNTRY,
paru.ALL_ROLE
FROM PER_ACTION_TYPES_B PATB, PER_ACTION_TYPES_TL PATT, PER_ACTIONS_B PAB, PER_ACTIONS_TL PAT,
per_action_reasons_b parb, per_action_reasons_tl part, per_action_reason_usages paru
WHERE PATB.ACTION_TYPE_ID = PATT.ACTION_TYPE_ID
AND PATB.ACTION_TYPE_ID = PAB.ACTION_TYPE_ID
AND PAB.ACTION_ID = PAT.ACTION_ID
AND PATT.LANGUAGE = PAT.LANGUAGE
AND PAT.LANGUAGE = 'US'
and paru.action_id = PAB.ACTION_ID
AND parb.action_reason_id = part.action_reason_id
and paru.action_reason_id = part.action_reason_id
and part.language = 'US'
UNION
SELECT PATB.ACTION_TYPE_ID, PAB.ACTION_ID,
PATB.ACTION_TYPE_CODE,
PATT.MEANING ACTION_TYPE, 
PAB.ACTION_CODE, 
PAT.ACTION_NAME, 
PAB.START_DATE ACTION_START_DATE, 
PAB.END_DATE ACTION_END_DATE,
null action_reason_id, 
'' action_reason_code, 
'' action_reason, 
PAB.START_DATE Reason_start_date , 
PAB.END_DATE Reason_end_date,
'' COUNTRY,
'' ALL_ROLE
FROM PER_ACTION_TYPES_B PATB, PER_ACTION_TYPES_TL PATT, PER_ACTIONS_B PAB, PER_ACTIONS_TL PAT
WHERE PATB.ACTION_TYPE_ID = PATT.ACTION_TYPE_ID
AND PATB.ACTION_TYPE_ID = PAB.ACTION_TYPE_ID
AND PAB.ACTION_ID = PAT.ACTION_ID
AND PATT.LANGUAGE = PAT.LANGUAGE
AND PAT.LANGUAGE = 'US'
---------------------------------------------------------------------------------------------------------------
User roles assigned in an INSTANCE
SELECT 
PAPF.PERSON_NUMBER,
PP.ATTRIBUTE1,
PU.USERNAME,
PRD.ROLE_COMMON_NAME
FROM 
PER_USERS PU
JOIN PER_ALL_PEOPLE_F PAPF 
ON PU.PERSON_ID = PAPF.PERSON_ID
AND TRUNC(SYSDATE) BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.EFFECTIVE_END_DATE
JOIN PER_PERSONS PP
ON PP.PERSON_ID = PAPF.PERSON_ID
JOIN PER_USER_ROLES PUR
ON PU.USER_ID = PUR.USER_ID
JOIN PER_ROLES_DN PRD
on pur.role_id = PRD.role_id
WHERE PU.ACTIVE_FLAG = 'Y'
and upper(username) like '%@S%'
------------------------------------------------------------------------------
SELECT
pn.DISPLAY_NAME,
pall.PERSON_NUMBER,
asg.ASSIGNMENT_NUMBER,
pp.ATTRIBUTE1 GGI,
aor.*
FROM PER_ASG_RESPONSIBILITIES aor
JOIN PER_PERSON_NAMES_F pn ON aor.PERSON_ID=pn.PERSON_ID
JOIN PER_ALL_PEOPLE_F pall ON aor.PERSON_ID=pall.PERSON_ID
JOIN PER_ALL_ASSIGNMENTS_M asg ON aor.PERSON_ID=asg.PERSON_ID
JOIN per_persons pp on aor.PERSON_ID=pp.PERSON_ID
WHERE TRUNC(sysdate) BETWEEN pn.effective_start_date AND pn.effective_end_date
AND pn.NAME_TYPE='GLOBAL'
AND asg.ASSIGNMENT_TYPE IN ('E','C','N','P')
AND TRUNC(sysdate) BETWEEN asg.effective_start_date AND asg.effective_end_date
select papf.person_number , pu.user_id, pu.username, pu.suspended, pp.ATTRIBUTE1 GGI
from per_users pu , per_all_people_f papf, per_persons pp
where pu.person_id = papf.person_id
and pp.person_id = papf.person_id
and trunc(sysdate) between papf.effective_start_date and papf.effective_end_date
select haou.name from hr_all_organization_units haou
where haou.organization_id = AOR.BUSINESS_UNIT_ID
and trunc(sysdate) between haou.effective_start_date AND haou.effective_end_date
-------------------------------------------------------------------------------------------------
SELECT
pn.DISPLAY_NAME,
pall.PERSON_NUMBER,
asg.ASSIGNMENT_NUMBER,
pp.ATTRIBUTE1 GGI,
aor.ASG_RESPONSIBILITY_ID,
REPLACE(REPLACE (aor.RESPONSIBILITY_NAME, CHAR(10), ''), char(13),'')
trim(aor.RESPONSIBILITY_NAME) RESPONSIBILITY_NAME,
aor.INCLUDE_TOP_HIER_NODE,
aor.ASSIGNMENT_ID,
aor.PERSON_ID,
aor.START_DATE,
aor.END_DATE,
aor.RESPONSIBILITY_TYPE ,
aor.STATUS,
aor.ENTERPRISE_ID,
aor.ORGANIZATION_TREE_CODE,
aor.TOP_ORGANIZATION_ID,
(select haou.name from hr_all_organization_units haou
where haou.organization_id = AOR.TOP_ORGANIZATION_ID
and trunc(sysdate) between haou.effective_start_date AND haou.effective_end_date) TOP_ORGANIZATION,
(select hac.CLASSIFICATION_CODE
from HR_ORG_UNIT_CLASSIFICATIONS_F HAC
where HAC.organization_id = aor.TOP_ORGANIZATION_ID
AND trunc(sysdate) BETWEEN hac.EFFECTIVE_START_DATE AND hac.EFFECTIVE_END_DATE 
) TOP_ORG_CLASSIFICATION_CODE,
aor.COUNTRY,
aor.BUSINESS_UNIT_ID,
(select haou1.name from hr_all_organization_units haou1
where haou1.organization_id = AOR.BUSINESS_UNIT_ID
and trunc(sysdate) between haou1.effective_start_date AND haou1.effective_end_date) BUSINESS_UNIT_NAME,
aor.LEGAL_ENTITY_ID,
(select haou2.name from hr_all_organization_units haou2
where haou2.organization_id = AOR.LEGAL_ENTITY_ID
and trunc(sysdate) between haou2.effective_start_date AND haou2.effective_end_date) LEGAL_ENTITY_NAME,
aor.WORK_CONTACTS_FLAG,
aor.TEMPLATE_ID,
aor.HIERARCHY_TYPE,
aor.USAGE
FROM PER_ASG_RESPONSIBILITIES aor
JOIN PER_PERSON_NAMES_F pn ON aor.PERSON_ID=pn.PERSON_ID and TRUNC(sysdate) BETWEEN pn.effective_start_date AND pn.effective_end_date
JOIN PER_ALL_PEOPLE_F pall ON aor.PERSON_ID=pall.PERSON_ID and TRUNC(sysdate) BETWEEN pall.effective_start_date AND pall.effective_end_date
JOIN PER_ALL_ASSIGNMENTS_M asg ON aor.PERSON_ID=asg.PERSON_ID and TRUNC(sysdate) BETWEEN asg.effective_start_date AND asg.effective_end_date
JOIN per_persons pp on aor.PERSON_ID=pp.PERSON_ID
JOIN PER_PERIODS_OF_SERVICE ppos ON aor.PERSON_ID=PPOS.PERSON_ID and asg.PERIOD_OF_SERVICE_ID = ppos.PERIOD_OF_SERVICE_ID and PPOS.PRIMARY_FLAG = 'Y' and (PPOS.ACTUAL_TERMINATION_DATE is null or  TRUNC(sysdate) BETWEEN ppos.date_start and ppos.ACTUAL_TERMINATION_DATE)
WHERE pn.NAME_TYPE='GLOBAL'
AND asg.ASSIGNMENT_TYPE IN ('E','C','N','P')
AND pall.PERSON_NUMBER = '20000015889'
and aor.RESPONSIBILITY_NAME like '%'
and aor.ASG_RESPONSIBILITY_ID = 300000033449649
 ------------------------------------------------------------------------------------
select 'MERGE|OrganizationTreeNode|PER_ORG_TREE_STRUCTURE|SG_MOCK3_ORG_TREE|SG Mock 3 Org Tree V1|' || haotl.name || '|DEPARTMENT|||' || fss.set_name || '|FUN_BUSINESS_UNIT|' AA
FROM
HR_ORG_UNIT_CLASSIFICATIONS_F hac,
HR_ALL_ORGANIZATION_UNITS_F hao,
HR_ORGANIZATION_UNITS_F_TL haotl,
FND_SETID_SETS FSS
WHERE hao.ORGANIZATION_ID = hac.ORGANIZATION_ID 
AND hao.ORGANIZATION_ID = haotl.ORGANIZATION_ID 
AND hao.EFFECTIVE_START_DATE BETWEEN hac.EFFECTIVE_START_DATE AND hac.EFFECTIVE_END_DATE 
(
select hac.CLASSIFICATION_CODE
from hr_all_organization_units haou, HR_ORG_UNIT_CLASSIFICATIONS_F HAC
where haou.organization_id = HAC.organization_id
and trunc(sysdate) between haou.effective_start_date AND haou.effective_end_date
AND haou.EFFECTIVE_START_DATE BETWEEN hac.EFFECTIVE_START_DATE AND hac.EFFECTIVE_END_DATE 
AOR.TOP_ORGANIZATION_ID
select * from HR_ORG_UNIT_CLASSIFICATIONS_F
)
--------------------------
SELECT
PN.DISPLAY_NAME,
PALL.PERSON_NUMBER,
(SELECT HAOU0.NAME FROM HR_ALL_ORGANIZATION_UNITS HAOU0
WHERE HAOU0.ORGANIZATION_ID = ASG.LEGAL_ENTITY_ID 
AND TRUNC(SYSDATE) BETWEEN HAOU0.EFFECTIVE_START_DATE AND HAOU0.EFFECTIVE_END_DATE) USERS_LEGAL_EMPLOYER,
ASG.LEGISLATION_CODE USERS_COUNTRY,
(SELECT HAOU3.NAME FROM HR_ALL_ORGANIZATION_UNITS HAOU3
WHERE HAOU3.ORGANIZATION_ID = ASG.BUSINESS_UNIT_ID 
AND TRUNC(SYSDATE) BETWEEN HAOU3.EFFECTIVE_START_DATE AND HAOU3.EFFECTIVE_END_DATE) USERS_BUSINESS_UNIT,
ASG.ASSIGNMENT_NUMBER,
PP.ATTRIBUTE1 GGI,
AOR.ASG_RESPONSIBILITY_ID,
TRIM(AOR.RESPONSIBILITY_NAME) RESPONSIBILITY_NAME,
AOR.INCLUDE_TOP_HIER_NODE,
AOR.ASSIGNMENT_ID,
AOR.PERSON_ID,
AOR.START_DATE,
AOR.END_DATE,
AOR.RESPONSIBILITY_TYPE ,
AOR.STATUS,
AOR.ENTERPRISE_ID,
AOR.ORGANIZATION_TREE_CODE,
AOR.TOP_ORGANIZATION_ID,
(SELECT HAOU.NAME FROM HR_ALL_ORGANIZATION_UNITS HAOU
WHERE HAOU.ORGANIZATION_ID = AOR.TOP_ORGANIZATION_ID
AND TRUNC(SYSDATE) BETWEEN HAOU.EFFECTIVE_START_DATE AND HAOU.EFFECTIVE_END_DATE) TOP_ORGANIZATION,
(SELECT HAC.CLASSIFICATION_CODE
FROM HR_ORG_UNIT_CLASSIFICATIONS_F HAC
WHERE HAC.ORGANIZATION_ID = AOR.TOP_ORGANIZATION_ID
AND TRUNC(SYSDATE) BETWEEN HAC.EFFECTIVE_START_DATE AND HAC.EFFECTIVE_END_DATE 
) TOP_ORG_CLASSIFICATION_CODE,
AOR.COUNTRY,
AOR.BUSINESS_UNIT_ID,
(SELECT HAOU1.NAME FROM HR_ALL_ORGANIZATION_UNITS HAOU1
WHERE HAOU1.ORGANIZATION_ID = AOR.BUSINESS_UNIT_ID
AND TRUNC(SYSDATE) BETWEEN HAOU1.EFFECTIVE_START_DATE AND HAOU1.EFFECTIVE_END_DATE) BUSINESS_UNIT_NAME,
AOR.LEGAL_ENTITY_ID,
(SELECT HAOU2.NAME FROM HR_ALL_ORGANIZATION_UNITS HAOU2
WHERE HAOU2.ORGANIZATION_ID = AOR.LEGAL_ENTITY_ID
AND TRUNC(SYSDATE) BETWEEN HAOU2.EFFECTIVE_START_DATE AND HAOU2.EFFECTIVE_END_DATE) LEGAL_ENTITY_NAME,
AOR.WORK_CONTACTS_FLAG,
AOR.TEMPLATE_ID,
AOR.HIERARCHY_TYPE,
AOR.USAGE
FROM PER_ASG_RESPONSIBILITIES AOR
JOIN PER_PERSON_NAMES_F PN ON AOR.PERSON_ID=PN.PERSON_ID AND TRUNC(SYSDATE) BETWEEN PN.EFFECTIVE_START_DATE AND PN.EFFECTIVE_END_DATE
JOIN PER_ALL_PEOPLE_F PALL ON AOR.PERSON_ID=PALL.PERSON_ID AND TRUNC(SYSDATE) BETWEEN PALL.EFFECTIVE_START_DATE AND PALL.EFFECTIVE_END_DATE
JOIN PER_ALL_ASSIGNMENTS_M ASG ON AOR.PERSON_ID=ASG.PERSON_ID AND TRUNC(SYSDATE) BETWEEN ASG.EFFECTIVE_START_DATE AND ASG.EFFECTIVE_END_DATE
JOIN PER_PERSONS PP ON AOR.PERSON_ID=PP.PERSON_ID
JOIN PER_PERIODS_OF_SERVICE PPOS ON AOR.PERSON_ID=PPOS.PERSON_ID AND ASG.PERIOD_OF_SERVICE_ID = PPOS.PERIOD_OF_SERVICE_ID AND PPOS.PRIMARY_FLAG = 'Y' AND (PPOS.ACTUAL_TERMINATION_DATE IS NULL OR  TRUNC(SYSDATE) BETWEEN PPOS.DATE_START AND PPOS.ACTUAL_TERMINATION_DATE)
WHERE PN.NAME_TYPE='GLOBAL'
AND ASG.ASSIGNMENT_TYPE IN ('E','C','N','P')
--AND PALL.PERSON_NUMBER = '20000101051'
--AND AOR.RESPONSIBILITY_NAME LIKE 'XXX%'
--AND AOR.ASG_RESPONSIBILITY_ID = 300000033449649
--------------------------------------------------------------------------------------------------------------------
select paam.assignment_number, padd.* 
from ANC_PER_ABS_DAILY_DTLS padd, per_all_assignments_m paam
where paam.assignment_id = padd.assignment_id
and trunc(sysdate) between paam.effective_start_date and paam.Effective_end_date
and paam.assignment_status_type_id = 1
and primary_flag = 'Y'
and paam.legislation_code = 'RO'
and paam.assignment_number != 'E20000100563'
SG France Customization Role
select distinct ASSIGNMENT_NUMBER, AUDIT_ACTION_TYPE_ from per_all_assignments_M_
where LEGISLATION_CODE = 'FR'
and trunc(LAST_UPDATE_DATE) = TO_date('08102025', 'ddmmyyyy')
and DATE_PROBATION_END is not null
-------------------------------------------------------------------------------------------------------------------
select count(*) -265 AA
--papf.person_number , pu.user_id, pu.username, pu.suspended, pea.EMAIL_TYPE, pea.EMAIL_ADDRESS, pp.ATTRIBUTE1 GGI, paam.assignment_status_type_id, paam.assignment_TYPE, pu.last_update_date, pu.last_updated_by
from per_users pu , per_all_people_f papf, per_all_assignments_m paam, PER_EMAIL_ADDRESSES PEA, per_persons pp
where pu.person_id = papf.person_id
and trunc(sysdate) between papf.effective_start_date and papf.effective_end_date
and paam.person_id = papf.person_id
and trunc(sysdate) between paam.effective_start_date and paam.effective_end_date
and paam.person_id = pea.person_id
and paam.legislation_code = 'RO'
and pea.EMAIL_TYPE = 'W1'
and paam.PRIMARY_ASSIGNMENT_FLAG = 'Y'
and paam.person_id = pp.person_id
--and pu.last_updated_by != 'BATCHUSER1'
and trunc(pu.last_update_date) != trunc(sysdate)
--order by pu.last_update_date desc
-------------------------------------------------------------------------------------------------------------------------
SELECT
B.ROWID ROW_ID,
B.TREE_STRUCTURE_CODE,
B.TREE_CODE,
B.TREE_VERSION_ID,
B.SOURCE_TREE_VERSION_ID,
B.STATUS,
B.EFFECTIVE_START_DATE,
B.EFFECTIVE_END_DATE,
B.LAST_VALIDATION_DATE,
B.CHANGED_SINCE_VALIDATION,
B.LEVEL_COUNT,
B.NODE_COUNT,
B.LOCKED_BY,
B.LOCK_DATE,
B.CREATED_BY,
B.CREATION_DATE,
B.LAST_UPDATED_BY,
B.LAST_UPDATE_DATE,
B.LAST_UPDATE_LOGIN,
B.LAST_VALIDATION_RESULT_ID,
B.LAST_VALIDATION_RESULT,
T.TREE_VERSION_NAME,
T.DESCRIPTION,
T.VERSION_COMMENT
FROM
FND_TREE_VERSION B,
FND_TREE_VERSION_TL T
WHERE B.TREE_STRUCTURE_CODE = T.TREE_STRUCTURE_CODE
AND B.TREE_CODE = T.TREE_CODE
AND B.TREE_VERSION_ID = T.TREE_VERSION_ID
AND T.LANGUAGE = USERENV('LANG')
and B.TREE_CODE = 'FR-SGPM'
SG Romania Assignment Local
Work Place Type
Fixed
Default must be set to Zero
--------------------------------------
select papf.person_number, pp.* from per_phones pp, per_all_people_f papf
where pp.legislation_code is null
--and pp.phone_number = '9686931579'
and pp.person_id = papf.person_id
and trunc(sysdate) between papf.effective_start_date and papf.effective_end_Date
--and papf.person_number = '20000005499'
and trunc(pp.CREATION_DATE) = to_DATE('2024-09-24', 'YYYY-MM-DD')
----------------------------
select papf.person_number PPNO, papf.creation_date PAPFCREATION, pAPF.* from per_phones pp, per_all_people_f papf
where pp.legislation_code is null
and pp.phone_number = '9686931579'
and pp.person_id = papf.person_id
and trunc(sysdate) between papf.effective_start_date and papf.effective_end_Date
--and papf.person_number = '20000005499'
--and trunc(pp.CREATION_DATE) = to_DATE('2024-09-24', 'YYYY-MM-DD')
and trunc(papf.CREATION_DATE) = to_DATE('2024-09-05', 'YYYY-MM-DD')
------------------------------------------------------------------------
SELECT 
FN.USER_NAME "User_Name"
,TO_CHAR(FN.FIRST_CONNECT,'yyyy-mm-dd')  "First_Connect_Date"
,TO_CHAR(FN.FIRST_CONNECT,'hh24:mi:ss') "First_Connect_Time"
,TO_CHAR(FN.LAST_CONNECT,'yyyy-mm-dd')  "Last_Connect_Date" 
,TO_CHAR(FN.LAST_CONNECT,'hh24:mi:ss')  "Last_Connect_Time" 
,TO_CHAR(FN.LAST_UPDATE_DATE,'yyyy-mm-dd') "Last_Update_Date"
,TO_CHAR(FN.LAST_UPDATE_DATE,'hh24:mi:ss') "Last_Update_Time"
,FN.NLS_LANGUAGE "User_Language"
,PER_EXTRACT_UTILITY.GET_DECODED_LOOKUP('PER_PERIOD_TYPE',PPS.PERIOD_TYPE) "Worker_Type"
FROM FND_SESSIONS FN
     ,PER_USERS PU
 ,PER_ASSIGNMENT_SECURED_LIST_V PAA
 ,PER_PERIODS_OF_SERVICE PPS
WHERE 
FN.USER_GUID = PU.USER_GUID
AND PU.PERSON_ID = PAA.PERSON_ID
AND PAA.PERIOD_OF_SERVICE_ID = PPS.PERIOD_OF_SERVICE_ID
AND PAA.ASSIGNMENT_TYPE IN ('C','E')
and paa.legislation_code = 'RO'
and (pps.ACTUAL_TERMINATION_DATE is null OR trunc(sysdate) between pps.DATE_START and pps.ACTUAL_TERMINATION_DATE)
and trunc(sysdate) between paa.effective_Start_date and paa.effective_end_date
AND FN.USER_NAME NOT IN
('FAAdmin'
,'FUSION_APPS_AMX_APPID'
,'FUSION_APPS_ATK_ADF_APPID'
,'FUSION_APPS_ATK_UMS_APPID'
,'FUSION_APPS_BI_APPID'
,'FUSION_APPS_BI_SYSTEM_APPID'
,'FUSION_APPS_CRM_ESS_APPID'
,'FUSION_APPS_CRM_SOA_APPID'
,'FUSION_APPS_FIN_ESS_APPID'
,'FUSION_APPS_FIN_ODI_ESS_APPID'
,'FUSION_APPS_FIN_SOA_APPID'
,'FUSION_APPS_FSCM_SES_CRAWL_APPID'
,'FUSION_APPS_GRC_APPID'
,'FUSION_APPS_HCM_ADF_LDAP_APPID'
,'FUSION_APPS_HCM_ESS_APPID'
,'FUSION_APPS_HCM_ESS_LOADER_APPID'
,'FUSION_APPS_HCM_SEMSEARCH_APPID'
,'FUSION_APPS_HCM_SES_CRAWL_APPID'
,'FUSION_APPS_HCM_SOA_APPID'
,'FUSION_APPS_PRC_ESS_APPID'
,'FUSION_APPS_PROV_PATCH_APPID'
,'FUSION_APPS_PSC_APPID'
,'FUSION_APPS_SEARCH_APPID'
,'anonymous'
,'em_monitoring'
,'opcon.user'
,'rats_monitor'
)
ORDER BY FN.USER_NAME
,TO_CHAR(FN.FIRST_CONNECT,'yyyy-mm-dd')  
,TO_CHAR(FN.FIRST_CONNECT,'hh24:mi:ss') 
,TO_CHAR(FN.LAST_CONNECT,'yyyy-mm-dd')  
,TO_CHAR(FN.LAST_CONNECT,'hh24:mi:ss')
------------------------------------------------------------------------
select
HTH.TRANSACTION_ID,
HTH.MODULE_IDENTIFIER,
HTH.PROCESS_OWNER,
HTH.SECTION_DISPLAY_NAME,
'XX' CREATED_BY,
HTH.CREATION_DATE,
HTH.LAST_UPDATE_DATE,
'YY' LAST_UPDATED_BY, 
HTD.STATUS
from hrc_txn_header HTH,
HRC_TXN_DATA HTD
where family = 'HCM'
and HTD.Transaction_id = HTH.Transaction_id
and hth.creation_date > to_date('03122023','DDMMYYYY')
--------------------------------------------------------------------------
SELECT
HTH.TRANSACTION_ID,
HTH.MODULE_IDENTIFIER,
HTH.PROCESS_OWNER,
HTH.SECTION_DISPLAY_NAME,
HTH.CREATED_BY,
HTH.CREATION_DATE,
HTH.LAST_UPDATE_DATE,
HTH.LAST_UPDATED_BY, 
HTD.STATUS,
HTD.STATE,
HTH.OBJECT,
HTH.SUBJECT
FROM HRC_TXN_HEADER HTH,
HRC_TXN_DATA HTD,
PER_USERS PU,
PER_ALL_ASSIGNMENTS_M PAAM
WHERE FAMILY = 'HCM'
AND HTD.TRANSACTION_ID = HTH.TRANSACTION_ID
AND INITIATOR_USER_ID =  PU.person_id
--AND PU.ACTIVE_FLAG = 'Y' 
--AND PU.SUSPENDED = 'N'
AND PU.PERSON_ID = PAAM.PERSON_ID 
AND PAAM.ASSIGNMENT_TYPE IN ('C','E')
AND PAAM.EFFECTIVE_LATEST_CHANGE='Y'
AND PAAM.LEGISLATION_CODE = 'RO'
AND TRUNC(SYSDATE) BETWEEN PAAM.EFFECTIVE_START_DATE AND PAAM.EFFECTIVE_END_DATE
--------------------------------------------------------------------------
select paa.* 
from PER_ABSENCE_ATTENDANCES paa, per_all_people_f papf
where papf.person_id = paa.person_id
and trunc(sysdate) between papf.effective_start_date and papf.effective_end_Date
and papf.person_number = '20000100729'
------------------------------------------------------------------------
SELECT HAOTL.NAME tOP_oRG_NAME, PAR.*
FROM PER_ALL_PEOPLE_F PAPF, PER_ALL_ASSIGNMENTS_M PAAM, PER_PERIODS_OF_SERVICE PPOS , PER_ASG_RESPONSIBILITIES PAR, HR_ORGANIZATION_UNITS_F_TL HAOTL 
WHERE PAPF.PERSON_ID = PPOS.PERSON_ID
AND PAR.PERSON_ID = PPOS.PERSON_ID
AND PAAM.ASSIGNMENT_ID = PAR.ASSIGNMENT_ID
AND  PPOS.PERIOD_OF_SERVICE_ID = PAAM.PERIOD_OF_SERVICE_ID
AND  PAAM.ASSIGNMENT_STATUS_TYPE = 'ACTIVE'
AND  PAAM.EFFECTIVE_LATEST_CHANGE = 'Y'
AND  PAAM.PRIMARY_FLAG = 'Y'
and paam.legislation_code = 'CL'
--AND  PAPF.PERSON_NUMBER IN ('80900002216','80900002217','80900002218','80900002219','80900002220') 
AND TRUNC(SYSDATE)  BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.EFFECTIVE_END_DATE
AND TRUNC(SYSDATE)  BETWEEN PAAM.EFFECTIVE_START_DATE AND PAAM.EFFECTIVE_END_DATE
and trunc(sysdate) between HAOTL.effective_start_date and HAOTL.effective_end_date
AND HAOTL.LANGUAGE = 'US'
and HAOTL.organization_id = PAR.TOP_ORGANIZATION_ID
and PAR.responsibility_type = 'SG_HRBP'
------------------------------------------------------------------------
select distinct RESPONSIBILITY_NAME from 
(
SELECT
PN.DISPLAY_NAME,
PALL.PERSON_NUMBER,
(SELECT HAOU0.NAME FROM HR_ALL_ORGANIZATION_UNITS HAOU0
WHERE HAOU0.ORGANIZATION_ID = ASG.LEGAL_ENTITY_ID 
AND TRUNC(SYSDATE) BETWEEN HAOU0.EFFECTIVE_START_DATE AND HAOU0.EFFECTIVE_END_DATE) USERS_LEGAL_EMPLOYER,
ASG.LEGISLATION_CODE USERS_COUNTRY,
(SELECT HAOU3.NAME FROM HR_ALL_ORGANIZATION_UNITS HAOU3
WHERE HAOU3.ORGANIZATION_ID = ASG.BUSINESS_UNIT_ID 
AND TRUNC(SYSDATE) BETWEEN HAOU3.EFFECTIVE_START_DATE AND HAOU3.EFFECTIVE_END_DATE) USERS_BUSINESS_UNIT,
ASG.ASSIGNMENT_NUMBER,
PP.ATTRIBUTE1 GGI,
AOR.ASG_RESPONSIBILITY_ID,
TRIM(AOR.RESPONSIBILITY_NAME) RESPONSIBILITY_NAME,
AOR.INCLUDE_TOP_HIER_NODE,
AOR.ASSIGNMENT_ID,
AOR.PERSON_ID,
AOR.START_DATE,
AOR.END_DATE,
AOR.RESPONSIBILITY_TYPE ,
AOR.STATUS,
AOR.ENTERPRISE_ID,
AOR.ORGANIZATION_TREE_CODE,
AOR.TOP_ORGANIZATION_ID,
(SELECT HAOU.NAME FROM HR_ALL_ORGANIZATION_UNITS HAOU
WHERE HAOU.ORGANIZATION_ID = AOR.TOP_ORGANIZATION_ID
AND TRUNC(SYSDATE) BETWEEN HAOU.EFFECTIVE_START_DATE AND HAOU.EFFECTIVE_END_DATE) TOP_ORGANIZATION,
(SELECT HAC.CLASSIFICATION_CODE
FROM HR_ORG_UNIT_CLASSIFICATIONS_F HAC
WHERE HAC.ORGANIZATION_ID = AOR.TOP_ORGANIZATION_ID
AND TRUNC(SYSDATE) BETWEEN HAC.EFFECTIVE_START_DATE AND HAC.EFFECTIVE_END_DATE 
) TOP_ORG_CLASSIFICATION_CODE,
AOR.COUNTRY,
AOR.BUSINESS_UNIT_ID,
(SELECT HAOU1.NAME FROM HR_ALL_ORGANIZATION_UNITS HAOU1
WHERE HAOU1.ORGANIZATION_ID = AOR.BUSINESS_UNIT_ID
AND TRUNC(SYSDATE) BETWEEN HAOU1.EFFECTIVE_START_DATE AND HAOU1.EFFECTIVE_END_DATE) BUSINESS_UNIT_NAME,
AOR.LEGAL_ENTITY_ID,
(SELECT HAOU2.NAME FROM HR_ALL_ORGANIZATION_UNITS HAOU2
WHERE HAOU2.ORGANIZATION_ID = AOR.LEGAL_ENTITY_ID
AND TRUNC(SYSDATE) BETWEEN HAOU2.EFFECTIVE_START_DATE AND HAOU2.EFFECTIVE_END_DATE) LEGAL_ENTITY_NAME,
AOR.WORK_CONTACTS_FLAG,
AOR.TEMPLATE_ID,
AOR.HIERARCHY_TYPE,
AOR.USAGE
FROM PER_ASG_RESPONSIBILITIES AOR
JOIN PER_PERSON_NAMES_F PN ON AOR.PERSON_ID=PN.PERSON_ID AND TRUNC(SYSDATE) BETWEEN PN.EFFECTIVE_START_DATE AND PN.EFFECTIVE_END_DATE
JOIN PER_ALL_PEOPLE_F PALL ON AOR.PERSON_ID=PALL.PERSON_ID AND TRUNC(SYSDATE) BETWEEN PALL.EFFECTIVE_START_DATE AND PALL.EFFECTIVE_END_DATE
JOIN PER_ALL_ASSIGNMENTS_M ASG ON AOR.PERSON_ID=ASG.PERSON_ID AND TRUNC(SYSDATE) BETWEEN ASG.EFFECTIVE_START_DATE AND ASG.EFFECTIVE_END_DATE
JOIN PER_PERSONS PP ON AOR.PERSON_ID=PP.PERSON_ID
JOIN PER_PERIODS_OF_SERVICE PPOS ON AOR.PERSON_ID=PPOS.PERSON_ID AND ASG.PERIOD_OF_SERVICE_ID = PPOS.PERIOD_OF_SERVICE_ID AND PPOS.PRIMARY_FLAG = 'Y' AND (PPOS.ACTUAL_TERMINATION_DATE IS NULL OR  TRUNC(SYSDATE) BETWEEN PPOS.DATE_START AND PPOS.ACTUAL_TERMINATION_DATE)
WHERE PN.NAME_TYPE='GLOBAL'
AND ASG.ASSIGNMENT_TYPE IN ('E','C','N','P')
and AOR.RESPONSIBILITY_TYPE = 'SG_HRSSC'
and HIERARCHY_TYPE != 'AOR_ORG'
) AA
--where AA.
--AND PALL.PERSON_NUMBER = '20000101051'
--AND AOR.RESPONSIBILITY_NAME LIKE 'XXX%'
--AND AOR.ASG_RESPONSIBILITY_ID = 300000033449649
--AND AOR.RESPONSIBILITY_TYPE like 'SG%HR%'
---------------------------------------------
select * from PER_ASG_RESPONSIBILITIES
where -- ASG_RESPONSIBILITY_ID  = 300000642217171
 STATUS = 'Active'
and RESPONSIBILITY_TYPE = 'SG_HRSSC'
and CREATION_DATE > to_date('2025-11-01', 'yyyy-mm-dd')
and ASG_RESPONSIBILITY_ID  = 300000642217171
select * from PER_ASG_RESPONSIBILITIES
where ASG_RESPONSIBILITY_ID 
(300000642004840,300000642004842, -- Old records, older version of Org tree hierachy id is present
300000618872939, 300000604098341 -- Newer version of Org tree hierachy id is present (Making this inactive solves the issue)
) 
PER Load All Organization Hierarchy Versions
KB206272
SELECT *
FROM per_org_structure_elements pose
,per_org_structure_versions posv
WHERE pose.org_structure_version_id = posv.org_structure_version_id
AND (
pose.organization_id_child =<pass organization_id with issue>
OR pose.organization_id_parent =<pass organization_id with issue>
);
----------------------------
select papf.person_number PPNO, papf.creation_date PAPFCREATION, pAPF.* from per_phones pp, per_all_people_f papf
where pp.legislation_code is null
and pp.phone_number = '9686931579'
and pp.person_id = papf.person_id
and trunc(sysdate) between papf.effective_start_date and papf.effective_end_Date
--and papf.person_number = '20000005499'
--and trunc(pp.CREATION_DATE) = to_DATE('2024-09-24', 'YYYY-MM-DD')
and trunc(papf.CREATION_DATE) = to_DATE('2024-09-05', 'YYYY-MM-DD')
------------------------------------------------------------------------
SELECT
PN.DISPLAY_NAME,
PALL.PERSON_NUMBER,
(SELECT HAOU0.NAME FROM HR_ALL_ORGANIZATION_UNITS HAOU0
WHERE HAOU0.ORGANIZATION_ID = ASG.LEGAL_ENTITY_ID 
AND TRUNC(SYSDATE) BETWEEN HAOU0.EFFECTIVE_START_DATE AND HAOU0.EFFECTIVE_END_DATE) USERS_LEGAL_EMPLOYER,
ASG.LEGISLATION_CODE USERS_COUNTRY,
(SELECT HAOU3.NAME FROM HR_ALL_ORGANIZATION_UNITS HAOU3
WHERE HAOU3.ORGANIZATION_ID = ASG.BUSINESS_UNIT_ID 
AND TRUNC(SYSDATE) BETWEEN HAOU3.EFFECTIVE_START_DATE AND HAOU3.EFFECTIVE_END_DATE) USERS_BUSINESS_UNIT,
ASG.ASSIGNMENT_NUMBER,
PP.ATTRIBUTE1 GGI,
AOR.ASG_RESPONSIBILITY_ID,
TRIM(AOR.RESPONSIBILITY_NAME) RESPONSIBILITY_NAME,
AOR.INCLUDE_TOP_HIER_NODE,
AOR.ASSIGNMENT_ID,
AOR.PERSON_ID,
AOR.START_DATE,
AOR.END_DATE,
AOR.RESPONSIBILITY_TYPE ,
AOR.STATUS,
AOR.ENTERPRISE_ID,
AOR.ORGANIZATION_TREE_CODE,
AOR.TOP_ORGANIZATION_ID,
(SELECT HAOU.NAME FROM HR_ALL_ORGANIZATION_UNITS HAOU
WHERE HAOU.ORGANIZATION_ID = AOR.TOP_ORGANIZATION_ID
AND TRUNC(SYSDATE) BETWEEN HAOU.EFFECTIVE_START_DATE AND HAOU.EFFECTIVE_END_DATE) TOP_ORGANIZATION,
(SELECT HAC.CLASSIFICATION_CODE
FROM HR_ORG_UNIT_CLASSIFICATIONS_F HAC
WHERE HAC.ORGANIZATION_ID = AOR.TOP_ORGANIZATION_ID
AND TRUNC(SYSDATE) BETWEEN HAC.EFFECTIVE_START_DATE AND HAC.EFFECTIVE_END_DATE 
) TOP_ORG_CLASSIFICATION_CODE,
AOR.COUNTRY,
AOR.BUSINESS_UNIT_ID,
(SELECT HAOU1.NAME FROM HR_ALL_ORGANIZATION_UNITS HAOU1
WHERE HAOU1.ORGANIZATION_ID = AOR.BUSINESS_UNIT_ID
AND TRUNC(SYSDATE) BETWEEN HAOU1.EFFECTIVE_START_DATE AND HAOU1.EFFECTIVE_END_DATE) BUSINESS_UNIT_NAME,
AOR.LEGAL_ENTITY_ID,
(SELECT HAOU2.NAME FROM HR_ALL_ORGANIZATION_UNITS HAOU2
WHERE HAOU2.ORGANIZATION_ID = AOR.LEGAL_ENTITY_ID
AND TRUNC(SYSDATE) BETWEEN HAOU2.EFFECTIVE_START_DATE AND HAOU2.EFFECTIVE_END_DATE) LEGAL_ENTITY_NAME,
AOR.WORK_CONTACTS_FLAG,
AOR.TEMPLATE_ID,
AOR.HIERARCHY_TYPE,
AOR.USAGE
FROM PER_ASG_RESPONSIBILITIES AOR
JOIN PER_PERSON_NAMES_F PN ON AOR.PERSON_ID=PN.PERSON_ID AND TRUNC(SYSDATE) BETWEEN PN.EFFECTIVE_START_DATE AND PN.EFFECTIVE_END_DATE
JOIN PER_ALL_PEOPLE_F PALL ON AOR.PERSON_ID=PALL.PERSON_ID AND TRUNC(SYSDATE) BETWEEN PALL.EFFECTIVE_START_DATE AND PALL.EFFECTIVE_END_DATE
JOIN PER_ALL_ASSIGNMENTS_M ASG ON AOR.PERSON_ID=ASG.PERSON_ID AND TRUNC(SYSDATE) BETWEEN ASG.EFFECTIVE_START_DATE AND ASG.EFFECTIVE_END_DATE
JOIN PER_PERSONS PP ON AOR.PERSON_ID=PP.PERSON_ID
JOIN PER_PERIODS_OF_SERVICE PPOS ON AOR.PERSON_ID=PPOS.PERSON_ID AND ASG.PERIOD_OF_SERVICE_ID = PPOS.PERIOD_OF_SERVICE_ID AND PPOS.PRIMARY_FLAG = 'Y' AND (PPOS.ACTUAL_TERMINATION_DATE IS NULL OR  TRUNC(SYSDATE) BETWEEN PPOS.DATE_START AND PPOS.ACTUAL_TERMINATION_DATE)
WHERE PN.NAME_TYPE='GLOBAL'
AND ASG.ASSIGNMENT_TYPE IN ('E','C','N','P')
--AND PALL.PERSON_NUMBER = '20000101051'
--AND AOR.RESPONSIBILITY_NAME LIKE 'XXX%'
--AND AOR.ASG_RESPONSIBILITY_ID = 300000033449649
-------------------------------------------------------------------------------------------------------
select 
--paam.assignment_number,  pawm.UNIT, pawm.VALUE
pawm.UNIT, count (pawm.VALUE)
from per_all_assignments_m paam, PER_ASSIGN_WORK_MEASURES_F pawm
where paam.legislation_code = 'FR'
and paam.assignment_id = pawm.assignment_id
and paam.effective_start_date = pawm.effective_start_date
and paam.effective_end_date = pawm.effective_end_date
and pawm.UNIT = 'FTE'
and trunc(sysdate) between paam.effective_start_date and paam.effective_end_date
and pawm.VALUE != 1
group by pawm.UNIT
-------------------------------------------------------------------------------------------------------
select pat.* from per_allocated_checklists pac, per_allocated_tasks pat
where person_id in (
select distinct (person_id) from per_all_People_f where person_number = '20000515955'
)
and pat.allocated_checklist_id = pac.allocated_checklist_id
------------------------------------------------------------------------------
--- Custom created DFFs and EFFs
------------------------------------------------------------------------------
select * from fnd_df_segments_b
where 
descriptive_flexfield_code in (
'PER_PERSON_EIT_EFF',
'PER_ORGANIZATION_INFORMATION_EFF',
'PER_POSITIONS_EIT_EFF',
'PER_ASSIGNMENT_EIT_EFF',
'PER_GRADES_DF',
'PER_JOBS_DFF',
'PER_POSITIONS_DFF',
'PER_PERSONS_DFF',
'PER_ASG_DF',
'PER_ORGANIZATION_UNIT_DFF',
'PER_CONTACT_RELSHIPS_DFF',
'PER_DOCUMENTS_OF_RECORD_DFF')
and created_by not like 'SEED_DATA_FROM_APPLICATION'
------------------------------------------------------------------------------
------------------------------------------------------------------------------
--- xx ActionTypes Actions and Reasons
------------------------------------------------------------------------------
SELECT PATB.ACTION_TYPE_ID, PAB.ACTION_ID,
PATB.ACTION_TYPE_CODE,
PATT.MEANING ACTION_TYPE, 
PAB.ACTION_CODE, 
PAT.ACTION_NAME, 
PAB.START_DATE ACTION_START_DATE, 
PAB.END_DATE ACTION_END_DATE,
parb.action_reason_id, 
parb.action_reason_code, 
part.action_reason, 
paru.start_date Reason_start_date , 
paru.end_date reason_end_date,
paru.COUNTRY,
paru.ALL_ROLE
FROM PER_ACTION_TYPES_B PATB, PER_ACTION_TYPES_TL PATT, PER_ACTIONS_B PAB, PER_ACTIONS_TL PAT,
per_action_reasons_b parb, per_action_reasons_tl part, per_action_reason_usages paru
WHERE PATB.ACTION_TYPE_ID = PATT.ACTION_TYPE_ID
AND PATB.ACTION_TYPE_ID = PAB.ACTION_TYPE_ID
AND PAB.ACTION_ID = PAT.ACTION_ID
AND PATT.LANGUAGE = PAT.LANGUAGE
AND PAT.LANGUAGE = 'US'
and paru.action_id = PAB.ACTION_ID
AND parb.action_reason_id = part.action_reason_id
and paru.action_reason_id = part.action_reason_id
and part.language = 'US'
UNION
SELECT PATB.ACTION_TYPE_ID, PAB.ACTION_ID,
PATB.ACTION_TYPE_CODE,
PATT.MEANING ACTION_TYPE, 
PAB.ACTION_CODE, 
PAT.ACTION_NAME, 
PAB.START_DATE ACTION_START_DATE, 
PAB.END_DATE ACTION_END_DATE,
null action_reason_id, 
'' action_reason_code, 
'' action_reason, 
PAB.START_DATE Reason_start_date , 
PAB.END_DATE Reason_end_date,
'' COUNTRY,
'' ALL_ROLE
FROM PER_ACTION_TYPES_B PATB, PER_ACTION_TYPES_TL PATT, PER_ACTIONS_B PAB, PER_ACTIONS_TL PAT
WHERE PATB.ACTION_TYPE_ID = PATT.ACTION_TYPE_ID
AND PATB.ACTION_TYPE_ID = PAB.ACTION_TYPE_ID
AND PAB.ACTION_ID = PAT.ACTION_ID
AND PATT.LANGUAGE = PAT.LANGUAGE
AND PAT.LANGUAGE = 'US'
------------------------------------------------------------------------------
------------------------------------------------------------------------------
--- Action names, translations and dates
------------------------------------------------------------------------------
SELECT 
PATB.ACTION_TYPE_ID, PATB.ACTION_TYPE_CODE, PATT.MEANING ACTION_TYPE, PAT.ACTION_ID, PAB.ACTION_CODE,
PAT.ACTION_NAME ENGLISH_ACTION_NAME,
patF.action_name French_Action_name,
patRO.action_name Romanian_Action_name,
patD.action_name German_Action_name,
patE.action_name Spanish_Action_name,
patFRC.action_name Canadian_French_Action_name,
patI.action_name Italian_Action_name,
patNL.action_name Dutch_Action_name,
patPTB.action_name Brazilian_Portuguese_Action_name,
patTR.action_name Turkish_Action_name,
PAB.START_DATE ACTION_START_DATE, PAB.END_DATE ACTION_END_DATE, 
PAT.CREATED_BY ACTION_CREATED_BY, PAT.CREATION_DATE ACTION_CREATION_DATE, PAT.LAST_UPDATED_BY ACTION_LAST_UPDATED_BY, PAT.LAST_UPDATE_DATE ACTION_LAST_UPDATE_DATE
FROM PER_ACTION_TYPES_B PATB, PER_ACTION_TYPES_TL PATT, PER_ACTIONS_B PAB, 
PER_ACTIONS_TL PAT,
per_actions_tl PATf,
per_actions_tl PATRO,
per_actions_tl PATD,
per_actions_tl PATE,
per_actions_tl PATFRC,
per_actions_tl PATI,
per_actions_tl PATNL,
per_actions_tl PATPTB,
per_actions_tl PATTR
WHERE PATB.ACTION_TYPE_ID = PATT.ACTION_TYPE_ID
AND PATB.ACTION_TYPE_ID = PAB.ACTION_TYPE_ID
AND PATT.LANGUAGE = 'US'
AND PAB.ACTION_ID = PAT.ACTION_ID
AND PAT.LANGUAGE = 'US'
and PAB.action_id = patF.action_id
and patF.language ='F'
and PAB.action_id = patRO.action_id
and patRO.language ='RO'
and PAB.action_id = patD.action_id
and patD.language ='D'
and PAB.action_id = patE.action_id
and patE.language ='E'
and PAB.action_id = patFRC.action_id
and patFRC.language ='FRC'
and PAB.action_id = patI.action_id
and patI.language ='I'
and PAB.action_id = patNL.action_id
and patNL.language ='NL'
and PAB.action_id = patPTB.action_id
and patPTB.language ='PTB'
and PAB.action_id = patTR.action_id
and patTR.language ='TR'
------------------------------------------------------------------------------
------------------------------------------------------------------------------
--- xx ActionReasons Translations and Dates
------------------------------------------------------------------------------
select  
'ActionReason' AA,
parb.action_reason_code, 
part.action_reason English_Action_Reason, 
partF.action_reason French_Action_Reason,
partRO.action_reason Romanian_Action_Reason,
partD.action_reason German_Action_Reason,
partE.action_reason Spanish_Action_Reason,
partFRC.action_reason Canadian_French_Action_Reason,
partI.action_reason Italian_Action_Reason,
partNL.action_reason Dutch_Action_Reason,
partPTB.action_reason Brazilian_Portuguese_Action_Reason,
partTR.action_reason Turkish_Action_Reason,
parb.start_date Reason_start_date, 
parb.end_date reason_end_date,
part.CREATED_BY Reason_CREATED_BY, 
part.CREATION_DATE Reason_CREATION_DATE, 
part.LAST_UPDATED_BY Reason_LAST_UPDATED_BY, 
part.LAST_UPDATE_DATE Reason_LAST_UPDATE_DATE
from per_action_reasons_b parb, 
per_action_reasons_tl part,
per_action_reasons_tl partf,
per_action_reasons_tl partRO,
per_action_reasons_tl partD,
per_action_reasons_tl partE,
per_action_reasons_tl partFRC,
per_action_reasons_tl partI,
per_action_reasons_tl partNL,
per_action_reasons_tl partPTB,
per_action_reasons_tl partTR
where parb.action_reason_id = part.action_reason_id
and part.language ='US'
and parb.action_reason_id = partF.action_reason_id
and partF.language ='F'
and parb.action_reason_id = partRO.action_reason_id
and partRO.language ='RO'
and parb.action_reason_id = partD.action_reason_id
and partD.language ='D'
and parb.action_reason_id = partE.action_reason_id
and partE.language ='E'
and parb.action_reason_id = partFRC.action_reason_id
and partFRC.language ='FRC'
and parb.action_reason_id = partI.action_reason_id
and partI.language ='I'
and parb.action_reason_id = partNL.action_reason_id
and partNL.language ='NL'
and parb.action_reason_id = partPTB.action_reason_id
and partPTB.language ='PTB'
and parb.action_reason_id = partTR.action_reason_id
and partTR.language ='TR'
------------------------------------------------------------------------------
------------------------------------------------------------------------------
--- Area of Responsibility
------------------------------------------------------------------------------
SELECT
PN.DISPLAY_NAME,
PALL.PERSON_NUMBER,
(SELECT HAOU0.NAME FROM HR_ALL_ORGANIZATION_UNITS HAOU0
WHERE HAOU0.ORGANIZATION_ID = ASG.LEGAL_ENTITY_ID 
AND TRUNC(SYSDATE) BETWEEN HAOU0.EFFECTIVE_START_DATE AND HAOU0.EFFECTIVE_END_DATE) USERS_LEGAL_EMPLOYER,
ASG.LEGISLATION_CODE USERS_COUNTRY,
(SELECT HAOU3.NAME FROM HR_ALL_ORGANIZATION_UNITS HAOU3
WHERE HAOU3.ORGANIZATION_ID = ASG.BUSINESS_UNIT_ID 
AND TRUNC(SYSDATE) BETWEEN HAOU3.EFFECTIVE_START_DATE AND HAOU3.EFFECTIVE_END_DATE) USERS_BUSINESS_UNIT,
ASG.ASSIGNMENT_NUMBER,
PP.ATTRIBUTE1 GGI,
AOR.ASG_RESPONSIBILITY_ID,
TRIM(AOR.RESPONSIBILITY_NAME) RESPONSIBILITY_NAME,
AOR.INCLUDE_TOP_HIER_NODE,
AOR.ASSIGNMENT_ID,
AOR.PERSON_ID,
AOR.START_DATE,
AOR.END_DATE,
AOR.RESPONSIBILITY_TYPE ,
AOR.STATUS,
AOR.ENTERPRISE_ID,
AOR.ORGANIZATION_TREE_CODE,
AOR.TOP_ORGANIZATION_ID,
(SELECT HAOU.NAME FROM HR_ALL_ORGANIZATION_UNITS HAOU
WHERE HAOU.ORGANIZATION_ID = AOR.TOP_ORGANIZATION_ID
AND TRUNC(SYSDATE) BETWEEN HAOU.EFFECTIVE_START_DATE AND HAOU.EFFECTIVE_END_DATE) TOP_ORGANIZATION,
(SELECT HAC.CLASSIFICATION_CODE
FROM HR_ORG_UNIT_CLASSIFICATIONS_F HAC
WHERE HAC.ORGANIZATION_ID = AOR.TOP_ORGANIZATION_ID
AND TRUNC(SYSDATE) BETWEEN HAC.EFFECTIVE_START_DATE AND HAC.EFFECTIVE_END_DATE 
) TOP_ORG_CLASSIFICATION_CODE,
AOR.COUNTRY,
AOR.BUSINESS_UNIT_ID,
(SELECT HAOU1.NAME FROM HR_ALL_ORGANIZATION_UNITS HAOU1
WHERE HAOU1.ORGANIZATION_ID = AOR.BUSINESS_UNIT_ID
AND TRUNC(SYSDATE) BETWEEN HAOU1.EFFECTIVE_START_DATE AND HAOU1.EFFECTIVE_END_DATE) BUSINESS_UNIT_NAME,
AOR.LEGAL_ENTITY_ID,
(SELECT HAOU2.NAME FROM HR_ALL_ORGANIZATION_UNITS HAOU2
WHERE HAOU2.ORGANIZATION_ID = AOR.LEGAL_ENTITY_ID
AND TRUNC(SYSDATE) BETWEEN HAOU2.EFFECTIVE_START_DATE AND HAOU2.EFFECTIVE_END_DATE) LEGAL_ENTITY_NAME,
AOR.WORK_CONTACTS_FLAG,
AOR.TEMPLATE_ID,
AOR.HIERARCHY_TYPE,
AOR.USAGE
FROM PER_ASG_RESPONSIBILITIES AOR
JOIN PER_PERSON_NAMES_F PN ON AOR.PERSON_ID=PN.PERSON_ID AND TRUNC(SYSDATE) BETWEEN PN.EFFECTIVE_START_DATE AND PN.EFFECTIVE_END_DATE
JOIN PER_ALL_PEOPLE_F PALL ON AOR.PERSON_ID=PALL.PERSON_ID AND TRUNC(SYSDATE) BETWEEN PALL.EFFECTIVE_START_DATE AND PALL.EFFECTIVE_END_DATE
JOIN PER_ALL_ASSIGNMENTS_M ASG ON AOR.PERSON_ID=ASG.PERSON_ID AND TRUNC(SYSDATE) BETWEEN ASG.EFFECTIVE_START_DATE AND ASG.EFFECTIVE_END_DATE
JOIN PER_PERSONS PP ON AOR.PERSON_ID=PP.PERSON_ID
JOIN PER_PERIODS_OF_SERVICE PPOS ON AOR.PERSON_ID=PPOS.PERSON_ID AND ASG.PERIOD_OF_SERVICE_ID = PPOS.PERIOD_OF_SERVICE_ID AND PPOS.PRIMARY_FLAG = 'Y' AND (PPOS.ACTUAL_TERMINATION_DATE IS NULL OR  TRUNC(SYSDATE) BETWEEN PPOS.DATE_START AND PPOS.ACTUAL_TERMINATION_DATE)
WHERE PN.NAME_TYPE='GLOBAL'
AND ASG.ASSIGNMENT_TYPE IN ('E','C','N','P')
--AND PALL.PERSON_NUMBER = '20000101051'
--AND AOR.RESPONSIBILITY_NAME LIKE 'XXX%'
--AND AOR.ASG_RESPONSIBILITY_ID = 300000033449649
------------------------------------------------------------------------------
------------------------------------------------------------------------------
--- User Roles
------------------------------------------------------------------------------
SELECT 
PAPF.PERSON_NUMBER,
PP.ATTRIBUTE1 GGI,
PU.USERNAME,
PRD.ROLE_COMMON_NAME,
pu.user_id
FROM 
PER_USERS PU
JOIN PER_ALL_PEOPLE_F PAPF 
ON PU.PERSON_ID = PAPF.PERSON_ID
AND TRUNC(SYSDATE) BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.EFFECTIVE_END_DATE
JOIN PER_PERSONS PP
ON PP.PERSON_ID = PAPF.PERSON_ID
JOIN PER_USER_ROLES PUR
ON PU.USER_ID = PUR.USER_ID
JOIN PER_ROLES_DN PRD
on pur.role_id = PRD.role_id
WHERE PU.ACTIVE_FLAG = 'Y'
and upper(username) like '%@S%'
------------------------------------------------------------------------------
------------------------------------------------------------------------------
--- Lookups and translations
------------------------------------------------------------------------------
select 
flt.MEANING Lookup_Name,
flt.DESCRIPTION Lookup_Description,
flv.lookup_type lookup_type,  FLV.LOOKUP_CODE,
FLV.MEANING English_Meaning, FLV.DESCRIPTION English_Description,
FLV.ENABLED_FLAG , FLV.TAG, to_char(FLV.START_DATE_ACTIVE,'DD-MON-YYYY') START_DATE_ACTIVE, 
to_char(FLV.END_DATE_ACTIVE,'DD-MON-YYYY') end_DATE_ACTIVE
, FLVcs.MEANING Czech_meaning, FLVcs.DESCRIPTION Czech_description
, FLVD.MEANING German_meaning, FLVD.DESCRIPTION German_description
, FLVE.MEANING Spanish_meaning, FLVE.DESCRIPTION Spanish_description
, FLVF.MEANING French_meaning, FLVF.DESCRIPTION French_description
, FLVFRC.MEANING Canadian_French_meaning, FLVFRC.DESCRIPTION Canadian_French_description
, FLVI.MEANING Italian_meaning, FLVI.DESCRIPTION Italian_description
, FLVNL.MEANING Dutch_meaning, FLVNL.DESCRIPTION Dutch_description
, FLVPL.MEANING Polish_meaning, FLVPL.DESCRIPTION Polish_description
, FLVPTB.MEANING Brazilian_Portuguese_meaning, FLVPTB.DESCRIPTION Brazilian_Portuguese_description
, FLVRO.MEANING Romanian_meaning, FLVRO.DESCRIPTION Romanian_description
, FLVTR.MEANING Turkish_meaning, FLVTR.DESCRIPTION Turkish_description,
flv.LAST_UPDATED_BY, flv.LAST_UPDATE_date, flv.Creation_date, flv.Created_by
from fnd_lookup_values flv
, fnd_lookup_types fl
, fnd_lookup_types_tl flt
,fnd_lookup_values flvcs
,fnd_lookup_values flvD
,fnd_lookup_values flvE
,fnd_lookup_values flvF
,fnd_lookup_values flvFRC
,fnd_lookup_values flvI
,fnd_lookup_values flvNL
,fnd_lookup_values flvPL
,fnd_lookup_values flvPTB
,fnd_lookup_values flvRO
,fnd_lookup_values flvTR
where flv.language = 'US'
and flt.language = 'US'
and flv.lookup_type = flvcs.lookup_type
and FLV.LOOKUP_CODE = flvcs.lookup_code
and flvcs.language = 'CS'
and flv.lookup_type = flvD.lookup_type
and FLV.LOOKUP_CODE = flvD.lookup_code
and flvD.language = 'D'
and FLV.lookup_type = flvE.lookup_type
and FLV.LOOKUP_CODE = flvE.lookup_code
and flvE.language = 'E'
and FLV.lookup_type = flvF.lookup_type
and FLV.LOOKUP_CODE = flvF.lookup_code
and flvF.language = 'F'
and FLV.lookup_type = flvFRC.lookup_type
and FLV.LOOKUP_CODE = flvFRC.lookup_code
and flvFRC.language = 'FRC'
and FLV.lookup_type = flvI.lookup_type
and FLV.LOOKUP_CODE = flvI.lookup_code
and flvI.language = 'I'
and FLV.lookup_type = flvNL.lookup_type
and FLV.LOOKUP_CODE = flvNL.lookup_code
and flvNL.language = 'NL'
and FLV.lookup_type = flvPL.lookup_type
and FLV.LOOKUP_CODE = flvPL.lookup_code
and flvPL.language = 'PL'
and FLV.lookup_type = flvPTB.lookup_type
and FLV.LOOKUP_CODE = flvPTB.lookup_code
and flvPTB.language = 'PTB'
and FLV.lookup_type = flvRO.lookup_type
and FLV.LOOKUP_CODE = flvRO.lookup_code
and flvRO.language = 'RO'
and FLV.lookup_type = flvTR.lookup_type
and FLV.LOOKUP_CODE = flvTR.lookup_code
and flvTR.language = 'TR'
and fl.lookup_type = FLV.lookup_type
and fl.lookup_type = FLt.lookup_type
and fl.VIEW_APPLICATION_ID = 3
and fl.CUSTOMIZATION_LEVEL in ('E', 'U')
-- and flv.LAST_UPDATED_BY != 'SEED_DATA_FROM_APPLICATION'
and flv.lookup_type in ( 'XX_LOOKUP_TYPE',
'ADDRESS_TYPE',
'BLOOD_TYPE',
'CONTACT',
'CONTRACT_TYPE',
'DISABILITY_CATEGORY',
'DISABILITY_REASON',
'DISABILITY_STATUS',
'DOCUMENT_CATEGORY',
'EMAIL_TYPE',
'EMP_CAT',
'EMPLOYEE_CATG',
'HRT_EDUCATION_LEVEL',
'JOB_FUNCTION_CODE',
'MAR_STATUS',
'NATIONALITY',
'ORA_PER_EXT_IDENTIFIER_TYPES',
'ORA_PER_SENIORITY_ITEMS',
'PER_CITIZENSHIP_STATUS',
'PER_CM_MTHD',
'PER_ETHNICITY',
'PER_HIGHEST_EDUCATION_LEVEL',
'PER_NATIONAL_IDENTIFIER_TYPE',
'PER_PASSPORT_TYPE',
'PER_RELIGION',
'PER_RESPONSIBILITY_TYPES',
'PER_SUPERVISOR_TYPE',
'PER_VISA_PERMIT_STATUS',
'PER_VISA_PERMIT_TYPE',
'PHONE_TYPE',
'PROBATION_PERIOD',
'SEX',
'TITLE',
'ORA_PER_STATUTORY_DEPENDENT'
)
------------------------------------------------------------------------------
------------------------------------------------------------------------------
--- DummyOrgTree
------------------------------------------------------------------------------
select 
'METADATA|OrganizationTreeNode|TreeStructureCode|TreeCode|TreeVersionName|OrganizationName|ClassificationCode|ReferenceTreeCode|ReferenceTreeVersionName|ParentOrganizationName|ParentClassificationCode|DeleteChildNodesFlag' AA from dual
UNION
select 'MERGE|OrganizationTreeNode|PER_ORG_TREE_STRUCTURE|SG_MOCK4_RO_DELTA_ORG_TREE|SG Mock 4 RO Delta Org Tree V3|SOCIETE GENERALE GROUP|ENTERPRISE|||||'  AA from dual 
union
select 'MERGE|OrganizationTreeNode|PER_ORG_TREE_STRUCTURE|SG_MOCK4_RO_DELTA_ORG_TREE|SG Mock 4 RO Delta Org Tree V3|' || haotl.name || '|DEPARTMENT|||' || fss.set_name || '|FUN_BUSINESS_UNIT|' AA
FROM
HR_ORG_UNIT_CLASSIFICATIONS_F hac,
HR_ALL_ORGANIZATION_UNITS_F hao,
HR_ORGANIZATION_UNITS_F_TL haotl,
FND_SETID_SETS FSS
WHERE hao.ORGANIZATION_ID = hac.ORGANIZATION_ID 
AND hao.ORGANIZATION_ID = haotl.ORGANIZATION_ID 
AND hao.EFFECTIVE_START_DATE BETWEEN hac.EFFECTIVE_START_DATE AND hac.EFFECTIVE_END_DATE 
AND haotl.LANGUAGE = USERENV('LANG') 
AND haotl.EFFECTIVE_START_DATE = hao.EFFECTIVE_START_DATE 
AND haotl.EFFECTIVE_END_DATE = hao.EFFECTIVE_END_DATE 
AND hac.CLASSIFICATION_CODE = 'DEPARTMENT'
and trunc(sysdate) between hao.EFFECTIVE_START_DATE and hao.EFFECTIVE_END_DATE
AND FSS.LANGUAGE = USERENV('LANG') 
and hac.SET_ID = FSS.SET_ID
--and fss.set_name = 'RO-GSC'  -- Uncomment if full tree is needed
UNION 
select 'MERGE|OrganizationTreeNode|PER_ORG_TREE_STRUCTURE|SG_MOCK4_RO_DELTA_ORG_TREE|SG Mock 4 RO Delta Org Tree V3|' || haotl.name || '|FUN_BUSINESS_UNIT|||SOCIETE GENERALE GROUP|ENTERPRISE|' AA
FROM
HR_ORG_UNIT_CLASSIFICATIONS_F hac,
HR_ALL_ORGANIZATION_UNITS_F hao,
HR_ORGANIZATION_UNITS_F_TL haotl
WHERE hao.ORGANIZATION_ID = hac.ORGANIZATION_ID 
AND hao.ORGANIZATION_ID = haotl.ORGANIZATION_ID 
AND hao.EFFECTIVE_START_DATE BETWEEN hac.EFFECTIVE_START_DATE AND hac.EFFECTIVE_END_DATE 
AND haotl.LANGUAGE = USERENV('LANG') 
AND haotl.EFFECTIVE_START_DATE = hao.EFFECTIVE_START_DATE 
AND haotl.EFFECTIVE_END_DATE = hao.EFFECTIVE_END_DATE 
AND hac.CLASSIFICATION_CODE = 'FUN_BUSINESS_UNIT'
and trunc(sysdate) between hao.EFFECTIVE_START_DATE and hao.EFFECTIVE_END_DATE
--and haotl.name = 'RO-GSC' -- Uncomment if full tree is needed
------------------------------------------------------------------------------
------------------------------------------------------------------------------
--- Assignment HDL row extract for deletion
------------------------------------------------------------------------------
select 
'METADATA|WorkTerms|AssignmentId|ActionCode|ReasonCode|EffectiveStartDate|EffectiveEndDate|EffectiveLatestChange|EffectiveSequence|PeriodOfServiceId|PrimaryWorkTermsFlag' AA
from dual
Union
select 
'METADATA|Assignment|AssignmentId|ActionCode|ReasonCode|WorkTermsAssignmentId|EffectiveStartDate|EffectiveEndDate|EffectiveLatestChange|EffectiveSequence|PeriodOfServiceId|PrimaryFlag|PrimaryAssignmentFlag' AA
from Dual
Union
select ASGT.AA from 
(
select 
papf.Person_number, Assignment_number, paam.effective_start_date,
'MERGE|WorkTerms|'||paam.assignment_ID || '|' ||paam.Action_code|| '|' || paam.Reason_code  || '|' ||to_char(paam.effective_start_date, 'YYYY/MM/DD') || '|' ||to_char(paam.effective_end_date, 'YYYY/MM/DD') || '|' ||paam.effective_latest_change || '|' || paam.effective_sequence  || '|' ||paam.period_of_service_id || '|' ||paam.Primary_work_terms_flag
AA
from per_all_assignments_M paam, per_all_people_f papf
where primary_work_terms_flag = 'Y'
and papf.person_id = paam.person_id
and trunc(:assignment_start_date) between papf.effective_start_date and papf.effective_end_date
Union
select 
papf.Person_number, Assignment_number, paam.effective_start_date,
'MERGE|Assignment|'||paam.assignment_ID || '|' || paam.Action_code|| '|' || paam.Reason_code  || '|' ||paam.Work_terms_assignment_id || '|' ||to_char(paam.effective_start_date, 'YYYY/MM/DD') || '|' || to_char(paam.effective_end_date, 'YYYY/MM/DD') || '|' ||paam.effective_latest_change || '|' ||  paam.effective_sequence  || '|' || paam.period_of_service_id || '|' ||paam.primary_flag || '|' || paam.Primary_assignment_flag
AA
from per_all_assignments_M paam, per_all_people_f papf
where 
 primary_work_terms_flag = 'N'
 and papf.person_id = paam.person_id
and trunc(:assignment_start_date) between papf.effective_start_date and papf.effective_end_date
 ) ASGT
 where  asgt.Person_number = :Person_number
-- asgt.assignment_number in ( 'E'||:Person_number, 'ET'||:Person_number)
 and asgt.effective_start_date = :assignment_start_date
order by 1 desc

------------------------------------------------------------------------------
