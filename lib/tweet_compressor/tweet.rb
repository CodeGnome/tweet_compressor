module TweetCompressor
  class Tweet
    MAX_LENGTH = 140
    attr_reader :compressed, :original, :urls

    def initialize tweet=''
      @original, @compressed = tweet, tweet
      @urls = []
    end

    # The workhorse method that calls each compression stage in turn as long as
    # the tweet text remains larger than 140 characters.
    def compress
      # Always perform, in order to track URL shortening.
      url_preserve

      stages = %i[url_preserve whitespace correct_grammar contractions
                  dedupe_punct abbr remove_vowels dedupe_consonants apostrophes
                  sentences]
      stages.each do |stage|
        break if char_count <= MAX_LENGTH
        self.send stage
      end

      # Must not be a stage, which may be bypassed.
      url_restore

      @compressed
    end

    def compression_level
      (100 - ((char_count / @original.size.to_f) * 100)).round 2
    end

    private
    include Compress
  end
end
