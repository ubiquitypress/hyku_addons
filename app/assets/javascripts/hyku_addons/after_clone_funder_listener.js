// Listener to attach the Funder name look up on clone
class AfterCloneFunderListener {
  constructor(){
    this.eventName = "after_clone_funder"
    this.targetSelector = ".funder_name"

    this.onLoad()
    this.registerListeners()
  }

  onLoad(){
    $(this.targetSelector).each($.proxy(function(_i, el){
      this.attachFunderAutoComplete($(el))
    }, this))
  }

  registerListeners() {
    $("body").on(this.eventName, this.onEvent.bind(this))
  }

  onEvent(_event, target) {
    let $input = $(target).find(".funder_name")

    this.attachFunderAutoComplete($input)
  }

  attachFunderAutoComplete($target) {
    $target.autocomplete({
      minLength: 2,
      source: function (request, response) {
        $.getJSON(this.element.data("autocomplete-url"), { q: request.term }, response)
      },
      select: function(_ui, result) {
        let $parent = $(this).closest("[data-cloneable-group]")

        let $awards = $parent.find(".funder_award-group .input-group")
        $awards.not(":first").remove();
        $awards.find("input:visible").val("")

        $parent.find(".funder_doi").val(result.item.uri)
      }
    })
  }
}
