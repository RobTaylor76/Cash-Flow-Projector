#fixture.preload('ledger_entries_table.html')

describe "Calculator", ->
  beforeEach -> 
    fixture.load('ledger_entries_table.html')

  it "loads fixtures", ->
    expect($("h1", fixture.el).text()).toBe("Ledger Entries Test Page") # using fixture.el as a jquery scope
