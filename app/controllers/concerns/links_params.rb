module LinksParams
  extend ActiveSupport::Concern

  private

  def encode_params
    original_link = params[:original_link]
    raise ActionController::ParameterMissing, "original_link" if \
      original_link.blank?

    validate_url_format(original_link)
    validate_original_link(original_link)
    original_link
  end

  def decode_params
    short_link = params[:short_link]
    raise ActionController::ParameterMissing, "short_link" if \
      short_link.blank?

    validate_url_format(short_link)
    validate_short_link(short_link)
    short_link.last(UrlShortener::SHORTEN_URL_SIZE)
  end

  def validate_url_format(url)
    url_regex = URI::DEFAULT_PARSER.make_regexp(%w[http https])
    valid = url =~ url_regex
    raise CustomExceptions::InvalidUrl, "this is not a valid url format" unless \
      valid
  end


  def validate_original_link(original_link)
    raise CustomExceptions::InvalidUrl, "we only process urls up to 80k chars" if \
      original_link.size > 80000
  end

  def validate_short_link(short_link)
    raise CustomExceptions::InvalidUrl, "invalid shortlink" if \
      short_link.first(Shorten::Application::BASE_URL.size).downcase != Shorten::Application::BASE_URL

    correct_size = Shorten::Application::BASE_URL.size + UrlShortener::SHORTEN_URL_SIZE
    raise CustomExceptions::InvalidUrl, "invalid shortlink size" if \
      short_link.size != correct_size
  end
end
