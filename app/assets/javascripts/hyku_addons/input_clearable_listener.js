// Example:
// $("body").trigger("clear_inputs", [$(el)])

class InputClearableListener {
  eventName = "clear_inputs"

  constructor(){
    this.registerListeners()
  }

  registerListeners(){
    $("body").on(this.eventName, this.onEvent.bind(this))
  }

  onEvent(event, target){
    $(target).find("input").val("")
    $(target).find("select").each(function(){
      // By removing selected, rather than setting the select value to false, we avoid having no visble toggled element
      $(this).find("option").attr("selected", false)
      $(this).trigger("change", [$(this)])
    })
  }
}
