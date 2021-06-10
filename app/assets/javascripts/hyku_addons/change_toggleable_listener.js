// Example:
//
//	<div data-toggleable>
//    <select
//      class="form-control"
//      data-toggleable-control
//      data-on-change="toggleable_group"
//      data-after-toggle-hidden="clear_inputs"
//    >
//      <option selected="selected" value="Personal">Personal</option>
//      <option value="Organisational">Organisational</option>
//    </select>
//    <div data-toggleable-group="Personal">...</div>
//    <div data-toggleable-group="Organisational">...</div>
//  </div>

class ChangeToggleableListener {
  constructor(){
    this.parentSelector = "[data-toggleable]"
    this.groupAttribute = "data-toggleable-group"
    this.groupSelector = `[${this.groupAttribute}]`
    this.controlSelector = "[data-toggleable-control]"
    this.eventName = "toggleable_group"
    this.afterActionAttribute = "data-after-toggleable-hidden"

    this.onLoad()
    this.registerListeners()
  }

  onLoad(){
    // Can't seen to get this to work via triggering the change event
    $(this.controlSelector).each($.proxy(function(_i, el){
      this.toggleSelectGroup($(el))
    }, this))
  }

  registerListeners(){
    $("body").on(this.eventName, this.onToggleGroupEvent.bind(this))
  }

  onToggleGroupEvent(_event, $target){
    this.toggleSelectGroup($target)
  }

  // NOTE:
  // This method could be cleaned up, as its getting kinda messy with the amount its doing.
  // Ideally, it would trigger an event and then move on. That event could then deal with the
  // toggling of required attributes on elements, but i feel like that might be a step
  // to far down the rabbit hole for now.
  toggleSelectGroup($target){
    let val = $target.val()
    let $parent = $target.closest(this.parentSelector)
    let $selectedElement = $parent.find(`[${this.groupAttribute}=${val}]`)

    // Hide all elements and unset required attributes by default
    $parent.find(this.groupSelector).not($selectedElement).each($.proxy(function(_i, hidden_group){
        let $hidden_group = $(hidden_group)

        $hidden_group.hide()

        this.toggleRequiredChildren($hidden_group, "unset_required")
        this.triggerElementAfterEvents($target, $hidden_group)
      }, this))

    // Show the $selectedElement and toggle required
    $selectedElement.show()
    this.toggleRequiredChildren($selectedElement, "set_required")
  }

  toggleRequiredChildren($element, eventName) {
    $element.find("[data-required='true']").each(function(){
      $("body").trigger(eventName, [$(this)])
    }, this)
  }

  // Find the after action from the element and apply them to a group - usually the hidden group
  triggerElementAfterEvents($element, $group){
    // Ensure we have events to trigger and account for times when no events are require
    let events = ($element.attr(this.afterActionAttribute) || "").split(" ").filter(String)

    if (events.length == 0) {
      return false;
    }

    events.forEach((event) => $("body").trigger(event, [$group]))
  }
}

