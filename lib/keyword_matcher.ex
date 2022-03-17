defmodule KeywordMatcher do
  @moduledoc """
  Documentation for `KeywordMatcher`.
  """

  @doc """
  ## Examples
  """

  def match?(text, keyword) when keyword != "" or text != "" do
    keyword = clean_kw(keyword)

    list_of_results = List.insert_at([], 0, has_or?(keyword))
    |> List.insert_at(1, has_and?(keyword))
    |> List.insert_at(2, has_wildcard?(keyword))

    case list_of_results do
      [false, true, _] -> helper_f_AND?(text, keyword)
      [true, _, _]-> helper_f_OR?(text, keyword)
      [false, false, false] -> match_single_term?(text, keyword)
      [false, false, true] -> Regex.match?(~r/#{keyword}/i, text)
    end

  end
      
  def match?(_text, _keyword), do: "The empty string is not possible to be matched. Please enter some text in it!"

  def clean_kw(keyword) do
      _keyword = String.replace(keyword, ~r/\sAND\s/," ")
          |>String.replace("(", "") 
          |>String.replace(")", "")
          |>String.replace(~r/[^\w\s\*]/,"")
  end

  def helper_f_AND?(text, keyword) do
      list_without_wc = get_the_words_without_WC(keyword)
      list_with_wc = get_words_with_WC(keyword)
      
      list1 = Enum.map(list_without_wc, fn x -> Regex.match?(~r/\b#{x}\b/iu, text) end)
      is_contains_false = Enum.member?(list1, false)
          
      list2 = Enum.map(list_with_wc, fn x -> text =~ ~r/#{x}/i end)
      case is_contains_false || Enum.member?(list2, false) do
          true -> false
          false -> true
      end
  end

  def helper_f_OR?(text, keyword) do
      list_k = Regex.split(~r{\sOR\s}i, keyword)
      list =  Enum.map(list_k, fn x -> helper_f_AND?(text, x) end) 
      case Enum.member?(list, true) do
          true -> true
          false -> false
      end
  end

  def get_the_words_without_WC(keyword) do
      case has_and?(keyword) do
          true-> _list_without_wc = Enum.reject(Regex.split(~r{\s}, keyword), fn x -> String.match?(x, ~r/\*/i) end)
                 |> Enum.map(fn x -> String.replace(x, ~r/\W/,"")end)
          false -> []
      end
  end

  def get_words_with_WC(keyword) do
      case has_and?(keyword) do
          true-> _list_with_wc = Enum.filter(Regex.split(~r{\s}, keyword), fn x -> has_wildcard?(x) end)
                 |> Enum.map(fn x -> String.replace(x, "*","") end)
          false -> true
      end
  end

  defp match_single_term?(text, keyword) do
      case Regex.match?( ~r/^[[:alpha:]]+$/, keyword) do
          true -> Regex.match?(~r/\b#{keyword}\b/i, text)
          false -> false
      end        
  end

  def has_wildcard?(keyword) do
      Regex.match?(~r/\w\*/i, keyword)
  end

  def has_and?(keyword) do
      Regex.match?(~r/\s/, keyword)
  end

  defp has_or?(keyword) do
      Regex.match?(~r/\sOR\s/i, keyword)
  end
end