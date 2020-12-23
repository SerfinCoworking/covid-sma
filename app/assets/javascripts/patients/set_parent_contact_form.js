$(document).on('turbolinks:load', function(e){
  if( !(_PAGE.controller === 'patients' && ['set_parent_contact'].includes(_PAGE.action))) return false;
  // Función para autocompletar DNI de paciente
  $('#search-patient-dni').autocomplete({
    source: $('#search-patient-dni').data('autocomplete-source'),
    autoFocus: true,
    minLength: 7,
    messages: {
      noResults: function() {
        $(".ui-menu-item-wrapper").html("No se encontró la ficha en el sistema con ese DNI");
      }
    },
    search: function( event, ui ) {
      $(event.target).parent().siblings('.with-loading').first().addClass('visible');
    },
    response: function (event, ui) {
      $(event.target).parent().siblings('.with-loading').first().removeClass('visible');
    },
    select:
    function (event, ui) {
      event.preventDefault();
      $("#patient").tooltip('hide');
      $("#search-patient-dni").val(ui.item.dni);
      $("#search-patient-lastname").val(ui.item.lastname);
      $("#search-patient-firstname").val(ui.item.firstname);
      $("#patient_parent_contact_id").val(ui.item.id);
    }
  });
});