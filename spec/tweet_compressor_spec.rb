require 'spec_helper'

describe TweetCompressor::Tweet do
  let(:filler ) { ?X * 140 }
  let(:space  ) { ' ' }
  let(:string1) { 'Something wicked this way comes.' }
  let(:string2) { 'Fling string while you sing.'     }

  context 'without arguments' do
    describe '#new' do
      it 'initializes cleanly' do
        expect { TweetCompressor::Tweet.new }.to_not raise_error
        expect { TweetCompressor::Tweet.new }.to_not raise_error ArgumentError
      end
    end

    describe '#compressed' do
      it 'returns empty string' do
        subject.compressed.should == ''
      end
    end
  end

  describe '#abbr' do
    it 'abbreviates "JavaScript"' do
      tweet = TweetCompressor::Tweet.new 'JavaScript should be shortened to JS.'
      tweet.send :abbr
      tweet.compressed.should == 'JS should be shortened to JS.'
    end

    it 'abbreviates "string"' do
      tweet = TweetCompressor::Tweet.new(string2)
      tweet.send :abbr
      tweet.compressed.should == 'Fling str while you sing.'
    end

    it 'matches lowercase' do
      tweet = TweetCompressor::Tweet.new 'javascript should be shortened to js.'
      tweet.send :abbr 
      tweet.compressed.should == 'JS should be shortened to js.'
    end

    it 'matches uppercase' do
      tweet = TweetCompressor::Tweet.new 'JAVASCRIPT SHOULD BE SHORTENED TO JS.'
      tweet.send :abbr 
      tweet.compressed.should == 'JS SHOULD BE SHORTENED TO JS.'
    end

    it 'skips hash tags' do
      text  = '#string #JavaScript #string'
      tweet = TweetCompressor::Tweet.new text
      tweet.send :abbr 
      tweet.compressed.should == text
    end

    it 'abbreviates numbers' do
      text = 'one two three fifteen twenty'
      tweet = TweetCompressor::Tweet.new text
      tweet.send :abbr 
      tweet.compressed.should == '1 2 3 15 20'
    end
  end

  describe '#apostrophes' do
    it 'removes apostrophes from contractions' do
      tweet = TweetCompressor::Tweet.new %q{It's not; I won't, you can't. So don't.}
      tweet.send :apostrophes
      tweet.compressed.should == %q{It's not; I wont, you cant. So dont.}
    end
  end

  describe '#char_count' do
    it 'reports an accurate string length' do
      tweet = TweetCompressor::Tweet.new string1
      tweet.send(:char_count).should == string1.length
    end

    it 'pretends URLs are exactly 20 chars' do
      url  = 'http://www.example.com/1234567890' # 33 chars
      text = "abc #{url} def"                    # 41 chars (8 + url)
      tweet = TweetCompressor::Tweet.new text
      tweet.instance_variable_set :@urls, Array(url)
      tweet.send(:char_count).should == 28
    end

    # Short URLs still take up 20 characters on Twitter.
    it 'handles short urls < 20 chars' do
      url  = 'http://123'         # 10 chars
      text = "abc #{url} def"     # 18 chars
      tweet = TweetCompressor::Tweet.new text
      tweet.instance_variable_set :@urls, [url]
      tweet.send(:char_count).should == 28
    end
  end

  describe '#compress' do
    it "skips strings less than #{TweetCompressor::Tweet::MAX_LENGTH} chars" do
      tweet = TweetCompressor::Tweet.new string1
      tweet.compress
      tweet.compressed.should == string1
    end

    it "compresses strings above #{TweetCompressor::Tweet::MAX_LENGTH} chars" do
      text  = "%s %s %s" % [string1, string2, filler.downcase]
      tweet = TweetCompressor::Tweet.new text
      tweet.compress
      tweet.compressed.should == 'Smthng wckd ths way cms. Flng str whl you sng. x'
    end

    it 'stores a compressed copy of the tweet' do
      tweet = TweetCompressor::Tweet.new(string1 + filler.downcase)
      tweet.compress
      tweet.compressed.should_not == tweet.original
      tweet.original.length.should be > tweet.compressed.length
      tweet.compressed.length.should == 25
    end
  end

  describe '#compression_level' do
    before do
      @tweet = TweetCompressor::Tweet.new string2 + filler.downcase
      @tweet.compress
    end

    it 'returns a Float' do
      @tweet.compression_level.should be_a Float
    end

    it 'calculates correctly' do
      @tweet.compression_level.should == 86.9
    end
  end

  describe '#contractions' do
    it 'contracts words' do
      text  = %q{It is; it is not. I will; I will not. I would not.}
      tweet = TweetCompressor::Tweet.new text
      tweet.send :contractions
      tweet.compressed.should == %q{It's; it's not. I'll; I'll not. I'd not.}
    end

    it 'preserves case of initial letter' do
      text = %q{It does not. Is not. Does not. Do not. You must not.}
      tweet = TweetCompressor::Tweet.new text
      tweet.send :contractions
      tweet.compressed.should ==
        %q{It doesn't. Isn't. Doesn't. Don't. You musn't.}
    end
  end

  describe '#dedupe_consonants' do
    let(:consonants) { 'LLC BBC CCID' }

    it 'ignores uppercase consonants' do
      tweet = TweetCompressor::Tweet.new consonants
      tweet.send :dedupe_consonants 
      tweet.compressed.should == tweet.original
    end

    it 'leaves one consonant' do
      tweet = TweetCompressor::Tweet.new consonants.downcase
      tweet.send :dedupe_consonants 
      tweet.compressed.should == 'lc bc cid'
    end
  end

  describe '#dedupe_punct' do
    let(:punctuation) { '!!! ... ,,, ?! .!' }
    let(:exceptions ) { 'Foo! Bar...baz. Quux?!' }

    it 'singularizes punctuation' do
      tweet = TweetCompressor::Tweet.new punctuation
      tweet.send :dedupe_punct 
      tweet.compressed.should == '! ... , ?! .!'
    end

    it 'makes exceptions for dashes and ellipses' do
      tweet = TweetCompressor::Tweet.new exceptions
      tweet.send :dedupe_punct 
      tweet.compressed.should == exceptions
    end

  end

  describe '#ing' do
    it 'shortens sleeping' do
      TweetCompressor::Tweet.new('sleeping').send(:ing).should == 'sleepg'
    end

    it 'ignores #sleeping' do
      TweetCompressor::Tweet.new('#sleeping').send(:ing).should == '#sleeping'
    end

    it 'ignored excepted words' do
      TweetCompressor::Tweet.new('fling').send(:ing).should == 'fling'
    end
  end

  describe '#remove_vowels' do
    it 'ignores starting vowels' do
      TweetCompressor::Tweet.new('aboard').send(:remove_vowels).should == 'abrd'
    end

    it 'removes internal vowels' do
      TweetCompressor::Tweet.new('boardwalk').
        send(:remove_vowels).should == 'brdwlk'
    end
  end

  describe '#sentences' do
    it 'removes space between sentences' do
      text = '1 2 3. 4 5 6, 7 8 9! 0'
      tweet = TweetCompressor::Tweet.new text
      tweet.send :sentences
      tweet.compressed.should == '1 2 3.4 5 6,7 8 9!0'
    end
  end

  describe '#texting' do
    it 'expresses equality' do
      input  = 'foo is a bar. bar is an afoo. baz is the quux'
      output = 'foo = bar. bar = afoo. baz = quux'
      tweet = TweetCompressor::Tweet.new input
      tweet.send :texting
      tweet.compressed.should == output
    end

    it 'uses "re" sensibly' do
      text = '1 about 2. 3 related to 4'  
      tweet = TweetCompressor::Tweet.new text
      tweet.send :texting
      tweet.compressed.should == '1 re 2. 3 re 4'
    end

    it 'strips colons from retweets' do
      text = 'Foo bar. RT @_baz_quux_: More fubar.'
      tweet = TweetCompressor::Tweet.new text
      tweet.send :texting
      tweet.compressed.should == 'Foo bar. RT @_baz_quux_ More fubar.'
    end
  end

  describe '#url_preserve' do
    let(:url1) { 'http://123' }
    let(:url2) { 'http://456' }
    let(:text) { "abc #{url1} def #{url2}" }

    it 'inserts placeholders in tweet' do
      tweet = TweetCompressor::Tweet.new text
      tweet.send :url_preserve
      tweet.compressed.should ==
        "abc #{Compress::URL_HOLDER} def #{Compress::URL_HOLDER}"
    end

    it 'stores the URLs' do
      tweet = TweetCompressor::Tweet.new text
      tweet.send :url_preserve
      tweet.urls.should == [url1, url2]
    end
  end

  describe '#url_restore' do
    let(:url1) { 'http://123' }
    let(:url2) { 'http://456' }
    let(:text) { "abc #{Compress::URL_HOLDER} def #{Compress::URL_HOLDER}" }

    it 'restores URLs to tweet' do
      tweet = TweetCompressor::Tweet.new text
      tweet.instance_variable_set :@urls, [url1, url2]
      tweet.send :url_restore
      tweet.compressed.should == "abc #{url1} def #{url2}"
    end
  end
end
