// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require_tree .

const SelectWorkType = require("hyku_addons/select_work_type")

const onLoad = function() {
  // Prevent JS being loaded twice
  if ($("body").attr("data-js-loaded") === "true") {
    return
  }

  // Register listeners before events, so that onload events are consumed
  // Listeners
  new InputClearableListener()
  new RequiredFieldListener()
  new RequiredGroupFieldListener()
  new CloneableListener()
  // We have onload methods here so this needs to be called last,
  // or it might try and trigger an event not being listened to
  new ChangeToggleableListener()

  // Register our Events
  new Eventable()

  new PrefillWorkFormViaDOI()

  $("[data-behavior=hyku_addons-select-work]").each(function() {
    new SelectWorkType($(this))
  });

  $("body").attr("data-js-loaded", "true")
}

// Ensure that page load (via turbolinks) and page refresh (via browser request) both load JS
$(document).ready(onLoad)
$(document).on("turbolinks:load", onLoad)
