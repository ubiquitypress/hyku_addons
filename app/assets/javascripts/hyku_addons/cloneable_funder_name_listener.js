// A specific cloneable listener for the funder name form field.
// This should really be more generic, but for now I am just trying to replicate
// legacy functionality and condence it into a smaller area so that it can be
// more easily refactored later.
class CloneableFunderNameListener {
  constructor(){
    this.eventName = "clone_group"
    this.targetSelector = ".funder_name"
    this.cloneableGroupName = "cloneable-funder"

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

  onEvent(_event, clicked) {
    let $clicked = $(clicked)

    if ($clicked.data("cloneable-target") !== this.cloneableGroupName) {
      return
    }

    let $target = $clicked
      .closest("[data-cloneable]")
      .find(`[data-cloneable-group='${this.cloneableGroupName}']:last`)
      .find(".funder_name")

    this.attachFunderAutoComplete($target)
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
