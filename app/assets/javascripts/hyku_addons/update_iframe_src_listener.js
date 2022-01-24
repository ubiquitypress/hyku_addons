// It's not possible to update external iframe SRCs once the page has loaded, due to the same-origin policy, so this
// class will create a new iframe DOM element, copy the existing ifames attributes and replace it in its parent.
//
// Example:
// <% options = { class: "js-reports-trigger form-control", data: { "on-change" => "update_iframe_src", iframe_id: "container_frame" }, include_blank: "Please Select..." } %>
// <%= select_tag :report, options_for_select(@reports), options %>
class UpdateIframeSrcListener {
  constructor() {
    this.eventName = "update_iframe_src"
    this.iframeId = "iframeId"
    this.introSelector = "#reports_intro"

    this.registerListeners()
  }

  registerListeners() {
    $("body").on(this.eventName, this.onEvent.bind(this))
  }

  onEvent(_, $select) {
    let $iframe = $(`#${$select.data(this.iframeId)}`)
    this.recreateIframe($select, $iframe)
  }

  recreateIframe($select, $iframe) {
    let [height, width, src] = $select.val().split(",")

    // If the user selected the blank option, or they selected the current chart after selecting the blank options
    if (src === undefined || src == $iframe.attr("src")) {
      return
    }

    $(this.introSelector).hide()

    let newIframe = this.buildIframeFromExisting($iframe)
    let $parent = $iframe.parent()
    $iframe.remove()


    newIframe.setAttribute("src", src)
    newIframe.width = "100%"
    newIframe.height = `${height}px`
    newIframe.style.display = "block"

    // Record the dimensions and ratio so that proportions can be maintained on resize
    $parent.data("ratio", height/width).data("width", width).data("height", height)
    $parent.append(newIframe)

    this.createResizeEvent($parent)
  }

  // Build the new iframe dom element and copy over all of the previous iframes attributes
  buildIframeFromExisting($existing) {
    let attrs = $existing[0].attributes
    let newIframe = document.createElement("iframe")

    $(attrs).each(function() { $(newIframe).attr(this.nodeName, this.nodeValue) })

    return newIframe
  }

  createResizeEvent($parent) {
    $parent.height($parent.data("ratio") * $parent.width())

    const resizeObserver = new ResizeObserver(entries => {
      for (let entry of entries) {
        let $el = $(entry.target);

        $el.height($el.data("ratio") * $el.width())
      }
    })

    resizeObserver.observe($parent[0])
  }
}
