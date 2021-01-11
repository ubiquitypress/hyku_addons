class ToggleRequiredListener {
  setEventName = "set_required"
  unsetEventName = "unset_required"
  afterCreateRequiredSelector = "[data-required]"
  requiredTagClass = "required-tag"
  requiredTagSelector = `.${this.requiredTagClass}`

  constructor(){
    this.registerListeners()
  }

  registerListeners(){
    $("body").on(this.setEventName, this.onSetEvent.bind(this))
    $("body").on(this.unsetEventName, this.onUnsetEvent.bind(this))
  }

  onSetEvent(event, target){
    this.toggleRequired(target, true)
    this.addRequiredLabel(target)
  }

  onUnsetEvent(event, target){
    this.toggleRequired(target, false)
    this.removeRequiredLabel(target)
  }

  toggleRequired(target, state) {
    this.requiredChildren(target).prop("required", state)
  }

  addRequiredLabel(target){
    this.requiredChildren(target).each($.proxy(function(i, el){
      let parent = $(el).closest(".form-group")

      if (parent.find(`label ${this.requiredTagSelector}`).length > 0) {
        return false
      }

      parent.find("label").append(this.createRequiredTag(el))
    }, this))
  }

  removeRequiredLabel(target){
    this.requiredChildren(target).each($.proxy(function(i, el){
      let parent = $(el).closest(".form-group")

      parent.find(`label ${this.requiredTagSelector}`).remove()
    }, this))
  }

  requiredChildren(target) {
    return target.find(this.afterCreateRequiredSelector)
  }

  // This is hardcoded as a form might not have a label to clone
  createRequiredTag(target) {
    return `<span class="label label-info ${this.requiredTagClass}">required</span>`
  }
}
