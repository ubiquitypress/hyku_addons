class PrefillWorkFormViaDOI {
  constructor(){
    this.targetInputSelector = "select, input, textarea, checkbox, radio"
    this.buttonSelector = "#doi-autofill-btn"
    this.form = $(this.buttonSelector).closest("form")
    // Object wide caceh for items in arrays
    this.arrayValuesLength = 0

    this.registerListeners()

    // NOTE:
    // Use the following for debugging only
    $(this.buttonSelector).attr("data-confirm", "")
    $("input#article_doi").val("http://doi.org/10.7554/eLife.63646")
    $("#doi-autofill-btn").click()
  }

  registerListeners(){
    $("body").on("ajax:success", this.buttonSelector, this.onSuccess.bind(this))
  }

  onSuccess(event, response) {
    this.response = JSON.parse(response)

    if (!this.response.data) {
      return false
    }

    console.info("response: ", this.response.data)

    // Switch to the description tab automatically
    $("[aria-controls='metadata']").click()

    Object.entries(this.response.data).forEach(([field, value]) => {
      this.processField(field, value)
    })
  }

  processField(field, value, index = 0) {
    if (this.isBlank(value)) {
      return false;
    }

    if ($.type(value) == "array") {
      this.arrayValuesLength = value.length

      $(value).each((i, val) => {
        // If we need to check JSON fields recursively
        if ($.type(val) == "object") {
          return this.processField(field, val, i)
        }

        this.setValue(field, val, i)
        this.wrapper(field).find('button.add').click()
      })

    } else if ($.type(value) == "object") {
      var wrapper = this.wrapper(field, index)

      Object.entries(value).forEach(([childField, childValue]) => {
        $(wrapper.find($(this.inputSelector(childField))).find(this.targetInputSelector).get(0)).val(childValue)
      })

      // Don't create extra cloneable blocks unless we have more data to add
      if (index + 1 < this.arrayValuesLength) {
        wrapper.find("[data-on-click=clone_parent]").trigger("click")
      }
    } else {
      this.setValue(field, value)
    }
  }

  setValue(field, value, index = 0) {
    if (this.isBlank(value)) {
      return false
    }

    $($(this.inputSelector(field)).find(this.targetInputSelector).get(index)).val(value)
  }

  inputSelector(field) {
    return `.${this.fieldName(field)}`
  }

  // returns the jq wrapper object with the correct index
  wrapper(field, index = 0) {
    return $($(this.wrapperSelector(field)).get(index))
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
