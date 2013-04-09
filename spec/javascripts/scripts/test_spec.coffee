fixture.preload('nested/nested_template.html')

describe "Calculator", ->
  beforeEach -> 
    fixture.load('nested/nested_template.html')

  it "loads fixtures", ->
    expect($("h1", fixture.el).text()).toBe("foo") # using fixture.el as a jquery scope


  it "should add two digits", ->
    expect( new Calculator().add(2,2) ).toBe(4)
