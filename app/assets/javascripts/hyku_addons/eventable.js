// Register events that can be consumed else where.
//
// Note: They don't need to be registered here, however it seems logical to
// keep them in the same place for now.
class Eventable {
  constructor(){
    this.registerEvents()
  }

  registerEvents(){
    $("body").on("change", "[data-on-change-event]", function(){
      let eventName = $(this).data("on-change-event")
      $("body").trigger(eventName, [$(this)])
    })

    $("body").on("click", "[data-on-click-event]", function(event){
      // NOTE: I didn't want to prevent default here, but I can't seem to prevent the link clicks in the listeners
      event.preventDefault()

      let eventName = $(this).data("on-click-event")
      $("body").trigger(eventName, [$(this)])
    })

    $("body").on("blur", "[data-on-blur-event]", function(event){
      let eventName = $(this).data("on-blur-event")
      console.log(eventName)
      $("body").trigger(eventName, [$(this)])
    })
  }
}
