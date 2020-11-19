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
        $("#patient-dni").val(ui.item.dni);

        console.log(ui.item, "<========== DEBUG ");
        // Si viene de andes el paciente, se motrara un formulario precargado con sus datos
        if(ui.item.create){
          $("#patient-form-fields .andes-fields").removeClass('d-none');
          $("#patient-form-fields").collapse('show');
          // setteamos los datos que vienen de andes
          const location = ui.item.data.direccion[0];
          if(location.ubicacion.pais){
            $("#patient-address-country").val(location.ubicacion.pais.nombre);
          }
          if(location.ubicacion.provincia){
            $("#patient-address-state").val(location.ubicacion.provincia.nombre);
          }
          if(location.ubicacion.localidad){
            $("#patient-address-city").val(location.ubicacion.localidad.nombre);
          }
          if(location.valor){
            $("#patient-address-line").val(location.valor);
          }
          if(location.geoReferencia && location.geoReferencia.length == 2){
            $("#patient-address-latitude").val(location.geoReferencia[0]);
            $("#patient-address-longitude").val(location.geoReferencia[1]);
          }
          if(location.codigoPostal){
            $("#patient-address-postal-code").val(location.codigoPostal);
          }


          $("#patient-form-lastname").val(ui.item.data.apellido).attr('readonly', true);
          $("#patient-form-firstname").val(ui.item.data.nombre).attr('readonly', true);
          $("#patient-form-dni").val(ui.item.data.documento).attr('readonly', true);
          
          if(ui.item.data.sexo){
            // precargamos el sexo del paciente
            $("#patient-form-sex option").each((index, item) => {
              const sex = new RegExp(ui.item.data.sexo, 'i');
              if($(item).val() && $(item).val().match(sex)){
                $("#patient-form-sex").val($(item).val());
                $("#patient-form-sex").selectpicker('render');
                $("#patient-form-sex").selectpicker('hide');
                // ocultamos el selectpicker y mostramos un input fake con el attribute readonly
                const sexInputSelect = $("#patient-form-sex").closest('.sex-indicator').find('.hidden-input-container').first();
                $(sexInputSelect).find('input').first().val($(item).val());
                $(sexInputSelect).removeClass('d-none');

              }
            });
          }

          $('.nested-fields.phones-form').remove();
          $("#add-phone").trigger("click");
          if(ui.item.data.contacto.length){
            for(let i = 0; i < ui.item.data.contacto.length; i++){

              const phonesField = $(".phones-form");
              const phoneType = new RegExp(ui.item.data.contacto[i].tipo, 'i');
              const phoneSelectType = $(phonesField[i]).find('select.phone-type').first();
              const phoneNumber = $(phonesField[i]).find('input.phone-number').first();
              
              // marcamos el valor correspondiente
              $(phoneSelectType).find('option').each((index, item) => {
                if($(item).val() && $(item).val().match(phoneType)){
                  $(phoneSelectType).val($(item).val());
                  $(phoneSelectType).selectpicker('render');
                  $(phoneSelectType).selectpicker('hide');
                  
                  // ocultamos el selectpicker y mostramos un input fake con el attribute readonly
                  const phoneInputSelect = $(phoneSelectType).closest('td').find('.hidden-input-container').first();
                  $(phoneInputSelect).find('input').first().val($(item).val());
                  $(phoneInputSelect).removeClass('d-none');

                }
              });
              $(phonesField[i]).find('td').last().find('a.remove-tag').addClass('d-none');
              // cargamos el numero de telefono
              $(phoneNumber).val(ui.item.data.contacto[i].valor).attr('readonly', true);
              $("#add-phone").trigger("click");
            }//fin for
          }

          if(ui.item.data.fechaNacimiento){
            // precargamos la fecha nacimiento del paciente
            const birthdate = moment(ui.item.data.fechaNacimiento);
            $("#patient-form-birthdate").val(birthdate.format("DD/MM/YYYY")).attr('readonly', true);
          }        

        }else if (ui.item.create && ui.item.dni){
          $("#patient-form-fields .andes-fields").removeClass('d-none');
          $("#patient-form-fields").collapse('show');
        }
      }
    });

});