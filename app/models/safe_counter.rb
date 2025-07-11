class SafeCounter < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def self.get_and_increment(name)
    counter = SafeCounter.find_or_create_by(name: name)
    counter.count = 0 if counter.count.nil?
    counter.count += 1
    counter.save!
    (counter.count - 1)
  end
end
