// Example:
//
// <input name="first_name" type="text" value="" data-required="true" data-required-group="user_name" data-on-blur-event="toggle_required_group">
// <input name="last_name" type="text" value="" data-required="true" data-required-group="user_name" data-on-blur-event="toggle_required_group">

class RequiredGroupFieldListener {
  constructor(){
    this.eventName = "toggle_required_group"
    this.groupAttributeName = "data-required-group"

    this.registerListeners()
  }

  registerListeners(){
    $("body").on(this.eventName, this.onEvent.bind(this))

    // When the page events have finished being registered, listen and perform an after action
    $("body").on("after-register-events", this.afterRegisterEvents.bind(this))
  }

  afterRegisterEvents(){
    $(`[${this.groupAttributeName}]`).trigger("blur")
  }

  onEvent(_event, target){
    let group = $(`[${this.groupAttributeName}=${target.attr(this.groupAttributeName)}]`)

    group.not(target).each($.proxy(function(_i, el){
      // If the element is hidden, we need to unset required or the form will break
      let eventName = $(target).val().length || $(target).is(":hidden") ? "unset_required" : "set_required"

      $("body").trigger(eventName, [el])
    }))
  }
}
