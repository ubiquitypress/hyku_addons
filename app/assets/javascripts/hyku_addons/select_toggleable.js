class SelectToggleable {
  parentSelector = ".js-select-toggle"
  addSelector = ".js-select-toggle-add"
  removeSelector = ".js-select-toggle-remove"
  changeSelector = ".js-select-toggle-change"
  fieldBlurSelector = ".js-select-toggle-blur"

  constructor(){
    this.registerEvents()
  }

  registerEvents(){
    $("body").on("click", this.addSelector, this.addSection.bind(this))
    $("body").on("click", this.removeSelector, this.removeSection.bind(this))
    $("body").on("change", this.changeSelector, this.changeSection.bind(this))
    $("body").on("blur", this.fieldBlurSelector, this.onFieldBlur.bind(this))
  }

  addSection(event){
    event.preventDefault()
  }

  removeSection(event){
    event.preventDefault()
  }

  changeSection(event){
    event.preventDefault()
  }

  onFieldBlur(event){

  }
}

$(document).on("turbolinks:load", function(){
  const toggleable = new SelectToggleable()
});
