// When the work form is submitted this listener will look for any hidden toggleable elements and remove them
class RemoveToggleableOnSubmitListener {
  constructor(){
    this.eventName = "work-form-submit"

    this.registerListeners()
  }

  registerListeners(){
    $("body").on(this.eventName, this.onEvent.bind(this))
  }

  onEvent(_event, target){
    // We cannot use `:hidden` as the user might not show additional fields so all elements would be hidden
    $(target).find("[data-toggleable-remove-on-submit][style*='display: none']").remove()
  }
}

