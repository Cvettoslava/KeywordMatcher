defmodule KeywordMatcher do
  @moduledoc """
  Documentation for `KeywordMatcher`.
  """

  @doc """
  ## Examples
  """

  def match?(text, keyword) when keyword != "" and text != "" do
    keyword = clean_kw(keyword)

    list_of_results = List.insert_at([], 0, has_or?(keyword))
    |> List.insert_at(1, has_and?(keyword))
    |> List.insert_at(2, has_wildcard?(keyword))

    case list_of_results do
        [false, true, _] -> operation_AND?(text, keyword)
        [true, _, _]-> operation_OR?(text, keyword)
        [false, false, false] -> match_single_term?(text, keyword)
        [false, false, true] -> Regex.match?(~r/#{keyword}/i, text)
    end
  end
  
  #It's default function which is called when the text or keyword is an empty string.
  def match?(_text, _keyword), do: "The empty string is not possible to be matched. Please enter some text in it!"

  #Cleans the keyword from all not word characters except whitespaces and wildcards.
  def clean_kw(keyword) do
        String.replace(keyword,~r/\sAND\s/," ")
        |>String.replace(~r/[^\w\s\*]/,"")
  end

  #Checks if every single word from the keyword is contained in the text, wchich represents an AND operation.
  defp operation_AND?(text, keyword) when keyword != "" and keyword != "\s" do
        list_of_words_without_wc = get_words_without_WC(keyword)
        list_of_words_with_wc = get_words_with_WC(keyword)
        
        list1 = Enum.reject(list_of_words_without_wc, fn x -> x == "" end)
        |> Enum.map(fn x -> Regex.match?(~r/\b#{x}\b/i, text) end)
        list2 = Enum.reject(list_of_words_with_wc, fn x -> x == "" end)
        |>Enum.map(fn x -> text =~ ~r/#{x}/i end)

        case Enum.member?(list1, false) || Enum.member?(list2, false) do
         true -> false
         false -> true
        end
  end

  defp operation_AND?(_text, _keyword), do: false

  #Checks if the words on at least one side of the OR is contained in the text, wchich represents an OR operation.
  def operation_OR?(text, keyword) do
        split_list = Regex.split(~r{OR}i, keyword)
        list = Enum.map(split_list, fn x -> String.replace(x,"\s\s","")end)
        |> Enum.reject(fn x -> x == " " end)
        |> Enum.map(fn x -> operation_AND?(text, x) end) 

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
      case Regex.match?( ~r/^[[:alpha:]]+$/iu, keyword) do
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