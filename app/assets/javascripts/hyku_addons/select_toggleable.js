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
  groupSelector = "[data-toggleable-group]"
  controlSelector = "[data-toggleable-control]"

  constructor(){
    this.onLoad()
    this.registerListeners()
  }

  onLoad(){
    // console.log("SelectGroupToggle.onLoad")

    // Can't seen to get this to work via triggering the change event
    $(this.controlSelector).each($.proxy(function(i, el){
      this.toggleSelectGroup($(el))
    }, this))
  }

  registerListeners(){
    // console.log("SelectGroupToggle.registerListeners")

    $("body").on("toggleable_group", this.onToggleGroupEvent.bind(this))
  }

  onToggleGroupEvent(_event, target){
    this.toggleSelectGroup(target)
  }

  toggleSelectGroup(target){
    // console.log(`SelectGroupToggle.Receive Event: ${event.type}`)

    let val = target.val()
    target.closest(this.parentSelector).find(this.groupSelector).hide()
    target.closest(this.parentSelector).find(`${this.groupSelector}[data-toggleable-group=${val}]`).show()
  }
}

