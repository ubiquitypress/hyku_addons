// Example:
//
// <div data-duplicatable data-after-clone-action="clear_inputs">
//   <a href="#" data-turbolinks="false" data-on-click-event="duplicate_parent">Add another</a>
// </div>

class Duplicatable {
  duplicatableSelector = "[data-duplicatable]"

  constructor(){
    this.registerListeners()
  }

  registerListeners(){
    // console.log("Duplicatable.registerListeners")

    $("body").on("duplicate_parent", this.onDuplicateParentEvent.bind(this))
    $("body").on("remove_parent", this.onRemoveParentEvent.bind(this))
  }

  onDuplicateParentEvent(event, clicked){
    event.preventDefault()
    console.log("Duplicatable.onDuplicateParentEvent")

    let target = clicked.closest(this.duplicatableSelector).last()
    let clone = target.clone()

    clone.insertAfter(target)
    $("body").trigger(clone.attr("data-after-clone-action"), [clone])
  }

  onRemoveParentEvent(event, clicked){
    event.preventDefault()
    console.log("Duplicatable.onRemoveParentEvent")
  }
}

