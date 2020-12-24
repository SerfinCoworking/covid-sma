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
      getEpidemicSheet(ui.item.epidemic_sheet_id);
      $("#patient").tooltip('hide');
      $("#search-patient-dni").val(ui.item.dni);
      $("#search-patient-lastname").val(ui.item.lastname);
      $("#search-patient-firstname").val(ui.item.firstname);
      $("#patient_parent_contact_id").val(ui.item.id);
    }
  });

  // Función para autocompletar Apellido de paciente
  $('#search-patient-lastname').autocomplete({
    source: $('#search-patient-lastname').data('autocomplete-source'),
    autoFocus: true,
    messages: {
      noResults: function() {
        $(".ui-menu-item-wrapper").html("No se encontró la ficha en el sistema con ese apellido");
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

  // Función para autocompletar Nombre de paciente
  $('#search-patient-firstname').autocomplete({
    source: $('#search-patient-firstname').data('autocomplete-source'),
    autoFocus: true,
    messages: {
      noResults: function() {
        $(".ui-menu-item-wrapper").html("No se encontró la ficha en el sistema con ese apellido");
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

  // ajax, brings sector according with the establishment ID
  function getEpidemicSheet(epidemicSheetId){
    if(typeof epidemicSheetId !== 'undefined'){ 
      $.ajax({
        url: "/fichas_epidemiologicas/"+epidemicSheetId, // Ruta del controlador
        method: "GET",
        dataType: "JSON",
      })
      .done(function( data ) {
        if(data.length){
          $.each(data, function(index, element){
            $('#provider-sector').append('<option value="'+element.id+'">'+ element.label +'</option>');
          });
          $('#provider-sector').selectpicker('refresh', {style: 'btn-sm btn-default'});
        }
      });
    }else{
      $('#provider-sector').find('option').remove();
      $('#provider-sector').selectpicker('refresh', {style: 'btn-sm btn-default'});
    }
  }
});