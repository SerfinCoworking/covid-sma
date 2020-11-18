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
          $("#patient-form-fields .andes-fields").removeClass('d-none');
          $("#patient-form-fields").collapse('show');
          console.log(ui.item.data.direccion);
          // setteamos los datos que vienen de andes
          $("#patient-address-country").val(ui.item.data.direccion[0].ubicacion.pais.nombre);
          $("#patient-address-state").val(ui.item.data.direccion[0].ubicacion.provincia.nombre);
          $("#patient-address-city").val(ui.item.data.direccion[0].ubicacion.localidad.nombre);
          $("#patient-address-line").val(ui.item.data.direccion[0].valor);
          $("#patient-address-latitude").val(ui.item.data.direccion[0].geoReferencia[0]);
          $("#patient-address-longitude").val(ui.item.data.direccion[0].geoReferencia[1]);
          $("#patient-address-postal-code").val(ui.item.data.direccion[0].codigoPostal);


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
                
                const phoneInputSelect = "<input type='text' name='phone-type-"+i+"' class='form-control string optional input-sm' readonly='readonly' value="+ $(item).val() +">";
                $(phonesField[i]).find('td').first().prepend(phoneInputSelect);
              }
            });
            $(phonesField[i]).find('td').last().find('a.remove-tag').addClass('d-none');
            // cargamos el numero de telefono
            $(phoneNumber).val(ui.item.data.contacto[i].valor).attr('readonly', true);

            $("#add-phone").trigger("click");
          }

                    
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