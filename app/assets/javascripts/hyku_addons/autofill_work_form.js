class AutofillWorkForm {
  constructor(){
    this.targetInputSelector = "select, input, textarea, checkbox, radio"
    this.buttonSelector = "#doi-autofill-btn"
    this.$button = $(this.buttonSelector)
    this.$form = this.$button.closest("form")
    this.arrayValuesLength = 0
    this.updatedFields = []
    this.logClass = "autofill-message"

    // TODO: Move translations to site locale and add to admin header section
    this.successMessage = "The following fields were auto-populated:"
    this.failureMessage = "The DOI entered did not return any data"
    this.errorMessage = "An error occured, the DOI might not be valid"
    this.alternateFieldLabels = {
      doi: "DOI",
      issn: "ISSN",
      isbn: "ISBN",
      eissn: "eISSN",
      official_link: "Official URL"
    }

    if (this.$button.length === 0) {
      return false
    }

    this.alterRequestFormat()
    this.registerListeners()
  }

  // If we do not provide a JSON request, then we receive console errors resulting from the JS response.
  // Ideally, this would be done inside the button path generation, but it relies on a url_helper inside a gem.
  alterRequestFormat() {
    let href = this.$button.attr("href") || ""
    this.$button.attr("href", href + ".json")
  }

  registerListeners() {
    // We don't want to use the default alert error messages
    this.$button.off("ajax:error")
    this.$button.on("click", this.clearLog.bind(this))
    $("body").on("ajax:success", this.buttonSelector, this.onSuccess.bind(this))
    $("body").on("ajax:error", this.buttonSelector, this.onError.bind(this))
  }

  onSuccess(_e, response) {
    this.response = response

    if ($.isEmptyObject(this.response.data)) {
      return this.logFailure();
    }

    // Switch to the description tab automatically
    $("[aria-controls='metadata']").click()

    Object.entries(this.response.data).forEach(([field, value]) => {
      this.processField(field, value)
    })

    this.logSuccess()
  }

  onError() {
    this.logMessage($("<p/>", { text: this.errorMessage }), "danger")
  }

  // This method performs most of the heavy lifting. It accepts a field name, a value and the index for the element.
  // It will then try and workout the correct field to place the value within.
  //
  // Value could be:
  // an array of objects, each of which contains multiple subfields and their value,
  // an object of subfields and their values
  // a string / int value
  processField(field, value, index = 0) {
    if (this.isBlank(value)) {
      return false;
    }

    // Dealing with edgecases by checking for a specific method to process a field, however this is only used for
    // legacy funder fields and otherwise should be processed normally with the cloneable code.
    if (this[`process_${field}`]) {
      this[`process_${field}`](value, index)

    } else if ($.type(value) == "array") {
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
      // Since a refactor how groups nested elements, we cannot use the default class selector
      // and instead must look for cloneable elements within the wrapper. This means that if there
      // are any subfields that are cloneable, then we will not count this by mistake
      var $wrapper = $($(this.wrapperSelector(field)).find(`[data-cloneable-group=${this.fieldName(field)}]`)[index])

      // If the cloneable enabled check above returns no results, then do one more to ensure that objects for
      // non-cloneable fields (like date_published) are found and can have their value set.
      if ($wrapper.length == 0) {
        $wrapper = $($(this.wrapperSelector(field))[index])
      }

      // This isn't using the normal setValue method because of the requirement
      // to autofill nested groups of fields from within a specific parent wrapper
      Object.entries(value).forEach(([childField, childValue]) => {
        this.setNestedValue($wrapper, childField, childValue)
      })

      // Don't create extra cloneable blocks unless we have more data to add
      if (index + 1 < this.arrayValuesLength) {
        $wrapper.find("[data-on-click=clone_group]").trigger("click")
      } else {
        this.setUpdated(field)
      }
    } else {
      this.setValue(field, value)
    }
  }

  // TODO:
  // This is a slightly modified version of `setValue`. It would be best to use just one, but with the extra
  // requirements to use a specific parent element context, its currently not possible
  setNestedValue(parentElement, childElement, value, index = 0) {
    if (this.isBlank(value)) {
      return false
    }

    // Find the relevant element selector
    var selector = this.inputSelector(childElement)
    // From within the wrapper, find all matching elements and then filter only form fields
    var input = parentElement.find(selector).find(this.targetInputSelector).get(index)

    $(input).val(value).trigger("change")
  }

  // TODO: Make it so that this method can be used by all of the other sections where we are currently specifying
  // the wrapper and setting the value within that.
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

  // This is gross, but untill the schema migration is complete this is a shim for legacy and cloneable funders.
  process_funder(funders) {
    if (this.wrapper("funder").data("cloneable") !== undefined) {
      this.processCloneableFunders(funders)
    } else {
      this.processLegacyFunders(funders)
    }
  }

  // A slightly modified version to deal with the cloneable element structure,
  // which should remain after the schema migration has been completed.
  processCloneableFunders(funders) {
    this.arrayValuesLength = funders.length

    if (this.arrayValuesLength === 0) {
      return false
    }

    funders.forEach((funder, i) => {
      // Get the top level children only
      var $wrapper = $(this.wrapper("funder").children("[data-cloneable-group]").get(i))

      Object.entries(funder).forEach(function([childField, childValue]){
        let setValue = (field, value, index = 0) => {
          $($wrapper.find($(this.inputSelector(field))).find(this.targetInputSelector).get(index)).val(value)
        }

        if ($.type(childValue) === "array") {
          childValue.forEach(function(val, j) {
            setValue(childField, val, j)

            if (j+1 < childValue.length) {
              $($wrapper.find($(this.inputSelector(childField))).not(this.targetInputSelector)).find("[data-on-click=clone_group]").click()
            }
          }, this)

        } else {
            setValue(childField, childValue)
        }
      }, this)

      if (i+1 < this.arrayValuesLength) {
        $wrapper.find("[data-on-click=clone_group]").filter(":last").trigger("click")
      } else {
        this.setUpdated("funder")
      }
    }, this)
  }

  // TODO: Remove this method when the schema migration has been completed
  // Funder has subfields that couldn't be properly updated without tracking parent and child indexes
  processLegacyFunders(funders) {
    this.arrayValuesLength = funders.length

    if (this.arrayValuesLength === 0) {
      return false
    }

    funders.forEach((funder, i) => {
      // Set the parent fields container for each iteration
      var $wrapper = this.wrapper("funder", i)

      Object.entries(funder).forEach(function([childField, childValue]){
        if ($.type(childValue) === "array") {
          childValue.forEach(function(val, j) {
            this.setNestedValue($wrapper, childField, val, j)

            if (j+1 < childValue.length) {
              this.wrapper(childField, i).find(".add-new").trigger("click")
            }
          }, this)

        } else {
          $($wrapper.find($(this.inputSelector(childField))).find(this.targetInputSelector)).val(childValue)
        }
      }, this)

      if (i+1 < this.arrayValuesLength) {
        $wrapper.find(".add_funder").trigger("click")
      } else {
        this.setUpdated("funder")
      }
    }, this)
  }

  logSuccess() {
    let uniqueFields = $.unique(this.updatedFields).sort()

    let fields = uniqueFields
      .map((field) => {
        // If we have an acronym, then use the value from the object above
        if (Object.keys(this.alternateFieldLabels).includes(field)) {
          return this.alternateFieldLabels[field]

        // Otherwise, simply Titleize it
        } else {
          return field.split("_").map((str) => { return str.charAt(0).toUpperCase() + str.slice(1) }).join(" ")
        }
      })
      .join(", ")
      .replace(/,([^,]*)$/, " and" + '$1')

    this.updatedFields = []

    let $titleMessage = $("<p/>", { text: this.successMessage }).add($("<p/>", { text: fields }))

    this.logMessage($titleMessage)
  }

  logFailure() {
    this.logMessage($("<p/>", { text: this.failureMessage }), "danger")
  }

  logMessage(messageHtml, wrapperClass = "success") {
    this.clearLog()

    let $wrapper = $("<div/>", { class: `${this.logClass} bg-${wrapperClass}` }).append(messageHtml)

    $wrapper.prependTo(this.$form)
  }

  clearLog() {
    $(`.${this.logClass}`).remove()
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
