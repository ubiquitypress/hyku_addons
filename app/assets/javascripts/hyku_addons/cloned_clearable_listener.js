// Example:
// $("body").trigger("clear_cloned", [$(el)])

class ClonedClearableListener {
  constructor(){
    this.eventName = "clear_cloned"
    this.actionName = "remove_group"

    this.registerListeners()
  }

  registerListeners(){
    $("body").on(this.eventName, this.onEvent.bind(this))
  }

  // Trigger the default events so that min-numbers etc are maintained
  onEvent(_event, target){
    $(target).find(`[data-cloneable] a[data-on-click=${this.actionName}]`).each($.proxy(function(_i, el){
      $("body").trigger(this.actionName, [$(el)])
    }, this))
  }
}
