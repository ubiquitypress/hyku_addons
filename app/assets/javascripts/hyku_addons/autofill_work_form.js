class AutofillWorkForm {
  constructor(){
    this.targetInputSelector = "select, input, textarea, checkbox, radio"
    this.buttonSelector = "#doi-autofill-btn"
    this.form = $(this.buttonSelector).closest("form")
    this.arrayValuesLength = 0
    this.updatedFields = []
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

    // Switch to the description tab automatically
    $("[aria-controls='metadata']").click()

    Object.entries(this.response.data).forEach(([field, value]) => {
      this.processField(field, value)
    })

    this.logUpdated()
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

      // This isn't using the normal setValue method because of the requirement to autofill nested groups of fields
      Object.entries(value).forEach(([childField, childValue]) => {
        $(wrapper.find($(this.inputSelector(childField))).find(this.targetInputSelector).get(0)).val(childValue)
      })

      // Don't create extra cloneable blocks unless we have more data to add
      if (index + 1 < this.arrayValuesLength) {
        wrapper.find("[data-on-click=clone_parent], .add_funder").trigger("click")
      } else {
        this.setUpdated(field)
      }
    } else {
      this.setValue(field, value)
    }
  }

  setValue(field, value, index = 0) {
    if (this.isBlank(value)) {
      return false
    }

    let input = $($(this.inputSelector(field)).find(this.targetInputSelector).get(index))
    if (input.length > 0) {
      this.setUpdated(field)
      input.val(value)
    }
  }

  logUpdated() {
    let fields = "The following fields were auto-populated: <br><br>"

    fields += this.updatedFields.map((field) => {
      return field.split("_").map((str) => { return str.charAt(0).toUpperCase() + str.slice(1) }).join(" ")
    }).join(", ")

    let wrapper = $("<div/>", { class: "updated-fields text-danger" })
    wrapper.prependTo(this.form).html(fields)
  }

  setUpdated(field) {
    this.updatedFields.push(field)
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
