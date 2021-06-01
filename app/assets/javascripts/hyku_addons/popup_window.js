class PopupWindow {
  constructor($target){
    this.$target = $target

    if (this.$target.length === 0) {
      return
    }

    this.registerListeners()
  }

  registerListeners(){
    $("body").on("click", this.$target, this.onClick.bind(this))
  }

  onClick(event) {
    // Check the event target, or all links seem to trigger the modal - not sure why, this is temp until I work it out
    if (event.target !== this.$target[0]) {
      return
    }

    event.preventDefault()

    const $target = $(event.target)
    const width = $target.data("popup-width") || 500
    const height = $target.data("popup-height") || 700
    const url = decodeURIComponent($target.attr("href"))
    const options = this.calculateOptions(width, height);

    const newWindow = window.open(url, $target.attr("title"), options)

    if (window.focus) {
      newWindow.focus();
    }
  }

  // Influenced by this SO post: https://stackoverflow.com/a/16861050/3588645
  calculateOptions(w, h) {
    // Fixes dual-screen position                             Most browsers      Firefox
    const dualScreenLeft = window.screenLeft !==  undefined ? window.screenLeft : window.screenX;
    const dualScreenTop = window.screenTop !==  undefined   ? window.screenTop  : window.screenY;

    const width = window.innerWidth ? window.innerWidth : document.documentElement.clientWidth ? document.documentElement.clientWidth : screen.width;
    const height = window.innerHeight ? window.innerHeight : document.documentElement.clientHeight ? document.documentElement.clientHeight : screen.height;

    const systemZoom = width / window.screen.availWidth;
    const left = (width - w) / 2 / systemZoom + dualScreenLeft
    const top = (height - h) / 2 / systemZoom + dualScreenTop

    return `scrollbars=yes, width=${w / systemZoom}, height=${h / systemZoom}, top=${top}, left=${left}`
  }
}
