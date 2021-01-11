// Example:
//
// <div data-cloneable data-after-clone-action="clear_inputs">
//   <a href="#" data-turbolinks="false" data-on-click-event="clone_parent">Add another</a>
//   <a href="#" data-turbolinks="false" data-on-click-event="remove_parent">Remove</a>
// </div>

class Cloneable {
  cloneableSelector = "[data-cloneable]"

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
    $("body").trigger(clone.attr("data-after-clone-action"), [clone])
  }

  onRemove(event, clicked){
    event.preventDefault()

    clicked.closest(this.cloneableSelector).remove()
  }
}

