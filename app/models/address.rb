class Address < ApplicationRecord
  belongs_to :country, optional: true
  belongs_to :state, optional: true
  belongs_to :city, optional: true
  has_one :patient

  def country_name
    self.country.present? ? self.country.name.humanize : ""
  end

  def state_name
    self.state.present? ? self.state.name.humanize : ""
  end

  def city_name
    self.city.present? ? self.city.name.humanize : ""
  end

  def self.update_or_create_address(params, patient)
    # Debemos mapear los valores "string" que vienen de andes
    @country = Country.where(name: params[:address_attributes][:country]).first_or_create(name: params[:address_attributes][:country])
    @state = State.where(name: params[:address_attributes][:state]).first_or_create(name: params[:address_attributes][:state], country_id: @country.id)
    @city = City.where(name: params[:address_attributes][:city]).first_or_create(name: params[:address_attributes][:city], state_id: @state.id )

    # Debemos actualizar o crear una nueva direccion
    @address = Address.where(id: patient.address_id).first

    if @address.present?
      @address.country = @country
      @address.state = @state
      @address.city = @city
      @address.line = params[:address_attributes][:line]
      @address.latitude = params[:address_attributes][:latitude]
      @address.longitude = params[:address_attributes][:longitude]
      @address.postal_code = params[:address_attributes][:postal_code]
      @address.save!
    else
      @address = Address.create(
        country: @country,
        state: @state,
        city: @city,
        line: params[:address_attributes][:line],
        latitude: params[:address_attributes][:latitude],
        longitude: params[:address_attributes][:longitude],
        postal_code: params[:address_attributes][:postal_code]
      )
    end
    return @address
  end

  def string
    self.line+" "+self.city_name+" "+self.state_name+" "+self.country_name
  end
end
