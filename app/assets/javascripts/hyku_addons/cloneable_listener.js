class CloneableListener {
  constructor(){
    this.cloneableAttribute = "data-cloneable"
    this.cloneableSelector = `[${this.cloneableAttribute}]`
    this.groupAttribute = "data-cloneable-group"
    this.groupSelector = `[${this.groupAttribute}]`
    this.targetAttribute = "data-cloneable-target"
    this.afterEventsDataAttribute = "data-after-clone"

    this.registerListeners()
  }

  registerListeners(){
    $("body").on("clone_parent", this.onClone.bind(this))
    $("body").on("remove_parent", this.onRemove.bind(this))
  }

  onClone(event, clicked){
    event.preventDefault()

    let sibling = this.siblings(clicked).last()
    let clone = sibling.clone()

    clone.insertAfter(sibling)

    this.triggerElementAfterEvents(clone)
  }

  onRemove(event, clicked){
    event.preventDefault()

    if(this.reachedMinCount(clicked)) {
      return false
    }

    clicked.closest(this.groupSelector).remove()
  }

  // Trigger any events requested, allowing for multiple space delimited event names
  triggerElementAfterEvents(element){
    // Ensure we have events to trigger and account for times when no events are require
    let events = (element.attr(this.afterEventsDataAttribute) || "").split(" ").filter(String)

    if (events.length == 0) {
      return false;
    }

    events.forEach((event) => $("body").trigger(event, [element]))
  }

  // Set a min number of sublings for a cloneable element by: data-cloneable-min="1"
  reachedMinCount(clicked) {
    let siblingCount = this.siblings(clicked).length
    let minimum = this.parent(clicked).data("cloneable-min") || 0

    return siblingCount <= minimum
  }

  siblings(clicked) {
    let attrName = clicked.attr(this.targetAttribute)

    return clicked.closest(this.cloneableSelector).find(`[${this.groupAttribute}=${attrName}]`)
  }

  parent(clicked) {
    return clicked.closest(this.cloneableSelector)
  }
}

