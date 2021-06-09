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
  constructor(){
    this.cloneableAttributeName = "data-cloneable"
    this.cloneableSelector = `[${this.cloneableAttributeName}]`
    this.cloneableTargetAttributeName = "data-cloneable-target"
    this.cloneableTargetSelector = `[${this.cloneableTargetAttributeName}]`
    this.afterEventsDataAttributeName = "data-after-clone"

    this.registerListeners()
  }

  registerListeners(){
    $("body").on("clone_parent", this.onClone.bind(this))
    $("body").on("remove_parent", this.onRemove.bind(this))
  }

  onClone(event, clicked){
    event.preventDefault()

    let target = this.findTargets(clicked).first()
    let clone = target.clone()

    clone.insertAfter(this.findTargets(clicked).last())
    this.triggerElementAfterEvents(clone)
  }

  onRemove(event, clicked){
    event.preventDefault()

    if(this.reachedMinCount(clicked)) {
      return false
    }

    clicked.closest(this.cloneableTargetSelector).remove()
  }

  // addBack includes the current element if that is the cloneable-target, so this could include
  // the parent div and its children, or just the children
  findTargets(clicked) {
    return clicked.closest(this.cloneableSelector)
      .find(this.cloneableTargetSelector)
      .addBack(this.cloneableTargetSelector)
  }

  // Trigger any events requested, allowing for multiple space delimited event names
  triggerElementAfterEvents(element){
    // Ensure we have events to trigger and account for times when no events are require
    let events = (element.attr(this.afterEventsDataAttributeName) || "").split(" ").filter(String)

    if (events.length == 0) {
      return false;
    }

    events.forEach((event) => $("body").trigger(event, [element]))
  }

  // Set a min number of sublings for a cloneable element by:
  // ... data-cloneable-min="1"
  reachedMinCount(clicked) {
    let parent = clicked.closest(this.cloneableSelector)
    // let attrName = parent.attr(this.cloneableTargetAttributeName)
    let targets = this.findTargets(clicked)
    let attrName = targets.last().attr(this.cloneableTargetAttributeName)
    let siblingCount = $(`[${this.cloneableTargetAttributeName}=${attrName}]`).length

    return siblingCount <= (parent.data("cloneable-min") || 0)
  }
}

