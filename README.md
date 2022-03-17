# Keyword Matcher

Language: Elixir

In this task you have to complete the implementation for the following module:

```elixir
defmodule KeywordMatcher do
	def match?(text, keyword) do
		Enum.random([true, false])
	end
end
```

This module has a single task: to check whether a given keyword matches a given text or not. The text is simply an arbitrary string. The keyword has a certain format, which we describe here.

### Keyword syntax

- Keywords are always written in disjunctive normal form (DNF). See [Wikipedia](https://en.wikipedia.org/wiki/Disjunctive_normal_form)

- In the simplest form, the keyword consists of a single term. This may or may not appear in the text. In this case, the matcher should specifically check whether it occurs as a whole word in the text (and not as a substring of a longer word). Example: _"elixir"_

- WILDCARD: A wildcard is allowed at the end of a term. This keyword then matches (besides whole words) also on substrings. Example: _"elixir*"_

- AND: If a keyword consists of several terms separated by spaces, this is to be considered as an AND operation. In this case, the matcher should check that all terms are really present in the given text. Example: _"language elixir erlang"_

- OR: A keyword can also consist of several terms, of which only one must be found. In such a case we use the OR operator (which is actually written out). Example: _"language OR elixir OR erlang"_

- Parentheses: Parentheses can be optionally placed around single terms. Whether these are present or not should not affect the result of the matcher. They primarily increase the readability of a long keyword for the human eye. Example: _"(erlang language) OR (elixir language)"_

Here is an example of a longer keyword, which could be composed according to the above rules:

```
(Elixir OR (functional concurrent) OR BEAM OR (programming language) OR (Erlang application*) OR (build* distributed) OR (HEX DOC) OR ExUnit OR (Phoenix Framework))
```

### Additional instructions

- Comparison should not be made case sensitive.

- Make sure that the code is easy to read. This will allow your colleagues (and your future self) to understand it quickly if something needs to be added or fixed there.

- Think of meaningful tests. Maybe start with a few simple examples and work your way up to more complicated scenarios. The tests for the simple cases will then give you the security that you will not break anything that has already been achieved during further development and refactoring.

### Bonus

Think about how to make the implementation even more robust. Does it still work if the OR operator is suddenly lowercase? Or if the number of spaces surrounding the OR operator varies all at once? Or the number of opening and closing parentheses don't match? And so on...