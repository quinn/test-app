module Oauthable
  extend ActiveSupport::Concern

  def oauth_connected? type
    send(:"#{type}_oauth_token").present?
  end

  def disconnect_oauth type
    send :"#{type}_oauth_token=", nil
    send :"#{type}_oauth_secret=", nil
    send :"#{type}_oauth_id=", nil
  end

  def disconnect_oauth! type
    disconnect_oauth(type)
    save
  end

  def fill_in_fields_from_oauth type, access_token
    if type == :twitter
      self.name = access_token.info.name
    end
  end

  module ClassMethods
    def init_for_oauth type, access_token, current_user=nil
      user = if current_user.present?
        current_user
      else
        find_or_init_in_database_for_oauth(type, access_token.uid)
      end

      if user.present?
        user.send :"#{type}_oauth_token=", access_token.credentials.token
        user.send :"#{type}_oauth_secret=", access_token.credentials.secret
        user.send :"#{type}_oauth_id=", access_token.uid
        user.fill_in_fields_from_oauth type, access_token
        user
      end
    end

    def find_or_init_in_database_for_oauth type, uid
      attribute = :"#{type}_oauth_id"
      user = where(attribute => uid.to_s).first || new
      user[attribute] = uid.to_s
      user
    end

    def oauth_types *types
      validates_uniqueness_of types.map{|type| :"#{type}_oauth_id" }, allow_blank: true
      attr_accessible *types.inject([]){|arr, type| arr += [:"#{type}_oauth_token", :"#{type}_oauth_secret", :"#{type}_oauth_id"] }
    end
  end
end
