class PagesController < ApplicationController
  # No authorization needed for public pages
  skip_authorization_check

  def home
  end
end
