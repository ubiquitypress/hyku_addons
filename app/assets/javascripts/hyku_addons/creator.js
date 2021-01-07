// add linked fields
$(document).on("turbolinks:load", function(){
  $("body").on("click", ".add_creator", function(event){
    event.preventDefault();

    var parent = $(this).closest(".ubiquity-meta-creator").last()
    cloneUbiDiv = parent.clone()
    cloneUbiDiv.find('input').val('');
    cloneUbiDiv.find('option').attr('selected', false);

    //adding required fields to creator_given_name and creator_family_name
    cloneUbiDiv.find(".ubiquity_creator_family_name").prop('required', true).next("span.error").show();
    cloneUbiDiv.find(".ubiquity_creator_given_name").prop('required', true).next("span.error").show();

    // TODO: What does this do? Can't find matching HTML classes in the codebase.
    //
    //increment hidden_field counter after cloning
    // var lastInputCount = $('.ubiquity-creator-score:last').val();
    // var hiddenInput = $(cloneUbiDiv).find('.ubiquity-creator-score');
    // hiddenInput.val(parseInt(lastInputCount) + 1);

    parent.after(cloneUbiDiv)
    $('.ubiquity_creator_name_type:last').val('Personal').trigger("change")
  });

  $("body").on("click", ".remove_creator", function(event){
    event.preventDefault();

    if ($(".ubiquity-meta-creator").length == 1 ) {
      return false
    }

    $(this).closest(".ubiquity-meta-creator").remove()
  });

  //for hiding and showing values on the edit form for creator sub fields
  $("body").on("change", ".ubiquity_creator_name_type", function(event){
    var target = $(this)
    var parent = target.closest(".ubiquity-meta-creator")

    if (event.target.value == 'Personal') {
      hideCreatorOrganization(target);
      parent.find(".ubiquity_personal_fields").show();

      var fields = $(this).siblings(".ubiquity_personal_fields")
      creatorAddOrRemoveRequiredAndMessage(fields)

    } else {
      hideCreatorPersonal(target);
      parent.find(".ubiquity_personal_fields").hide();
      parent.find(".ubiquity_organization_fields").show();

      var fields = parent.find('.ubiquity_organization_fields:last');
      creatorOrganizationAddOrRemoveRequiredAndMessage(fields);
    }
  });

  // onFieldBlur
  $("body").on("blur", ".ubiquity_creator_organization_name", function (event) {
    event.preventDefault();

    var fields = $(this).parent('.ubiquity_organization_fields:last');
    creatorOrganizationAddOrRemoveRequiredAndMessage(fields);
  });

  // onFieldBlur
  $("body").on("blur", ".ubiquity_creator_family_name, .ubiquity_creator_given_name", function (event) {
    event.preventDefault();

    var fields = $(this).parent('.ubiquity_personal_fields:last');
    creatorAddOrRemoveRequiredAndMessage(fields);
  });

  $(".ubiquity_creator_name_type").each(function() {
    displayFields(this)
  })

  $('.additional-fields').on("click", function(event){
    $(".ubiquity_creator_name_type").each(function() {
      displayFields(this);
    })
  })

  function displayFields(target){
    var target = $(target)
    var parent = target.closest(".ubiquity-meta-creator")
    parent.find(".js-creator-group").hide()

    if (target.val() == 'Personal') {
      hideCreatorOrganization(target);
      parent.find(".ubiquity_personal_fields").show();

      var fields = parent.find(".ubiquity_personal_fields:last");
      creatorAddOrRemoveRequiredAndMessage(fields);

    } else {
      hideCreatorPersonal(target);
      parent.find(".ubiquity_organization_fields").show();

      var fields = $(target).siblings('.ubiquity_organization_fields:last');
      creatorOrganizationAddOrRemoveRequiredAndMessage(fields);
    }
  }

  function hideCreatorOrganization(self){
    var parent = self.closest(".ubiquity-meta-creator")
    var target = parent.find(".ubiquity_organization_fields")
    var field = target.find(".ubiquity_creator_organization_name:last")

    field.val('').removeAttr('required').next("span.error").hide();
    target.hide();
  }

  function hideCreatorPersonal(self){
    var parent = self.closest(".ubiquity-meta-creator")
    var target = parent.find(".ubiquity_personal_fields")

    target.find(".ubiquity_creator_family_name:last, .ubiquity_creator_given_name:last")
      .val('')
      .removeAttr('required')
      .next("span.error")
      .hide();
    target.find(".ubiquity_creator_orcid:last, .ubiquity_creator_institutional_relationship:last").val('');
    target.hide();
  }

  function creatorAddOrRemoveRequiredAndMessage(target){
    var givenName = target.find('.ubiquity_creator_given_name:last');
    var familyName = target.find('.ubiquity_creator_family_name:last');

    if (givenName.val() || familyName.val()) {
      givenName.removeAttr('required').next("span.error").hide();
      familyName.removeAttr('required').next("span.error").hide();
    } else {
      givenName.prop('required', true).next("span.error").show();
      familyName.prop('required', true).next("span.error").show();
    }
  }

  function creatorOrganizationAddOrRemoveRequiredAndMessage(target){
    var field = target.find(".ubiquity_creator_organization_name:last")

    if (field.val()) {
      field.removeAttr('required').next("span.error").hide();

    } else {
      field.prop('required', true).next("span.error").show();
    }
  }
});

