class InputClearable {
  constructor(){
    this.registerListeners()
  }

  registerListeners(){
    console.log("InputClearable.registerListeners")

    $("body").on("clear_inputs", this.onInputClearable.bind(this))
  }

  onInputClearable(event, target){
    console.log("InputClearable.onInputClearable")

    target.find("input").val("")
    target.find("options").attr("selected", false)
    target.find("select").each(function(){
      $(this).trigger("change", [$(this)])
    })
  }
}
