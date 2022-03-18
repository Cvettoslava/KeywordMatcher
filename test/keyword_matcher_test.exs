defmodule KeywordMatcherTest do
  use ExUnit.Case
  @module KeywordMatcher

  describe "match" do
    test "return true if kw is in" do
      keyword = "one"
      text = "one three"

      actual = @module.match?(text, keyword)
      assert actual == true
    end
  end

  test "no word characters" do
    keyword = "**)_%"
    text = "one two three four five"
    
    actual = @module.match?(text, keyword)

    assert actual == false
  end

  test "just a single word with wildcard" do
    keyword = "tw*"
    text = "one two three four five"
    
    actual = @module.match?(text, keyword)

    assert actual == true
  end
  
  test "test sentence of ands" do
    keyword = "one two thre*"
    text = "one two three four five"

    actual = @module.match?(text, keyword)

    assert actual == true
  end

  test "order of words doesn't not matter" do
    keyword = "four one"
    text = "one two three four five"
    
    actual = @module.match?(text, keyword)

    assert actual == true
  end
   
  test "more than  one whitespace" do
    keyword = "three     AND one  five"
    text = "one two three four five"
    
    actual = @module.match?(text, keyword)

    assert actual == true
  end

  test "OR and also AND operator" do
    keyword = "three   OR  AND on  fiv*"
    text = "one two three four five"
    
    actual = @module.match?(text, keyword)

    assert actual == true
  end

  test "test OR operation" do
    keyword = "thre OR fiv"
    text = "one two three four five"
    
    actual = @module.match?(text, keyword)

    assert actual == false
  end

  test "empty strings" do
    keyword = ""
    text = "a"
    
    actual = @module.match?(text, keyword)

    assert actual == "The empty string is not possible to be matched. Please enter some text in it!"
  end

  test "wildcard in the middlle of a word" do
    keyword = "three  AND on*e  five"
    text = "one two three four five"
    
    actual = @module.match?(text, keyword)

    assert actual == true
  end

  test "wildcard at the end of a OR" do
    keyword = "three  AND OR*  five"
    text = "one two three four five"
    
    actual = @module.match?(text, keyword)

    assert actual == false
  end

  test "wildcard at the end of a AND" do
    keyword = "three  AND* OR  fiv"
    text = "one two three four five"
    
    actual = @module.match?(text, keyword)

    assert actual == false
  end
end
