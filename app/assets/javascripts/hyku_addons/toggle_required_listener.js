class ToggleRequiredListener {
  setEventName = "set_required"
  unsetEventName = "unset_required"
  afterCreateRequiredSelector = "[data-required]"

  constructor(){
    this.registerListeners()
  }

  registerListeners(){
    $("body").on(this.setEventName, this.onSetEvent.bind(this))
    $("body").on(this.unsetEventName, this.onUnsetEvent.bind(this))
  }

  onSetEvent(event, target){
    this.toggleRequired(target, true)

    // SHOW SPAN.ERROR $$$$$$$$$$
  }

  onUnsetEvent(event, target){
    this.toggleRequired(target, false)
  }

  toggleRequired(target, state) {
    target.find(this.afterCreateRequiredSelector).prop("required", state)
  }
}
