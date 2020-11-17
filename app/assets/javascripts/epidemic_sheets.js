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


});