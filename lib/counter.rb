module Counter
  class << self
    def generate_number(name, size = 7)
      zero = Base62.decimal_to_base62(0)
      number = Base62.decimal_to_base62(SafeCounter.get_and_increment(name))
      # Pad with leading zeros to ensure exact decimal_count characters
      # and get first size characters only
      number.rjust(size, zero).first(size)
    end
  end
end
