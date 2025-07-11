class Link < ApplicationRecord
  validates :original_link, presence: true, length: { maximum: 80000 }, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }
  validates :short_link, presence: true, length: { is: 9 }

  def expired?
    expiry_date.present? && expiry_date < Time.current
  end
end
