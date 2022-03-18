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
  
  #It's default function which is called when the text or keyword is an empty string.
  def match?(_text, _keyword), do: "The empty string is not possible to be matched. Please enter some text in it!"

  #Cleans the keyword from all not word characters except whitespaces and wildcards.
  defp clean_kw(keyword) do
      String.replace(keyword, ~r/\sAND\s/," ")
      |>String.replace(~r/[^\w\s\*]/,"")
  end

  #Checks if every single word from the keyword is contained in the text, wchich represents an AND operation.
  defp helper_f_AND?(text, keyword) do
        list_of_words_without_wc = get_words_without_WC(keyword)
        list_of_words_with_wc = get_words_with_WC(keyword)
      
        list1 = Enum.map(list_of_words_without_wc, fn x -> Regex.match?(~r/\b#{x}\b/iu, text) end)
        list2 = Enum.map(list_of_words_with_wc, fn x -> text =~ ~r/#{x}/i end)

        case Enum.member?(list1, false) || Enum.member?(list2, false) do
          true -> false
          false -> true
        end
  end

  #Checks if at least one word from both sides of the OR is contained in the text, wchich represents an OR operation.
  defp helper_f_OR?(text, keyword) do
      list_k = Regex.split(~r{\sOR\s}i, keyword)
      list =  Enum.map(list_k, fn x -> helper_f_AND?(text, x) end) 
      case Enum.member?(list, true) do
        true -> true
        false -> false
      end
  end

  #Gets the words which do not end with a wildcard.
  defp get_words_without_WC(keyword) do
      case has_and?(keyword) do
          true -> _list_of_words_without_wc = Enum.reject(Regex.split(~r{\s}, keyword), fn x -> has_wildcard?(x) end)
          false -> Enum.reject([keyword], fn x -> has_wildcard?(x) end)
      end
  end

  #Gets the words which end with a wildcard.
  defp get_words_with_WC(keyword) do
      case has_and?(keyword) do
          true -> _list_of_words_with_wc = Enum.filter(Regex.split(~r{\s}, keyword), fn x -> has_wildcard?(x) end)
                  |> Enum.map(fn x -> String.replace(x, "*","") end)
          false -> Enum.filter([keyword], fn x -> has_wildcard?(x) end)
                   |> Enum.map(fn x -> String.replace(x, "*","") end)
      end
  end

  #Checks if the keyword is contained in the given text.
  defp match_single_term?(text, keyword) do
      case Regex.match?( ~r/^[[:alpha:]]+$/, keyword) do
          true -> Regex.match?(~r/\b#{keyword}\b/i, text)
          false -> false
      end        
  end

  #Checks if the keyword contains a wildcard.
  defp has_wildcard?(keyword) do
      Regex.match?(~r/\w\*/i, keyword)
  end

  #Checks if the keyword contains whitespace.
  defp has_and?(keyword) do
      Regex.match?(~r/\s/, keyword)
  end

  #Checks if the keyword contains "OR".
  defp has_or?(keyword) do
      Regex.match?(~r/\sOR\s/i, keyword)
  end
  
end