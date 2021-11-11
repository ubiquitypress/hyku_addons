// Register events that can be consumed else where.
//
// Note: They don't need to be registered here, however it seems logical to
// keep them in the same place for now.
class Eventable {
  constructor(){
    this.registerEvents()
    this.afterRegisterEvents()
  }

  registerEvents(){
    $("body").on("change", "[data-on-change]", function(){
      let eventName = $(this).data("on-change")
      $("body").trigger(eventName, [$(this)])
    })

    $("body").on("click", "[data-on-click]", function(event){
      // NOTE: I didn't want to prevent default here, but I can't seem to prevent the link clicks in the listeners
      event.preventDefault()

      let eventName = $(this).data("on-click")
      $("body").trigger(eventName, [$(this)])
    })

    $("body").on("blur", "[data-on-blur]", function(_event){
      let eventName = $(this).data("on-blur")
      $("body").trigger(eventName, [$(this)])
    })

    // Whenever the form is submitted, allow listeners to perform registered actions
    $("body").on("submit", "form[data-behavior='work-form']", function(_event){
      $("body").trigger("work-form-submit", [$(this)])
    })
  }

  // So that our listeners know when all events have been
  afterRegisterEvents(){
    $("body").trigger("after-register-events")
  }
}
