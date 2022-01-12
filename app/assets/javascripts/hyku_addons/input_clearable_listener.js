// Example:
// $("body").trigger("clear_inputs", [$(el)])

class InputClearableListener {
  constructor(){
    this.eventName = "clear_inputs"

    this.registerListeners()
  }

  registerListeners(){
    $("body").on(this.eventName, this.onEvent.bind(this))
  }

  onEvent(_event, target){
    $(target).find("input").val("")
    $(target).find("select").each(function(){
      // By removing selected, rather than setting the select value to false, we avoid having no visble toggled element
      $(this).find("option").attr("selected", false)
      $(this).trigger("change", [$(this)])
    })
  }
}
