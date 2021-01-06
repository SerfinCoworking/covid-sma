class PatientsController < ApplicationController
  before_action :set_patient, only: [:show, :edit, :update, :update_parent_contact, 
    :set_parent_contact, :destroy, :delete, :validate]
  require 'json'
  require 'rest-client'
  # GET /patients
  # GET /patients.json
  def index
    @filterrific = initialize_filterrific(
      Patient,
      params[:filterrific],
      select_options: {
        sorted_by: Patient.options_for_sorted_by,
        with_patient_type_id: PatientType.options_for_select
      },
      persistence_id: false,
      default_filter_params: {sorted_by: 'created_at_desc'},
      available_filters: [
        :sorted_by,
        :search_fullname,
        :search_dni,
        :with_patient_type_id,
      ],
    ) or return
    @patients = @filterrific.find.page(params[:page]).per_page(15)
  end

  # GET /patients/1
  # GET /patients/1.json
  def show
    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /patients/new
  def new
    @patient = Patient.new
    @patient_types = PatientType.all
    @patient.patient_phones.build
  end

  # GET /patients/1/edit
  def edit
    @patient_types = PatientType.all
  end

  def set_parent_contact
    authorize @patient
  end

  # POST /patients
  # POST /patients.json
  def create
    @patient = Patient.new(patient_params)

    respond_to do |format|
      if @patient.save
        flash.now[:success] = @patient.full_info+" se ha creado correctamente."
        format.html { redirect_to @patient }
        format.js
      else
        flash[:error] = "El paciente no se ha podido crear."
        format.html { render :new }
        format.js { render layout: false, content_type: 'text/javascript' }
      end
    end
  end

  # PATCH/PUT /patients/1
  # PATCH/PUT /patients/1.json
  def update
    respond_to do |format|
      if @patient.update(patient_params)
        flash[:success] = @patient.full_info+" se ha modificado correctamente."
        format.html { redirect_to @patient }
      else
        flash.now[:error] = @patient.full_info+" no se ha podido modificar."
        format.html { render :edit }
      end
    end
  end

  def update_parent_contact
    respond_to do |format|
      if @patient.update(parent_contact_params)
        flash[:success] = "A "+@patient.full_info+" se le ha registrado un contacto padre correctamente."
        format.html { redirect_to @patient.epidemic_sheet }
      else
        flash[:error] = @patient.full_info+" no se ha podido modificar."
        format.html { render :set_parent_contact }
      end
    end
  end

  # DELETE /patients/1
  # DELETE /patients/1.json
  def destroy
    @full_info = @patient.full_info
    @patient.destroy
    respond_to do |format|
      flash.now[:success] = "El paciente "+@full_info+" se ha eliminado correctamente."
      format.js
    end
  end

  # GET /patient/1/delete
  def delete
    respond_to do |format|
      format.js
    end
  end

  def search
    @patients = Patient.order(:first_name).search_query(params[:term]).limit(10)
    render json: @patients.map{ |pat| { id: pat.id, dni: pat.dni, label: pat.fullname } }
  end

  def get_by_dni_and_fullname
    @patients = Patient.get_by_dni_and_fullname(params[:term]).limit(10).order(:last_name)
    render json: @patients.map{ |pat| { id: pat.id, label: pat.dni.to_s+" "+pat.last_name+" "+pat.first_name, dni: pat.dni }  }
  end

  def get_by_dni
    @patients = Patient.search_dni(params[:term])
    if @patients.present?
      render json: @patients.map{ |pat| { label: pat.dni.to_s+" "+pat.last_name+" "+pat.first_name, dni: pat.dni, fullname: pat.fullname, establishment: pat.epidemic_sheet.establishment.name, url: epidemic_sheet_path(pat.epidemic_sheet)}  }
    else
      dni = params[:term]
      token = ENV['ANDES_TOKEN']
      url = ENV['ANDES_MPI_URL']
      andes_patients = RestClient::Request.execute(method: :get, url: "#{url}/",
        timeout: 30, headers: {
          "Authorization" => "JWT #{token}",
          params: {'documento': dni}
        }
      )
      if JSON.parse(andes_patients).count > 0
        render json: JSON.parse(andes_patients).map{ |pat| { create: true, label: pat['documento'].to_s+" "+pat['apellido']+" "+pat['nombre'], dni: pat['documento'], fullname: pat['apellido']+" "+pat['nombre'], data: pat  }  }
      else
        render json: [0].map{ |pat| { create: true, dni: params[:term], label: "Agregar paciente" }}
      end    
    end    
  end

  def get_by_fullname
    @patients = Patient.search_fullname(params[:term]).limit(10).order(:last_name)
    if @patients.count > 0
      render json: @patients.map{ |pat| { id: pat.id, label: pat.dni.to_s+" "+pat.fullname, 
        dni: pat.dni, fullname: pat.fullname  
      }}
    else
      render json: [0].map{ |pat| { dni: params[:term], label: "Agregar paciente" }}
    end   
  end

  def get_by_dni_locally
    @patients = Patient.search_dni(params[:term]).limit(10).order(:last_name)
    if @patients.count > 0
      render json: @patients.map{ |pat| { id: pat.id, label: pat.dni.to_s+" "+pat.fullname, epidemic_sheet_id: pat.epidemic_sheet.id,
        dni: pat.dni, fullname: pat.fullname, lastname: pat.last_name, firstname: pat.first_name  
      }}
    else
      render json: [0].map{ |pat| { label: "No se encontró ningun paciente con DNI: "+params[:term] }}
    end 
  end

  def get_by_lastname
    @patients = Patient.search_lastname(params[:term]).limit(10).order(:last_name)
    if @patients.count > 0
      render json: @patients.map{ |pat| { id: pat.id, label: pat.dni.to_s+" "+pat.fullname, epidemic_sheet_id: pat.epidemic_sheet.id,
        dni: pat.dni, fullname: pat.fullname, lastname: pat.last_name, firstname: pat.first_name
      }}
    else
      render json: [0].map{ |pat| { label: "No se encontró ningun paciente con apellido: "+params[:term] }}
    end 
  end

  def get_by_firstname
    @patients = Patient.search_firstname(params[:term]).limit(10).order(:first_name)
    if @patients.count > 0
      render json: @patients.map{ |pat| { id: pat.id, label: pat.dni.to_s+" "+pat.fullname, epidemic_sheet_id: pat.epidemic_sheet.id,
        dni: pat.dni, fullname: pat.fullname, lastname: pat.last_name, firstname: pat.first_name  
      }}
    else
      render json: [0].map{ |pat| { label: "No se encontró ningun paciente con nombre: "+params[:term] }}
    end 
  end

  def validate
    authorize @patient
    
    token = ENV['ANDES_TOKEN']
    url = ENV['ANDES_MPI_URL']
    andes_patients = RestClient::Request.execute(method: :get, url: "#{url}/",
      timeout: 30, headers: {
        "Authorization" => "JWT #{token}",
        params: {'documento': @patient.dni}
      }
    )
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_patient
      @patient = Patient.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def patient_params
      params.require(:patient).permit(:first_name, :last_name, :dni,
        :email, :birthdate, :sex, :marital_status, :assigned_establishment_id,
        patient_phones_attributes: [
          :id,
          :phone_type,
          :number,
          :_destroy
        ],
        current_address_attributes: [
          :neighborhood,
          :street,
          :street_number
        ]
      )
    end

    def parent_contact_params
      params.require(:patient).permit(:parent_contact_id)
    end
end
