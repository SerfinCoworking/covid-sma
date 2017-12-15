$(document).on('turbolinks:load', function() {

  $('#prescription_date_received').datetimepicker();
  $('#prescription_date_processed').datetimepicker();
  document.getElementById('patientHint').style.display="none";
  document.getElementById('professional-hint').style.display="none";
  $('#patient_id').change(function () {
      if($('#patient_id option:selected').val() == 0){
        document.getElementById('form-prescription').style.display="block";
        document.getElementById('patientHint').style.display="none";
        document.getElementById('prescription_patient_attributes_first_name').required = true;
        document.getElementById('prescription_patient_attributes_last_name').required = true;
        document.getElementById('prescription_patient_attributes_dni').required = true;
      }else{
        document.getElementById('form-prescription').style.display="none";
        document.getElementById('patientHint').style.display="block";
        document.getElementById('prescription_patient_attributes_first_name').required = false;
        document.getElementById('prescription_patient_attributes_last_name').required = false;
        document.getElementById('prescription_patient_attributes_dni').required = false;
      }
  });
  $('#professional_id').change(function () {
    if($('#professional_id option:selected').val() == 0){
      document.getElementById('form-professional').style.display="block";
      document.getElementById('professional-hint').style.display="none";
      document.getElementById('prescription_professional_attributes_first_name').required = true;
      document.getElementById('prescription_professional_attributes_last_name').required = true;
      document.getElementById('prescription_professional_attributes_dni').required = true;

    }else{
      document.getElementById('form-professional').style.display="none";
      document.getElementById('professional-hint').style.display="block";
      document.getElementById('prescription_professional_attributes_first_name').required = false;
      document.getElementById('prescription_professional_attributes_last_name').required = false;
      document.getElementById('prescription_professional_attributes_dni').required = false;
    }
  });
});
