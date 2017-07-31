class Bootcamp::Module < ApplicationRecord
  validates :title, uniqueness: true, presence: true
  validates :repo,  uniqueness: true, presence: true
  has_many :exercises
end
