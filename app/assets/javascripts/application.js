// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require jquery.remotipart
//= require js-routes
//= require twitter/bootstrap/bootstrap
//      nope: require turbolinks
//= require jquery/jqueryui/jquery-ui-1.10.3.custom.min
//= require cowboy/jquery-hashchange/jquery.ba-hashchange.min
//= require morr/jquery-appear/jquery.appear
//= require eternicode/bootstrap-datepicker/bootstrap-datepicker
//= require smalot/bootstrap-datetimepicker/bootstrap-datetimepicker
//= require jherdman/javascript-relative-time-helpers/date.extensions
//= require silviomoreto/bootstrap-select/bootstrap-select.min
//= require jquery-fileupload/basic
//= require codemirror
//= require codemirror/addons/edit/matchbrackets
//= require codemirror/modes/python
//= require codemirror/modes/markdown
//= require global
//= require media-library
//= require typeaheads
//= require highcharts
//= require highcharts/highcharts-more
//= require highcharts-theme

// Add the route helpers directly into the window object for easy access.
$.extend(window, Routes)
