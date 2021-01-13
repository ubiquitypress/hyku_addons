// Example:
//
//	<div data-toggleable data-cloneable data-after-clone="clear_inputs">
//    <select
//      class="form-control"
//      data-toggleable-control
//      data-on-change="toggleable_group"
//      data-after-toggle-hidden="clear_inputs"
//    >
//      <option selected="selected" value="Personal">Personal</option>
//      <option value="Organisational">Organisational</option>
//    </select>
//    <div data-toggleable-group="Personal"></div>
//    <div data-toggleable-group="Organisational"></div>
//  </div>

class ChangeToggleableListener {
  parentSelector = "[data-toggleable]"
  groupAttributeName = "data-toggleable-group"
  groupSelector = `[${this.groupAttributeName}]`
  controlSelector = "[data-toggleable-control]"
  requiredSelector = "[data-required]"
  eventName = "toggleable_group"
  afterHiddenAttributeName = "data-after-toggleable-hidden"

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

  // NOTE:
  // This method could be cleaned up, as its getting kinda messy with the amount its doing.
  // Ideally, it would trigger an event and then move on. That event could then deal with the
  // toggling of required attributes on elements, but i feel like that might be a step
  // to far down the rabbit hole for now.
  toggleSelectGroup(target){
    let val = target.val()
    let parent = target.closest(this.parentSelector)
    let selectedElement = parent.find(`[${this.groupAttributeName}=${val}]`)
    let afterHiddenEventName = target.attr(this.afterHiddenAttributeName)

    // Hide all elements and unset required attributes by default
    parent.find(this.groupSelector).not(selectedElement).each($.proxy(function(i, group){
      $(group).hide()
      this.toggleRequiredChildren($(group), "unset_required")

      // Trigger any after hide actions on the hidden elements
      if (afterHiddenEventName) {
        $("body").trigger(afterHiddenEventName, [group])
      }
    }, this))

    // Show the selectedElement and toggle required
    selectedElement.show()
    this.toggleRequiredChildren(selectedElement, "set_required")
  }

  toggleRequiredChildren(parent, eventName) {
    parent.find(this.requiredSelector).each(function(){
      $("body").trigger(eventName, [$(this)])
    }, this)
  }
}

