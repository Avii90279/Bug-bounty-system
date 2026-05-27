class HintUsage < ApplicationRecord
  belongs_to :user
  belongs_to :hint
  belongs_to :challenge
end
