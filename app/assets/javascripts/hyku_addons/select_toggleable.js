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

class SelectToggleable {
  parentSelector = "[data-toggleable]"
  groupAttributeName = "data-toggleable-group"
  groupSelector = `[${this.groupAttributeName}]`
  controlSelector = "[data-toggleable-control]"

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
    $("body").on("toggleable_group", this.onToggleGroupEvent.bind(this))
  }

  onToggleGroupEvent(_event, target){
    this.toggleSelectGroup(target)
  }

  toggleSelectGroup(target){
    let val = target.val()
    let parent = target.closest(this.parentSelector)

    // Hide all elements and unset required attributes by default
    parent.find(this.groupSelector).each(function(){
      $(this).hide()
      $("body").trigger("unset_required", [$(this)])
    })

    // Find matching element and toggle required
    let element = parent.find(`[${this.groupAttributeName}=${val}]`)
    element.show()
    $("body").trigger("set_required", [element])
  }
}

