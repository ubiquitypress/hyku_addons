class PrefillWorkFormViaDOI {
  constructor(){
    this.targetInputSelector = "select, input, textarea, checkbox, radio"
    this.buttonSelector = "#doi-autofill-btn"
    this.form = $(this.buttonSelector).closest("form")

    // TODO: Remove this when out of development
    // $(this.buttonSelector).attr('data-confirm', false)

    this.registerListeners()

    // TODO:
    // Remove this testing code
    // $('#generic_work_doi').val('10.21250/tcq')
    // $(this.buttonSelector).click()
    // $("[aria-controls=metadata]").click()
  }

  registerListeners(){
    $("body").on("ajax:success", this.buttonSelector, this.onSuccess.bind(this))
  }

  onSuccess(event, response) {
    this.response = JSON.parse(response)

    if (!this.response.data) {
      return false
    }

    Object.entries(this.response.data).forEach(([field, value]) => {
      this.processField(field, value)
    })
  }

  processField(field, value) {
    if (this.isBlank(value)) {
      return false;
    }

    if ($.type(value) == "array") {
      $(value).each((index, val) => {
        // If we need to check JSON fields recursively
        if ($.type(val) == "object") {
          return this.processField(field, val)
        }

        this.setValue(field, val, index)
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
    if (this.isBlank(value)) {
      return false
    }

    $($(this.inputSelector(field)).filter(this.targetInputSelector).get(index)).val(value)
  }

  inputSelector(field) {
    return `.${this.fieldName(field)}`
  }

  wrapperSelector(field) {
    return `div.${this.fieldName(field)}`
  }

  fieldName(field) {
    return `${this.response.curation_concern}_${field}`
  }

  isBlank(value) {
    value == undefined || value.length == 0
  }
}
