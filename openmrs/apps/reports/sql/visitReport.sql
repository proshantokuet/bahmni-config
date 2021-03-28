SELECT
DISTINCT(pi.identifier) AS "Patient Identifier",
concat(pn.given_name, " ", ifnull(pn.family_name,""))         AS "Patient Name",
  floor(DATEDIFF(DATE(v.date_started), p.birthdate) / 365)      AS "Age",
  p.gender                                                      AS "Gender",
  DATE_FORMAT(p.date_created, "%d-%b-%Y")                       AS "Patient Created Date",
  vt.name                                                       AS "Visit type",
  DATE_FORMAT(v.date_started, "%d-%b-%Y")                       AS "Date started",
  DATE_FORMAT(v.date_stopped, "%d-%b-%Y")                       AS "Date stopped",
  ROUND(TIME_TO_SEC(timediff(v.date_stopped,v.date_started))/60) AS "Waiting Time (In Minutes)",
  DATE_FORMAT(admission_details.admission_date, "%d-%b-%Y")     AS "Date Of Admission",
  DATE_FORMAT(admission_details.discharge_date, "%d-%b-%Y")     AS "Date Of Discharge"
  
  
  

FROM visit v
  JOIN visit_type vt ON v.visit_type_id = vt.visit_type_id
  JOIN person p ON p.person_id = v.patient_id AND p.voided is false
  JOIN patient_identifier pi ON p.person_id = pi.patient_id AND pi.voided is false
  JOIN patient_identifier_type pit ON pi.identifier_type = pit.patient_identifier_type_id AND pit.retired is false
  JOIN person_name pn ON pn.person_id = p.person_id AND pn.voided is false
  LEFT OUTER JOIN (SELECT
                      va.date_created                                              AS admission_date,
                      if(va.value_reference = "Discharged", va.date_changed, NULL) AS discharge_date,
                      va.visit_id                                                  AS visit_id
                    FROM visit_attribute va
                    JOIN visit_attribute_type vat ON vat.visit_attribute_type_id = va.attribute_type_id
                    AND vat.name="Admission Status") as admission_details ON admission_details.visit_id = v.visit_id
  where v.voided is false and  Date(v.date_stopped) between '#startDate#' and '#endDate#' GROUP BY v.visit_id
  

