$(function() {

function appendNewLegderEntryRow() {
  numberOfRows = $("#ledger_entries tr.ledger_entry").size()
  firstRow = $("#ledger_entries tr.ledger_entry:first").clone()

  inputs = $("[name*=0]",firstRow)

  inputs.each(function(index, input) {
    name_regex = /\[0\]/
    id_regex = /_0_/
    $input = $(input)
    $input.attr("name", $input.attr("name").replace(name_regex, "["+numberOfRows+"]"));
    $input.attr("id", $input.attr("id").replace(id_regex, "_"+numberOfRows+"_"));
  });
  $('#ledger_entries').append(firstRow)
}
/**  this is needed for the jasmine tests as doc ready fireed before fixtures added...
$(document).on('click', '#add-table-row', appendNewLegderEntryRow);
**/

$('#add-table-row').click(function() {
  appendNewLegderEntryRow()
});

});
