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

  onEvent(event, target){
    $(target).find("input").val("")
    $(target).find("options").attr("selected", false)
    $(target).find("select").each(function(){
      $(this).trigger("change", [$(this)])
    })
  }
}
