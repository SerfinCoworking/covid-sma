$(document).on('turbolinks:load', function(e){
  
  // $("#patient-form-fields").collapse('toggle');

  if( _PAGE.controller !== 'epidemic_sheets' && (_PAGE.action !== 'new' || _PAGE.action !== 'edit') ) return false;

    // Función para autocompletar DNI de paciente
    $('#patient-dni').autocomplete({
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
        // Si viene de andes el paciente, se motrara un formulario precargado con sus datos
        if(ui.item.create){
          $("#patient-form-fields").collapse('show');
          
          $("#patient-form-lastname").val(ui.item.data.apellido).attr('readonly', true);
          $("#patient-form-firstname").val(ui.item.data.nombre).attr('readonly', true);
          $("#patient-form-dni").val(ui.item.data.documento).attr('readonly', true);
          
          // precargamos el sexo del paciente
          $("#patient-form-sex option").each((index, item) => {
            const sex = new RegExp(ui.item.data.sexo, 'i');
            if($(item).val() && $(item).val().match(sex)){
              $("#patient-form-sex").val($(item).val());
              $("#patient-form-sex").selectpicker('render');
            }
            
          });
                    
          // precargamos la fecha nacimiento del paciente
          const birthdate = moment(ui.item.data.fechaNacimiento);
          $("#patient-form-birthdate").val(birthdate.format("DD/MM/YYYY")).attr('readonly', true);;
          
          // Falta cargar telefonos

          // patient-form-phones
          // console.log(ui.item.data.apellido);
        }else{
          $("#patient-form-fields").collapse('show');
        }
        // .collapse('show');
      }
    });

});