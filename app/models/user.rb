class User < ActiveRecord::Base
  include Oauthable
  attr_accessible :name
  oauth_types :twitter
end
