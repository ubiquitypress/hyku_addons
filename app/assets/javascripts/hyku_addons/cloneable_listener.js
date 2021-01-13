// Example:
//	<div
//		data-toggleable
//		data-cloneable="creator"
//		data-after-clone="clear_inputs"
//		data-cloneable-min="1"
//	>
//   <a href="#" data-turbolinks="false" data-on-click="clone_parent">Add another</a>
//   <a href="#" data-turbolinks="false" data-on-click="remove_parent">Remove</a>
// </div>

class CloneableListener {
  cloneableAttributeName = "data-cloneable"
  cloneableSelector = `[${this.cloneableAttributeName}]`
  afterEventsDataAttributeName = "data-after-clone"

  constructor(){
    this.registerListeners()
  }

  registerListeners(){
    $("body").on("clone_parent", this.onClone.bind(this))
    $("body").on("remove_parent", this.onRemove.bind(this))
  }

  onClone(event, clicked){
    event.preventDefault()

    let target = clicked.closest(this.cloneableSelector).last()
    let clone = target.clone()

    clone.insertAfter(target)
    this.triggerElementAfterEvents(clone)
  }

  onRemove(event, clicked){
    event.preventDefault()

    if(this.reachedMinCount(clicked)) {
      return false
    }

    clicked.closest(this.cloneableSelector).remove()
  }

  // Trigger any events requested, allowing for multiple space delimited event names
  triggerElementAfterEvents(element){
    // Ensure we have events to trigger
    let events = element.attr(this.afterEventsDataAttributeName).split(" ").filter(String)

    if (events.length == 0) {
      return false;
    }

    events.forEach((event) => $("body").trigger(event, [element]))
  }

  // Set a min number of sublings for a cloneable element by:
  // ... data-cloneable-min="1"
  reachedMinCount(clicked) {
    let parent = clicked.closest(this.cloneableSelector)
    let attrName = parent.attr(this.cloneableAttributeName)
    let siblingCount = $(`[${this.cloneableAttributeName}=${attrName}]`).length

    return siblingCount <= (parent.data("cloneable-min") || 0)
  }
}

