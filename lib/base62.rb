module Base62
  class << self
    Base64_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

    # Convert a number to base62 representation
    def decimal_to_base62(number)
      return Base64_CHARS[0]  if number == 0

      result = ""
      while number > 0
        result = Base64_CHARS[number % 62] + result
        number /= 62
      end

      result
    end

    def random(size)
      return Base64_CHARS[0]  if size <= 0

      random_number = ""
      size.times do
        random_number += Base64_CHARS[rand(62)]
      end
      random_number
    end
  end
end
