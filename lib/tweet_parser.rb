require 'parslet'

class Parslet::Atoms::URI < Parslet::Atoms::Base
  def initialize
    super()

    @error_msgs = {
      :premature  => "Premature end of input",
      :failed     => "Expected URI"
    }
  end

  def try(source, context, consume_all)
    re = URI.regexp
    str = source.instance_variable_get(:@str)
    pos = source.instance_variable_get(:@pos)

    if (res = str[pos..-1].match(re)) && (url = res[0]) =~ /https?:\/\//
      return succ(source.consume(url.length))
    end
  end

  def to_s_inner(prec)
    "'#{str}'"
  end
end

class TweetParser < Parslet::Parser
  rule(:user_d) { str('@') }
  rule(:tag_d)  { str('#') }
  rule(:link_d) { match('https?://') }

  rule(:words) {
    (
      (
        match(/\W/)
      ).absent? >> any
    ).repeat
  }

  def uri
    Parslet::Atoms::URI.new
  end

  rule(:user) { user_d  >> words.as(:user) }
  rule(:tag)  { tag_d   >> words.as(:tag)  }
  rule(:link) { uri.as(:link) }
  rule(:text) { ((user_d | tag_d | link_d).absent? >> any).repeat }

  rule(:exp) {
    (
      text.maybe.as(:before)   >>
      (user | tag | link).as(:link) >>
      text.maybe.as(:after)
    ).repeat(1).as(:links) | text
  }

  root :exp

  def self.parse *args
    result = new.parse(*args)
    return result.to_s unless result.respond_to? :[]

    result[:links].inject('') do |parsed, chunk|
      if chunk[:before].present?
        parsed << chunk[:before]
      end

      type, value = chunk[:link].to_a[0]

      link = case type
      when :user
        %Q(<a href="/search?term=user:#{value}">@#{value}</a>)
      when :tag
        escaped_hash = URI.escape("##{value}")
        %Q(<a href="/search?term=#{escaped_hash}">##{value}</a>)
      when :link
        %Q(<a href="#{value}">#{value}</a>) # no target=blank because Jakob Nielsen says so
      end

      parsed << link

      if chunk[:after].present?
        parsed << chunk[:after]
      end

      parsed
    end

  rescue Parslet::ParseFailed
    raise Parslet::ParseFailed, "failed to parse #{args.first.inspect}"
  end
end
