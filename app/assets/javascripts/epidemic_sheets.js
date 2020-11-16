$(document).on('turbolinks:load', function() {

  $(document).on('change', '.case-select', function(e) {
    e.stopImmediatePropagation()
    console.log("Valor: ", $(this).val());
    if($(this).val() == 'confirmado'){
      $('.diagnostic-method').removeClass("invisible");
    }else{
      $('.diagnostic-method').addClass("invisible");
    }
  });//End on change events

  // Función para autocompletar DNI de paciente
  jQuery(function() {
    return $('#patient-dni').autocomplete({
      source: $('#patient-dni').data('autocomplete-source'),
      autoFocus: true,
      minLength: 7,
      messages: {
        noResults: function() {
          $(".ui-menu-item-wrapper").html("No se encontró el paciente");
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
        $("#patient_id").val(ui.item.id);
        $("#patient-dni").val(ui.item.dni);
        $("#patient-fullname").val(ui.item.fullname);
      }
    })
  });
});