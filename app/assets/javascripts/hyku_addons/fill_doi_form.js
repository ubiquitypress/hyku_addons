class FillDOIForm {
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

    console.log(response.data)

    Object.entries(this.response.data).forEach(([field, value]) => {
      if (value == undefined || value.length == 0) {
        return false
      }

      this.processField(field, value)
    })
  }

  processField(field, value) {
    if (this.response.fields.json.includes(field)) {
      console.log('json', field, value)

    } else if (this.response.fields.date.includes(field)) {
      console.log('date', field, value)

    } else if (Array.isArray(value)) {
      $(value).each((index, val) => {
        this.setValue(field, val, index)

        $(this.wrapperSelector(field)).find('button.add').click()
      })

    } else {
      this.setValue(field, value)
    }
  }

  setValue(field, value, index = 0) {
    $($(this.inputId(field)).get(index)).val(value)
  }

  inputId(field) {
    return `#${this.fieldName(field)}`
  }

  wrapperSelector(field) {
    return `div.${this.fieldName(field)}`
  }

  fieldName(field) {
    return `${this.response.curation_concern}_${field}`
  }
}
