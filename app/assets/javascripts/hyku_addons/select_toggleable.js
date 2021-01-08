class Eventable {
  constructor(){
    this.registerEvents()
  }

  registerEvents(){
    console.log("registerEvents")
    $("body").on("change", `[data-on-event=change]`, function(){
      let eventName = $(this).data("send-event")

      console.log(`trigger event: ${eventName}`)
      $("body").trigger(eventName, [$(this)])
    })
  }
}

class SelectToggleableListener {
  groupSelector = ".js-toggle-group"

  constructor(){
    this.registerListeners()
  }

  registerListeners(){
    console.log("registerListeners")

    $("body").on("toggle_group", this.toggleSelectGroup.bind(this))
  }

  toggleSelectGroup(event, target){
    console.log(`Performing: ${event.type}`)

    let val = target.val()
    $(this.groupSelector).hide()
    $(`${this.groupSelector}[data-toggle-group=${val}]`).show()
  }
}

$(document).on("turbolinks:load", function(){
  const events = new Eventable()
  const selectListener = new SelectToggleableListener()
});
