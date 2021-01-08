class Eventable {
  constructor(){
    this.registerEvents()
  }

  registerEvents(){
    $("body").on("change", "[data-on-change-event]", function(){
      let eventName = $(this).data("on-change-event")

      // console.log(`Eventable.trigger event: ${eventName}`)
      $("body").trigger(eventName, [$(this)])
    })

    $("body").on("click", "[data-on-click-event]", function(event){
      // NOTE: I didn't want to prevent default here, but I can't seem to prevent the link clicks in the listeners
      event.preventDefault()

      let eventName = $(this).data("on-click-event")
      console.log(`Eventable.trigger event: ${eventName}`)
      $("body").trigger(eventName, [$(this)])
    })
  }
}
