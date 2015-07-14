class Student < ActiveRecord::Base
  acts_as_copy_target

  has_one :user

  has_and_belongs_to_many :users

  has_many :***REMOVED***, dependent: :restrict_with_error

  validates :name, presence: true
  validates :api_code, presence: true, if: :api?

  scope :api, -> { where(arel_table[:api].eq(true)) }

  def self.search(value)
    relation = all

    if value.present?
      relation = relation.where(%Q(
        name ILIKE :text OR api_code = :code
      ), text: "%#{value}%", code: value)
    end

    relation
  end

  def to_s
    name
  end
end
