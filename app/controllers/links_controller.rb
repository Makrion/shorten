class LinksController < ApplicationController
  include LinksParams

  skip_before_action :verify_authenticity_token

  # POST /encode
  # Creates a short link from an original URL
  def encode
    result = UrlShortener.encode(encode_params)

    render json: result, status: :ok
  end

  # POST /decode
  # Retrieves the original URL from a short link
  def decode
    result = UrlShortener.decode(decode_params)

    render json: result, status: :ok
  end
end
