SELECT m.patient_name                                              AS 
       "Patient Name", 
       pi.identifier                                               AS HID, 
       m.contact                                                   AS "Mobile No", 
       m.gender                                                    AS "Gender", 
       Concat(Timestampdiff(year, p.birthdate, Curdate()), 'Y ', 
       Timestampdiff(month, p.birthdate, Curdate())%12, 'M ', Floor( 
       Timestampdiff(day, p.birthdate, Curdate())% 30.4375), 'D ') AS "Age", 
       Date_format(m.money_receipt_date, '%Y-%d-%m %H:%i')    AS "Visit Date",
       m.clinic_name as "Clinic Name",
       m.clinic_code as "Clinic Code",
       psp.item as "Service Name",
       psp.code as "Service Code"
FROM   openmrs.psi_money_receipt m 
       JOIN openmrs.person p 
         ON m.patient_uuid = p.uuid 
       JOIN openmrs.patient_identifier pi 
         ON p.person_id = pi.patient_id 
       JOIN openmrs.psi_service_provision psp 
         ON psp.psi_money_receipt_id = m.mid
 where Date(m.money_receipt_date) between '#startDate#' and '#endDate#'
