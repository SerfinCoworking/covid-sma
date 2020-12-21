$(document).on('turbolinks:load', function(e){
  if( !(_PAGE.controller === 'epidemic_sheets' && ['new', 'create', 'edit', 'update', 'new_contact'].includes(_PAGE.action))) return false;
    $("#present-prev-symp, #present-symptoms").on('change', function(e){
      if($(e.target).is(":checked")){
        $(e.target).closest(".col-4").siblings(".symptoms-fields").addClass('show');
      }else{
        /* al quitar el check, limpiamos los campos de seleccion y observaciones */
        $(e.target).closest(".col-4").siblings(".symptoms-fields").removeClass('show');
        $(e.target).closest(".col-4").siblings(".symptoms-fields").find(".selectpicker-md").first().selectpicker('deselectAll');
        $(e.target).closest(".col-4").siblings(".symptoms-fields").find(".observations-field").val('');
        
      }
    });

    // mostramos selector test realizado, si el valor seleccionado no es "sospechoso"
    $("#case-select").on('change', function(e){     
      if($(e.target).find('option:selected').first().attr('data-needs-diagnostic') === 'true'){
        $(e.target).closest('.case-type-container').siblings('.diagnostic-method').addClass("show");
        $(e.target).closest('.case-type-container').siblings('.special-device').addClass("show");
      }else{
        $(e.target).closest('.case-type-container').siblings('.diagnostic-method').removeClass("show");
        $(e.target).closest('.case-type-container').siblings('.special-device').removeClass("show");
      }
    });    

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
        resetPatientForm();

        // Si viene de andes el paciente, se motrara un formulario precargado con sus datos
        if(ui.item.create && ui.item.data){
          $("#patient-form-fields .andes-fields").removeClass('d-none');
          $("#patient-form-fields").collapse('show');
          // setteamos los datos que vienen de andes
          const location = ui.item.data.direccion[0];
          if(location && location.ubicacion.pais){
            $("#patient-address-country").val(location.ubicacion.pais.nombre);
          }
          if(location && location.ubicacion.provincia){
            $("#patient-address-state").val(location.ubicacion.provincia.nombre);
          }
          if(location && location.ubicacion.localidad){
            $("#patient-address-city").val(location.ubicacion.localidad.nombre);
          }
          if(location && location.valor){
            $("#patient-address-line").val(location.valor);
          }
          if(location && location.geoReferencia && location.geoReferencia.length == 2){
            $("#patient-address-latitude").val(location.geoReferencia[0]);
            $("#patient-address-longitude").val(location.geoReferencia[1]);
          }
          if(location && location.codigoPostal){
            $("#patient-address-postal-code").val(location.codigoPostal);
          }

          
          $("#patient-status-code").val("Validado");


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

          if(ui.item.data.contacto.length){
            for(let i = 0; i < ui.item.data.contacto.length; i++){
              if(['celular', 'fijo'].includes(ui.item.data.contacto[i].tipo)){
                const phonesField = $(".phones-form");
                const phoneType = new RegExp(ui.item.data.contacto[i].tipo, 'i');
                const phoneSelectType = $(phonesField[i]).find('select.phone-type').first();
                const phoneNumber = $(phonesField[i]).find('input.phone-number').first();
                
                // marcamos el valor correspondiente
                $(phoneSelectType).find('option').each((index, item) => {
                  if($(item).val() && $(item).val().match(phoneType) ){
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
              }
            }//fin for

          }

          if(ui.item.data.fechaNacimiento){
            // precargamos la fecha nacimiento del paciente
            const birthdate = moment(ui.item.data.fechaNacimiento);
            $("#patient-form-birthdate").val(birthdate.format("DD/MM/YYYY")).attr('readonly', true);
          }        

        }else if (ui.item.create && ui.item.dni){
          $("#patient-form-fields .andes-fields").removeClass('d-none');
          $("#patient-form-dni").val(ui.item.dni).attr('readonly', true);
          $("#patient-status-code").val("Temporal");
          $("#patient-form-fields").collapse('show');
        }else{
          $("#patient-form-fields").collapse('hide');
          $('#patient-found-modal').modal('show');
          
          // cargamos 
          // nombre / apellido / establecimiento donde fue cargado
          const body = $('#patient-found-modal').find("#patient-data");
          body.find("#patient-fullname").text(ui.item.fullname);
          body.find("#patient-dni").text(ui.item.dni);
          body.find("#establishment").text(ui.item.establishment);
          $('#patient-found-modal').find("a#redirect-sheet").attr('href', ui.item.url);


        }
      }
    });

    function resetPatientForm(){
      $("#patient-address-country").val('');
      $("#patient-address-state").val('');
      $("#patient-address-city").val('');
      $("#patient-address-line").val('');
      $("#patient-address-latitude").val('');
      $("#patient-address-longitude").val('');
      $("#patient-address-postal-code").val('');
      $("#patient-form-lastname").val('');
      $("#patient-form-lastname").removeAttr('readonly');

      $("#patient-form-firstname").val('');
      $("#patient-form-firstname").removeAttr('readonly');
      $("#patient-form-dni").val('');
      $("#patient-form-dni").removeAttr('readonly');

      $("#patient-form-sex").val("Otro");
      $("#patient-form-sex").selectpicker('render');
      $("#patient-form-sex").selectpicker('show');

      // ocultamos el selectpicker y mostramos un input fake con el attribute readonly
      const sexInputSelect = $("#patient-form-sex").closest('.sex-indicator').find('.hidden-input-container').first();
      $(sexInputSelect).find('input').first().val('');
      $(sexInputSelect).addClass('d-none');

      // phones
      $('.nested-fields.phones-form').remove();
      $("#add-phone").trigger("click");

      $("#patient-form-birthdate").val('');
      $("#patient-form-birthdate").removeAttr('readonly');
    }

    $('#close-contact-form').on('cocoon:after-insert', function(e, insertedItem, originalEvent) { 
      insertedItem.find('.full-name').focus();
      $('.selectpicker').selectpicker({style: 'btn-sm btn-default'});
      $('.last-contact-date').datepicker({
        closeText: 'Cerrar',
        prevText: '<Ant',
        nextText: 'Sig>',
        currentText: 'Hoy',
        monthNames: ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'],
        monthNamesShort: ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'],
        dayNames: ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'],
        dayNamesShort: ['Dom', 'Lun', 'Mar', 'Mié', 'Juv', 'Vie', 'Sáb'],
        dayNamesMin: ['Do', 'Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sá'],
        weekHeader: 'Sm',
        dateFormat: 'dd/mm/yy',
        firstDay: 1,
        isRTL: false,
        showMonthAfterYear: false,
        yearSuffix: ''
      });
    });
});