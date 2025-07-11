module UrlShortener
  COUNTER_NAME = "URL SHORTENER"
  SHORTEN_URL_SIZE = (ENV["SHORTEN_URL_SIZE"] || 9).to_i
  SECURITY_SALT_SIZE = (ENV["SECURITY_SALT_SIZE"] || 2).to_i
  SHORT_LINK_EXPIRY_MINUTES = 60*24*365

  class << self
    def encode(original_link, expiry_date = SHORT_LINK_EXPIRY_MINUTES.minutes.from_now)
      # Generate unique short link
      number_size = SHORTEN_URL_SIZE - SECURITY_SALT_SIZE
      number = Counter.generate_number(COUNTER_NAME, number_size)
      salt = generate_salt(SECURITY_SALT_SIZE)
      # Create new link
      link = Link.create(
        original_link: original_link,
        short_link: (number+salt),
        expiry_date: expiry_date
      )

      if link.persisted?
        {
          short_link:  Shorten::Application::BASE_URL + link.short_link,
          expiry_date: link.expiry_date
        }
      else
        raise CustomExceptions::DatabaseException, "Failed to create short link"
      end
    end

    def decode(short_link)
      link = Link.find_by!(short_link: short_link)

      # Check if link has expired
      if link.expired?
        raise CustomExceptions::LinkExpired, "Short link has expired"
      end

      {
        original_link: link.original_link,
        expiry_date: link.expiry_date
      }
    end

    private

    def generate_salt(size)
      Base62.random(size)
    end
  end
end
