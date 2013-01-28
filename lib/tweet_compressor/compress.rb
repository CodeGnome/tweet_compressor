# This module is a mixin for classes that want to use a very basic alphabetic
# shorthand to reduce text size. The module performs in-place operations, and
# expects to find a @compressed instance variable to work from.
#
# Example:
# 
#   include Compress
#   @original = 'JavaScript'
#   @compressed = @original.dup
#   abbr
#   # => "JS"
#
#
module Compress
  URL_HOLDER = '__PLACEHOLDER4URLS__'
  URL_LENGTH = 20
  URL_PATTERN  = %r{
                     \b
                     (
                       (?: [a-z][\w-]+:
                        (?: /{1,3} | [a-z0-9%] ) |
                         www\d{0,3}[.] |
                         [a-z0-9.\-]+[.][a-z]{2,4}/
                       )
                       (?:
                        [^\s()<>]+ | \(([^\s()<>]+|(\([^\s()<>]+\)))*\)
                       )+
                       (?:
                         \(([^\s()<>]+|(\([^\s()<>]+\)))*\) |
                         [^\s`!()\[\]{};:'".,<>?«»“”‘’]
                       )
                     )
                 }ix

  # Calculate the current character count, taking the "virtual size" of
  # Twitter-shortened URLs into account.
  def char_count
    real_url_chars = @urls.join.size
    virt_url_chars = @urls.count * URL_LENGTH
    @compressed.size - real_url_chars + virt_url_chars
  end

  private

  # Special abbreviations to increase clarity.
  #
  # TODO: A YAML dictionary would be preferrable to case statements if the list
  # grows to any significant length.
  def abbr
    @compressed = @compressed.split.map do |word|
      case word.downcase
      when 'and'        then '&'
      when 'javascript' then 'JS'
      when 'string'     then 'str'
      when 'one'        then '1'
      when 'two'        then '2'
      when 'three'      then '3'
      when 'four'       then '4'
      when 'five'       then '5'
      when 'six'        then '6'
      when 'seven'      then '7'
      when 'eight'      then '8'
      when 'nine'       then '9'
      when 'ten'        then '10'
      when 'eleven'     then '11'
      when 'twelve'     then '12'
      when 'thirteen'   then '13'
      when 'fourteen'   then '14'
      when 'fifteen'    then '15'
      when 'sixteen'    then '15'
      when 'seventeen'  then '17'
      when 'eighteen'   then '18'
      when 'nineteen'   then '19'
      when 'twenty'     then '20'
      else word
      end
    end.join ' '
    @compressed.gsub! /is (?:an?|the)/, '='
    @compressed.gsub! /(in|with)? regards? (to)?/i, 're'
    @compressed.gsub! /about|regarding|related( to)?|(in response to)/, 're'
  end

  # Remove apostrophes from contractions to save more space.
  def apostrophes
    @compressed.gsub! /n't/i, 'nt'
  end

  # Identify common contractions, taking a few pains to preserve capitalization
  # of the initial letter.
  def contractions
    @compressed.gsub! /I would/i, %q{I'd}
    @compressed.gsub! /i will(?!= ?not)/i, %q{I'll}
    @compressed.gsub! /(i)t is/i, %q{\1t's}
    @compressed.gsub! /(i)s not/i, %q{\1sn't}
    @compressed.gsub! /(w)ill not/i, %q{\1on't}
    @compressed.gsub! /(c)an ?not/i, %q{\1an't}
    @compressed.gsub! /(d)o(es)? not/i, %q{\1o\2n't}
    @compressed.gsub! /(s)hould not/i, %q{\1houldn't}
    @compressed.gsub! /(m)ust not/i, %q{\1usn't}
  end

  # Fix common grammar mistakes that also save space.
  def correct_grammar
    @compressed.gsub! /s's/i, ?'
  end

  # Remove duplicate lowercase consonants. Assume duplicate capital letters
  # like 'LLC' are intentional.
  def dedupe_consonants
    consonants = [*'a'..'z'].flatten.reject { |c| c =~ /[aeiou]/ }
    regex = /(#{consonants})\1+/
    @compressed = @compressed.split.map do |word|
      next word unless word =~ regex
      word.gsub! regex, $1.to_s
    end.join ' '
  end

  # Remove duplicate punctuation characters. Make an exception for ellipses
  # and dashes.
  def dedupe_punct
    regex = /([[:punct:]])\1+/
    @compressed = @compressed.split.map do |word|
      word.gsub! /\.{4,}/, '...'
      word.gsub! /-{3,}/, '--'
      next word if word.include? '...' or word.match /-{2,3}/
      next word unless word =~ regex
      word.gsub! regex, '\1'
    end.join ' '
  end

  # Replace 'ing' with 'g'. Excludes short words like "ring" and "sing," and
  # checks an exception list for special cases.
  def ing
    exceptions = %w[fling]
    @compressed = @compressed.split.map do |word|
      next word unless word.end_with? 'ing'
      next word if word.start_with? '#'
      next word if word.size <= 4
      next word if exceptions.include? word
      word.sub(/ing$/, 'g')
    end.join ' '
  end

  # Remove lowercase vowels in longer words, unless it is the starting letter.
  def remove_vowels
    @compressed = @compressed.split.map do |word|
      next word if word.start_with? '#'
      word.size >= 4 ? word.gsub(/(?<!\A)[aeiou]/, '') : word
    end.join ' '
  end

  # Remove spaces between punctuation marks and the following words.
  def sentences
    @compressed.gsub! /([[:punct:]])\s*(\S)/, '\1\2'
  end

  # Abbreviations common in texting, but with a higher cognitive load.
  def texting
    @compressed.gsub! /is (?:an?|the)/, '='
    @compressed.gsub! /:.\)|\(.:/, ':)'
    @compressed.gsub! /(in|with)? regards? (to)?/i, 're'
    @compressed.gsub! /about|regarding|related( to)?|(in response to)/i, 're'
    @compressed.gsub! /(RT @[^:\b]+):?/, '\1'
    @compressed.gsub! /\bare\b/, 'r'
    @compressed.gsub! /\bfor\b/, '4'
    @compressed.gsub! /\bto/, '2'
    @compressed.gsub! /why/, 'y'
    @compressed.gsub! /you/, 'u'
  end

  # Regularize whitespace.
  def whitespace
    @compressed = @compressed.split.join ' '
  end

  # Temporarily remove URLs from the pattern space so that they don't get horked
  # during other text transormations.
  def url_preserve
    @urls = @compressed.scan(/#{URL_PATTERN}/).flatten.compact
    @urls.each { |url| @compressed.gsub! /#{url}/, URL_HOLDER }
  end

  # Return stored URLs to the pattern space.
  def url_restore
    @urls.each { |url| @compressed.sub! URL_HOLDER, url }
  end
end
