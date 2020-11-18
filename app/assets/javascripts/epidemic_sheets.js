$(document).on('turbolinks:load', function() {

  $(document).on('change', '.case-select', function(e) {
    e.stopImmediatePropagation()

    if($(this).val() == 'confirmado'){
      $('.diagnostic-method').removeClass("invisible");
    }else{
      $('.diagnostic-method').addClass("invisible");
    }
  });//End on change events
});