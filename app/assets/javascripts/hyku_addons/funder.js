const funderOnload = function() {
  // Prevent JS being loaded twice
  if ($("body").attr("data-funder-js-loaded") === "true") {
    return
  }

  function activateAutocompleteForFunderName(obj){
    obj.autocomplete({
      minLength: 2,
      source: function (request, response) {
        $.getJSON(this.element.data('autocomplete-url'), {
          q: request.term
        }, response);
      },
      select: function(ui, result) {
        closest_div = $(this).closest('.ubiquity-meta-funder')

        closest_div.find('.ubiquity_funder_doi').val('')
        closest_div.find('.funder_awards_input_fields_wrap li').not(':first').remove();
        closest_div.find('.funder_awards_input_fields_wrap li:first-child input')[0].value = ''

        closest_div.find('.ubiquity_funder_doi').val(result.item.uri)
        fetchFunderFieldData(result.item.id, closest_div)
      }
    });
  }

  $(".ubiquity-meta-funder").each(function(){
    activateAutocompleteForFunderName($(this).find(".ubiquity_funder_name"));
  })

  $("body").on("click", ".add_funder", function(event){
    event.preventDefault();

    var ubiquityFunderClass = $(this).attr('data-addUbiquityFunder');
    var cloneUbiDiv = $(this).closest('div' + ubiquityFunderClass).clone();

    cloneUbiDiv.find('input').val('');
    cloneUbiDiv.find('ul li').not('li:first').remove();

    //increment hidden_field counter after cloning
    var lastInputCount = $('.ubiquity-funder-score:last').val();
    var hiddenInput = $(cloneUbiDiv).find('.ubiquity-funder-score');

    hiddenInput.val(parseInt(lastInputCount) + 1);
    $(ubiquityFunderClass +  ':last').after(cloneUbiDiv)

    activateAutocompleteForFunderName(cloneUbiDiv.find(".ubiquity_funder_name"));
    applyFunderValidationRulesForField();
  });

  $("body").on("click", ".remove_funder", function(event){
    event.preventDefault();

    var ubiquityFunderClass = $(this).attr('data-removeUbiquityFunder');

    if ($(ubiquityFunderClass).length > 1) {
      $(this).closest('div' + ubiquityFunderClass).remove();
    }
  });

  $("body").attr("data-funder-js-loaded", "true")
}

$(document).ready(funderOnload)
$(document).on("turbolinks:load", funderOnload)

