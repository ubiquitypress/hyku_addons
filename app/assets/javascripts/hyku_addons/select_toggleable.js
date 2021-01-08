class Eventable {
  constructor(){
    this.registerEvents()
  }

  registerEvents(){
    console.log("Eventable.registerEvents")

    $("body").on("change", `[data-on-change-event]`, function(){
      let eventName = $(this).data("on-change-event")

      console.log(`Eventable.trigger event: ${eventName}`)
      $("body").trigger(eventName, [$(this)])
    })
  }
}

class SelectGroupToggle {
  parentSelector = ".js-toggle"
  groupSelector = ".js-toggle-group"
  controlSelector = ".js-toggle-control"

  constructor(){
    this.onLoad()
    this.registerListeners()
  }

  onLoad(){
    console.log("SelectGroupToggle.onLoad")

    // Can't seen to get this to work via triggering the change event
    $(this.controlSelector).each($.proxy(function(i, el){
      this.toggleSelectGroup($(el))
    }, this))
  }

  registerListeners(){
    console.log("SelectGroupToggle.registerListeners")

    $("body").on("toggle_group", this.onToggleGroupEvent.bind(this))
  }

  onToggleGroupEvent(_event, target){
    this.toggleSelectGroup(target)
  }

  toggleSelectGroup(target){
    console.log(`SelectGroupToggle.Receive Event: ${event.type}`)

    let val = target.val()
    $(this.groupSelector).hide()
    $(`${this.groupSelector}[data-toggle-group=${val}]`).show()
  }
}

$(document).on("turbolinks:load", function(){
  const events = new Eventable()
  const selectListener = new SelectGroupToggle()
});
