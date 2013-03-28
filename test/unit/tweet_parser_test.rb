gem 'parslet'
require File.expand_path('../../fast_test_helper', __FILE__)
require File.expand_path('../../../lib/tweet_parser.rb', __FILE__)

describe TweetParser do
  it 'parses @' do
    assert_equal '<a href="/search?term=user:quinnshanahan">@quinnshanahan</a> hello', TweetParser.parse('@quinnshanahan hello')
  end

  it 'parses #' do
    assert_equal '<a href="/search?term=%23rails">#rails</a> test', TweetParser.parse('#rails test')
  end

  it 'parses links' do
    assert_equal 'link to <a href="http://google.com/">http://google.com/</a>', TweetParser.parse('link to http://google.com/')
  end

  it 'does nothing on regular text' do
    assert_equal 'regular text', TweetParser.parse('regular text')
  end

  it 'can be combined' do
    assert_equal 'hello <a href="/search?term=user:quinnshanahan">@quinnshanahan</a> <a href="/search?term=%23rails">#rails</a> <a href="http://google.com/">http://google.com/</a>', TweetParser.parse('hello @quinnshanahan #rails http://google.com/')
  end

  it 'can parse' do
    TweetParser.parse("RT @splcenter: #SCOTUS: House Judiciary Committee Report hard to ignore - shows #DOMA based on 'Moral Disapproval of Homosexuality' http")
  end
end
