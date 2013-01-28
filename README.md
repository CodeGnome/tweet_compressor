# tweet\_compressor

## Copyright and Licensing

### Copyright Notice

The copyright for the software, documentation, and associated files are
held by the author.

    Copyright 2013 Todd A. Jacobs
    All rights reserved.

The AUTHORS file is also included in the source tree.

### Software License

![GPLv3 Logo](http://www.gnu.org/graphics/gplv3-88x31.png)

The software is licensed under the
[GPLv3](http://www.gnu.org/copyleft/gpl.html). The LICENSE file is also
included in the source tree.

### README License

![Creative Commons BY-NC-SA
Logo](http://i.creativecommons.org/l/by-nc-sa/3.0/us/88x31.png)

This README is licensed under the [Creative Commons
Attribution-NonCommercial-ShareAlike 3.0 United States
License](http://creativecommons.org/licenses/by-nc-sa/3.0/us/).

## Purpose

tweet\_compressor is Ruby gem that performs successive text
transformations in order to shrink input text below Twitter's
140-character limit while preserving the integrity of hashtags and
links.

## Features

- Treats hashtags as sacrosanct.
- Relies on Twitter to shorten URLs for you, counting URLs as 20
  characters.
- Skips shortening stages whenever the character length drops below 140.
- Remains vaguely intelligible even under heavy compression.

## Caveats and Limitations

1. The gem performs text transformations; it's not a full parser.
2. Some of the transformations may be naive or rely on brute force to
   get the job done. YMMV.
3. No sanity checking is performed on the semantics of the output text.
   It Works for Me&trade;, but it's not a substitute for applying common
   sense and a keen eye to your tweets before posting on Twitter.
4. Works best when you only need to trim a handful of characters. If
   you're vastly over the limit, readability suffers as compression gets
   tighter.

## Supported Software Versions

This software is tested against the current Ruby 2.x series. It is
unlikely to work without minor editing on 1.9.3, and you're on your own
for anything earlier than 1.9.1.

- See [.ruby-version][20] for the currently-supported Ruby versions.
- See [Gemfile.lock][30] for a complete list of gems, including supported
  versions, needed to build or run this project.

## Installation and Setup

Installing tweet\_compressor couldn't be easier. Just follow these two
simple steps:

1. `gem install tweet_compressor`
2. There is no step two.

## Usage

    tweet_compressor <tweet>

## Examples

No screenshots here, just samples of what you can expect to see on
standard output when you run the program.


- Example of text that requires no compression.

        $ tweet_compressor foo
        Chars: 3, Compression: 0.0%

        foo

- Example of extremely heavy compression. Trims 196 characters about the
  Gettysburg Address down to 137.

        $ tweet_compressor 'Four score and seven years ago our fathers
        brought forth on this continent a new nation, conceived in liberty,
        and dedicated to the proposition that all men are created equal.
        #speech #Lincoln'                                                            
        Chars: 137, Compression: 28.65%

        4 scr &7 yrs ago our fthrs brght frth on ths cntnt a new ntn,cncvd
        in lbrty,& dctd to the prpstn tht al men are crtd eql.#speech
        #Lincoln

- Example of assumed compression from [Twitter's built-in URL
  shortener.][10]

        $ tweet_compressor 'http://tweet_compressor/knows/twitter/shortens/urls/to/20/characters'
        Chars: 20, Compression: 70.59%

        http://tweet_compressor/knows/twitter/shortens/urls/to/20/characters

## Contributions Welcome

This is an open-source project. Contributors are highly encouraged to
open pull-requests on GitHub.

----
[Project Home Page](https://github.com/CodeGnome/tweet_compressor)

[10]: https://support.twitter.com/entries/109623
[20]: https://raw.github.com/CodeGnome/tweet_compressor/master/.ruby-version
[30]: https://raw.github.com/CodeGnome/tweet_compressor/master/Gemfile.lock
