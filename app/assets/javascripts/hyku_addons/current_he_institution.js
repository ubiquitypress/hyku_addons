// Not updating this code for now, just making it more generic
function populate_isni_ror(){
  var index = document.querySelector(".current_he_institution_name").selectedIndex

  document.querySelector(".current_he_institution_isni").selectedIndex = index
  document.querySelector(".current_he_institution_ror").selectedIndex = index
}

