SELECT
pi.identifier,
concat(pn.given_name, " ", ifnull(pn.family_name,""))         AS "Patient Name",
  floor(DATEDIFF(DATE(o.obs_datetime), p.birthdate) / 365)      AS "Age",
  pa.value as "Contact Number",
  vt.name                                                       AS "Visit Type",
  DATE_FORMAT(v.date_started, "%d-%b-%Y")                       AS "Visit Start Date",
  DATE_FORMAT(v.date_stopped, "%d-%b-%Y")                       AS "Visit Stop Date",
  obs_fscn.name as "Question Name",
  coalesce(o.value_numeric, o.value_text,DATE_FORMAT(o.value_datetime, "%d-%b-%Y"), coded_scn.name, coded_fscn.name) AS "Answer"

FROM obs o
  JOIN concept obs_concept ON obs_concept.concept_id=o.concept_id AND obs_concept.retired is false
  JOIN concept_name obs_fscn on o.concept_id=obs_fscn.concept_id AND obs_fscn.concept_name_type="FULLY_SPECIFIED" AND obs_fscn.voided is false
  LEFT JOIN concept_name obs_scn on o.concept_id=obs_scn.concept_id AND obs_scn.concept_name_type="SHORT" AND obs_scn.voided is false
  JOIN person p ON p.person_id = o.person_id AND p.voided is false
  JOIN patient_identifier pi ON p.person_id = pi.patient_id AND pi.voided is false
  JOIN patient_identifier_type pit ON pi.identifier_type = pit.patient_identifier_type_id AND pit.retired is false
  JOIN person_name pn ON pn.person_id = p.person_id AND pn.voided is false
  JOIN encounter e ON o.encounter_id=e.encounter_id AND e.voided is false
  JOIN encounter_provider ep ON ep.encounter_id=e.encounter_id
  JOIN visit v ON v.visit_id=e.visit_id AND v.voided is false
  JOIN visit_type vt ON vt.visit_type_id=v.visit_type_id AND vt.retired is false
  LEFT OUTER JOIN location l ON e.location_id = l.location_id AND l.retired is false
  LEFT OUTER JOIN obs parent_obs ON parent_obs.obs_id=o.obs_group_id
  LEFT OUTER JOIN concept_name parent_cn ON parent_cn.concept_id=parent_obs.concept_id AND parent_cn.concept_name_type="FULLY_SPECIFIED"
  LEFT JOIN concept_name coded_fscn on coded_fscn.concept_id = o.value_coded AND coded_fscn.concept_name_type="FULLY_SPECIFIED" AND coded_fscn.voided is false
  LEFT JOIN concept_name coded_scn on coded_scn.concept_id = o.value_coded AND coded_fscn.concept_name_type="SHORT" AND coded_scn.voided is false
  LEFT OUTER JOIN person_attribute pa ON p.person_id = pa.person_id AND pa.voided is false AND pa.person_attribute_type_id = 42
WHERE o.voided is false AND o.form_namespace_and_path like '%Follow up%' AND obs_fscn.name IN ('Follow-up For','Next Follow-up Date','Other Notes') ANd Date(o.obs_datetime)  between '#startDate#' and '#endDate#'
order by v.date_started DESC

