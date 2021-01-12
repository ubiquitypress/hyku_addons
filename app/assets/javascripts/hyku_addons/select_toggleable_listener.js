// Example:
//
//	<div data-toggleable data-cloneable data-after-clone-action="clear_inputs">
//    <select class="form-control" data-toggleable-control data-on-change-event="toggleable_group">
//      <option selected="selected" value="Personal">Personal</option>
//      <option value="Organisational">Organisational</option>
//    </select>
//    <div data-toggleable-group="Personal"></div>
//    <div data-toggleable-group="Organisational"></div>
//  </div>

class SelectToggleableListener {
  parentSelector = "[data-toggleable]"
  groupAttributeName = "data-toggleable-group"
  groupSelector = `[${this.groupAttributeName}]`
  controlSelector = "[data-toggleable-control]"
  requiredSelector = "[data-required]"
  eventName = "toggleable_group"

  constructor(){
    this.onLoad()
    this.registerListeners()
  }

  onLoad(){
    // Can't seen to get this to work via triggering the change event
    $(this.controlSelector).each($.proxy(function(i, el){
      this.toggleSelectGroup($(el))
    }, this))
  }

  registerListeners(){
    $("body").on(this.eventName, this.onToggleGroupEvent.bind(this))
  }

  onToggleGroupEvent(_event, target){
    this.toggleSelectGroup(target)
  }

  toggleSelectGroup(target){
    let val = target.val()
    let parent = target.closest(this.parentSelector)

    // Hide all elements and unset required attributes by default
    parent.find(this.groupSelector).each($.proxy(function(i, parent){
      $(parent).hide()
      this.toggleRequiredChildren($(parent), "unset_required")
    }, this))

    // Find matching element and toggle required
    let element = parent.find(`[${this.groupAttributeName}=${val}]`)
    element.show()
    this.toggleRequiredChildren(element, "set_required")
  }

  toggleRequiredChildren(parent, eventName) {
    parent.find(this.requiredSelector).each(function(){
      $("body").trigger(eventName, [$(this)])
    }, this)
  }
}

