class CovidProfileMovement < ApplicationRecord
  belongs_to :covid_profile
  belongs_to :user
  belongs_to :sector
end
