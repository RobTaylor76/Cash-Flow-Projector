fixture.preload('ledger_entries_table.html')

describe "Ledger Entries", ->
  beforeEach -> 
    fixture.load('ledger_entries_table.html')

  it "loads fixtures", ->
    expect($("h1", fixture.el).text()).toBe("Ledger Entries Test Page") # using fixture.el as a jquery scope

  it "should have a button and 2 ledger entry rows", ->
    expect($("#add-table-row").length).toBe(1)
    expect($("#ledger_entries tr.ledger_entry").size()).toBe(2)

  it "should add an new ledger entry row when button is clicked", ->
    #expect($("#ledger_entries tr.ledger_entry [name=*3]").size()).toBe(0)
    #expect($("#ledger_entries tr.ledger_entry [id=*3]").size()).toBe(0)
    $("#add-table-row").trigger("click")
    expect($("#ledger_entries tr.ledger_entry").size()).toBe(3)
    #expect($("#ledger_entries tr.ledger_entry [name=*3]").size()).toBe(4)
    #expect($("#ledger_entries tr.ledger_entry [id=*3]").size()).toBe(4)
