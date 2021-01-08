class Duplicatable {
  constructor(){
    this.registerListeners()
  }

  registerListeners(){
    console.log("Duplicatable.registerListeners")

    $("body").on("duplicate_parent", this.onDuplicateParentEvent.bind(this))
    $("body").on("remove_parent", this.onRemoveParentEvent.bind(this))
  }

  onDuplicateParentEvent(){
    console.log("Duplicatable.onDuplicateParentEvent")
  }

  onRemoveParentEvent(){
    console.log("Duplicatable.onRemoveParentEvent")

  }
}

