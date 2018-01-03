class MedicationsController < ApplicationController
  before_action :set_medication, only: [:show, :edit, :update, :destroy]

  # GET /medications
  # GET /medications.json
  def index
    @filterrific = initialize_filterrific(
      Medication,
      params[:filterrific],
      select_options: {
        sorted_by: Medication.options_for_sorted_by
      },
      persistence_id: false,
      default_filter_params: {sorted_by: 'created_at_desc'},
      available_filters: [
        :sorted_by,
        :search_query,
        :date_received_at,
      ],
    ) or return
    @medications = @filterrific.find.page(params[:page]).per_page(8)


    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /medications/1
  # GET /medications/1.json
  def show
    respond_to do |format|
      format.js
    end
  end

  # GET /medications/new
  def new
    @medication = Medication.new
    @medication.build_medication_brand
    @medication.medication_brand.build_laboratory
    @vademecums = Vademecum.all
    @medication_brands = MedicationBrand.all
    @laboratories = Laboratory.all
  end

  # GET /medications/1/edit
  def edit
    @vademecums = Vademecum.all
    @medication_brands = MedicationBrand.all
    @laboratories = Laboratory.all
  end

  # POST /medications
  # POST /medications.json
  def create
    @medication = Medication.new(medication_params)
    if medication_params[:medication_brand_id].present?
      @medication.update_attribute(:medication_brand_id, medication_params[:medication_brand_id])
    end
    date_r = medication_params[:date_received]
    date_e = medication_params[:expiry_date]
    @medication.date_received = DateTime.strptime(date_r, '%d/%M/%Y %H:%M %p')
    @medication.expiry_date = DateTime.strptime(date_e, '%d/%M/%Y %H:%M %p')

    respond_to do |format|
      if @medication.save
        flash.now[:success] = "El lote de "+@medication.full_info+" se ha cargado correctamente."
        format.js
      else
        flash.now[:error] = "El lote de medicamentos no se ha podido cargar."
        format.js
      end
    end
  end

  # PATCH/PUT /medications/1
  # PATCH/PUT /medications/1.json
  def update
    new_date_received = DateTime.strptime(medication_params[:date_received], '%d/%M/%Y %H:%M %p')
    new_expiry_date = DateTime.strptime(medication_params[:expiry_date], '%d/%M/%Y %H:%M %p')

    respond_to do |format|
      if @medication.update(medication_params)
        @medication.update_attribute(:date_received, new_date_received)
        @medication.update_attribute(:expiry_date, new_expiry_date)
        flash.now[:success] = "El lote de "+@medication.full_info+" se ha modificado correctamente."
        format.js
      else
        flash.now[:error] = "El lote de "+@medication.full_info+" no se ha podido modificar."
        format.js
      end
    end
  end

  # DELETE /medications/1
  # DELETE /medications/1.json
  def destroy
    @medication_info = @medication.full_info
    @medication.destroy
    respond_to do |format|
      flash.now[:success] = "El lote de "+@medication_info+" se ha eliminado correctamente."
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_medication
      @medication = Medication.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def medication_params
      params.require(:medication).permit(:vademecum_id, :quantity, :date_received,
                                         :expiry_date, :medication_brand_id,
                                         medication_brand_attributes: [:id, :name, :description, :laboratory_id,
                                         laboratory_attributes: [:id, :name, :address]])
    end
end
