// Example:
//
// <div data-cloneable data-after-clone-action="clear_inputs">
//   <a href="#" data-turbolinks="false" data-on-click-event="clone_parent">Add another</a>
//   <a href="#" data-turbolinks="false" data-on-click-event="remove_parent">Remove</a>
// </div>

class Cloneable {
  cloneableSelector = "[data-cloneable]"
  afterEventsDataAttributeName = "data-after-clone-action"

  constructor(){
    this.registerListeners()
  }

  registerListeners(){
    $("body").on("clone_parent", this.onClone.bind(this))
    $("body").on("remove_parent", this.onRemove.bind(this))
  }

  onClone(event, clicked){
    event.preventDefault()
    console.log("Cloneable.onClone")

    let target = clicked.closest(this.cloneableSelector).last()
    let clone = target.clone()

    clone.insertAfter(target)
    this.triggerElementAfterEvents(clone)
  }

  onRemove(event, clicked){
    event.preventDefault()
    console.log("Cloneable.onRemove")

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
}

