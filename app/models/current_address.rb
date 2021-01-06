class CurrentAddress < ApplicationRecord

  has_one :patient

  def neighborhood_name
    self.neighborhood.present? ? self.neighborhood.humanize : ""
  end

  def street_name
    self.street.present? ? self.street.humanize : ""
  end

  def street_number_name
    self.street_number.present? ? self.street_number.humanize : ""
  end  

  def get_full_address_name
    self.neighborhood_name + " " + self.street_name + " " + self.street_number_name
  end

end
