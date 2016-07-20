class Movie < ApplicationRecord
  searchkick
  belongs_to :user
  has_many :reviews


  validates :title, uniqueness: true
end
