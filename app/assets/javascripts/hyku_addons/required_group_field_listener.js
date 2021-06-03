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
  }

  // This event callback looks at individual required groups, if one item has been updated,
  // then the other can have its required tag removed.
  onEvent(_event, target){
    let group = $(`[${this.groupAttributeName}=${target.attr(this.groupAttributeName)}]`)

    group.not(target).each($.proxy(function(_i, el){
      let eventName = $(target).val().length ? "unset_required" : "set_required"

      $("body").trigger(eventName, [el])
    }))
  }
}
