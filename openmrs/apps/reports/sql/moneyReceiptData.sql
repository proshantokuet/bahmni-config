
select mid, patient_name, uic, contact, dob, clinic_name, money_receipt_date, gender, slip_no from psi_money_receipt pmr where Date(money_receipt_date) between '#startDate#' and '#endDate#'
