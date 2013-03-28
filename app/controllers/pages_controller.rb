class PagesController < ApplicationController
  def landing
    if signed_in? then redirect_to(search_path) end
  end

  def search
    TwitterClient.send(:connection).headers["Accept-Encoding"] = "" # see: https://github.com/sferik/twitter/issues/370
    @term = params[:term] || 'doma'

    if params[:term] =~ /^user:(.*)/
      @username = $1
    end

    @search_results = cache("twitter_search_results_#{@term}", expires_in: 5.minutes) do
      if @username.present?
        TwitterClient.user_timeline(@username)
      else
        TwitterClient.search(@term, count: 20, result_type: 'recent').results
      end
    end

    if @username.present? && @search_results.any?
      @user = @search_results.first.user
    end
  end
end
