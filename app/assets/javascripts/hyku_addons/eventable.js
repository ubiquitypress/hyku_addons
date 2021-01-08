class Eventable {
  constructor(){
    this.registerEvents()
  }

  registerEvents(){
    console.log("Eventable.registerEvents")

    $("body").on("change", `[data-on-change-event]`, function(){
      let eventName = $(this).data("on-change-event")

      console.log(`Eventable.trigger event: ${eventName}`)
      $("body").trigger(eventName, [$(this)])
    })

    $("body").on("click", `[data-on-click-event]`, function(){
      let eventName = $(this).data("on-click-event")

      console.log(`Eventable.trigger event: ${eventName}`)
      $("body").trigger(eventName, [$(this)])
    })
  }
}
