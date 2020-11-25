class CovidProfilesController < ApplicationController
  before_action :set_covid_profile, only: [:show, :edit, :update, :destroy, :delete]
  require 'json'
  require 'rest-client'
  # GET /covid_profiles
  # GET /covid_profiles.json
  def dashboard
    @covid_profiles = CovidProfile.all
    @last_covid_profiles = @covid_profiles.limit(5)
  end

  def index
    @filterrific = initialize_filterrific(
      CovidProfile,
      params[:filterrific],
      select_options: {
      },
      persistence_id: false,
      default_filter_params: {sorted_by: 'created_at_desc'},
      available_filters: [
      ],
    ) or return
    @covid_profiles = @filterrific.find.page(params[:page]).per_page(15)
  end

  # GET /covid_profiles/1
  # GET /covid_profiles/1.json
  def show
    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /covid_profiles/new
  def new
    @covid_profile = CovidProfile.new
    @covid_profile_types = CovidProfileType.all
    @covid_profile.covid_profile_phones.build
  end

  # GET /covid_profiles/1/edit
  def edit
  end

  # POST /covid_profiles
  # POST /covid_profiles.json
  def create
    @covid_profile = CovidProfile.new(covid_profile_params)

    respond_to do |format|
      if @covid_profile.save
        flash.now[:success] = @covid_profile.full_info+" se ha creado correctamente."
        format.html { redirect_to @covid_profile }
        format.js
      else
        flash[:error] = "El paciente no se ha podido crear."
        format.html { render :new }
        format.js { render layout: false, content_type: 'text/javascript' }
      end
    end
  end

  # PATCH/PUT /covid_profiles/1
  # PATCH/PUT /covid_profiles/1.json
  def update
    respond_to do |format|
      if @covid_profile.update(covid_profile_params)
        flash[:success] = @covid_profile.full_info+" se ha modificado correctamente."
        format.html { redirect_to @covid_profile }
      else
        flash.now[:error] = @covid_profile.full_info+" no se ha podido modificar."
        format.html { render :edit }
      end
    end
  end

  # DELETE /covid_profiles/1
  # DELETE /covid_profiles/1.json
  def destroy
    @full_info = @covid_profile.full_info
    @covid_profile.destroy
    respond_to do |format|
      flash.now[:success] = "El paciente "+@full_info+" se ha eliminado correctamente."
      format.js
    end
  end

  # GET /covid_profile/1/delete
  def delete
    respond_to do |format|
      format.js
    end
  end

  def search
    @covid_profiles = CovidProfile.order(:first_name).search_query(params[:term]).limit(10)
    render json: @covid_profiles.map{ |pat| { id: pat.id, dni: pat.dni, label: pat.fullname } }
  end

  def get_by_dni_and_fullname
    @covid_profiles = CovidProfile.get_by_dni_and_fullname(params[:term]).limit(10).order(:last_name)
    render json: @covid_profiles.map{ |pat| { id: pat.id, label: pat.dni.to_s+" "+pat.last_name+" "+pat.first_name, dni: pat.dni }  }
  end

  def get_by_dni
    @covid_profiles = CovidProfile.search_dni(params[:term])
    if @covid_profiles.present?
      render json: @covid_profiles.map{ |pat| { label: pat.dni.to_s+" "+pat.last_name+" "+pat.first_name, dni: pat.dni, fullname: pat.fullname, establishment: pat.epidemic_sheet.establishment.name, url: epidemic_sheet_path(pat.epidemic_sheet)}  }
    else
      
      dni = params[:term]
      token = ENV['ANDES_TOKEN']
      url = ENV['ANDES_MPI_URL']
      andes_covid_profiles = RestClient::Request.execute(method: :get, url: url,
        timeout: 30, headers: {
          "Authorization" => "JWT #{token}",
          params: {'documento': dni}
        }
      )
      if JSON.parse(andes_covid_profiles).count > 0
        render json: JSON.parse(andes_covid_profiles).map{ |pat| { create: true, label: pat['documento'].to_s+" "+pat['apellido']+" "+pat['nombre'], dni: pat['documento'], fullname: pat['apellido']+" "+pat['nombre'], data: pat  }  }
      else
        render json: [0].map{ |pat| { create: true, dni: params[:term], label: "Agregar paciente" }}
      end    
    end    
  end

  def get_by_fullname
    @covid_profiles = CovidProfile.search_fullname(params[:term]).limit(10).order(:last_name)
    render json: @covid_profiles.map{ |pat| { id: pat.id, label: pat.dni.to_s+" "+pat.fullname, dni: pat.dni, fullname: pat.fullname  }  }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_covid_profile
      @covid_profile = CovidProfile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def covid_profile_params
      params.require(:covid_profile).permit(:first_name, :last_name, :dni,
        :email, :birthdate, :sex, :marital_status,
        covid_profile_phones_attributes: [:id, :phone_type, :number, :_destroy])
    end
end
