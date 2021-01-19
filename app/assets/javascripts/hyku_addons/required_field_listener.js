// Example:
// <input type="text" value="" data-required>

class RequiredFieldListener {
  constructor(){
    this.setEventName = "set_required";
    this.unsetEventName = "unset_required";
    this.requiredTagClass = "required-tag";
    this.requiredTagSelector = `.${this.requiredTagClass}`;

    this.registerListeners();
  }

  registerListeners(){
    $("body").on(this.setEventName, this.onSetEvent.bind(this));
    $("body").on(this.unsetEventName, this.onUnsetEvent.bind(this));
  }

  onSetEvent(event, target){
    this.toggleRequired($(target), true);
    this.addRequiredLabel($(target));
  }

  onUnsetEvent(event, target){
    this.toggleRequired($(target), false);
    this.removeRequiredLabel($(target));
  }

  toggleRequired(target, state) {
    target.prop("required", state);
  }

  addRequiredLabel(target){
    let parent = $(target).closest(".form-group");

    if (parent.find(`label ${this.requiredTagSelector}`).length > 0) {
      return false;
    }

    parent.find("label").append(this.createRequiredTag(target));
  }

  removeRequiredLabel(target){
    let parent = $(target).closest(".form-group");

    parent.find(`label ${this.requiredTagSelector}`).remove();
  }

  // This is hardcoded as a form might not have a label to clone
  createRequiredTag(target) {
    return `<span class="label label-info ${this.requiredTagClass}">required</span>`;
  }
}
