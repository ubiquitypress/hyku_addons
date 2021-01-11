class RequiredMultipleFieldListener {
  eventName = "toggle_require_multiple"

  constructor(){
    this.registerListeners()
  }

  registerListeners(){
    $("body").on(this.eventName, this.onEvent.bind(this))
  }

  onEvent(event, target){
    console.log("RequireMultipleListener.onEvent", target)
  }
}
