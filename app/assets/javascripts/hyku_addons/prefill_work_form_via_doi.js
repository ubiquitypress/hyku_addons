class PrefillWorkFormViaDOI {
  constructor(){
    this.buttonSelector = "#doi-autofill-btn"
    this.form = $(this.buttonSelector).closest("form")

    // TODO: Remove this when out of development
    $(this.buttonSelector).attr('data-confirm', false)

    this.registerListeners()
  }

  registerListeners(){
    $("body").on("ajax:success", this.buttonSelector, this.onSuccess.bind(this))
  }

  onSuccess(event, response) {
    this.response = JSON.parse(response)

    if (!this.response.data) {
      return false
    }

    // console.log(this.response.data)

    Object.entries(this.response.data).forEach(([field, value]) => {
      this.processField(field, value)
    })
  }

  processField(field, value) {
    if ($.type(value) == "array") {
      $(value).each((index, val) => {
        this.setValue(field, val, index)

        // We can only add one new field at a time
        $(this.wrapperSelector(field)).find('button.add').click()
      })

    } else if ($.type(value) == "object") {
      Object.entries(value).forEach(([field, value]) => {
        this.setValue(field, value)
      })

    } else {
      this.setValue(field, value)
    }
  }

  setValue(field, value, index = 0) {
    if (value == undefined || value.length == 0) {
      return false
    }

    $($(this.inputSelector(field)).get(index)).val(value)
  }

  inputSelector(field) {
    return `${this.wrapperSelector(field)} .${this.fieldName(field)}`
  }

  wrapperSelector(field) {
    return `div.${this.fieldName(field)}`
  }

  fieldName(field) {
    return `${this.response.curation_concern}_${field}`
  }
}
