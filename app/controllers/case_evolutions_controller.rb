class CaseEvolutionsController < ApplicationController
  before_action :set_case_evolution, only: [:edit, :update, :destroy, :delete]

  def edit
    
  end

  def update
    authorize @case_evolution

    respond_to do |format|
      if @case_evolution.update(case_evolution_params)
        EpidemicSheetMovement.create(user: current_user, epidemic_sheet: @case_evolution.epidemic_sheet, action: "editó evolución de caso", sector: current_user.sector)
        flash.now[:success] = 'La evolución de caso se ha modificado correctamente.'
        format.js
      else
        format.html { render :edit }
      end
    end
  end

  private

  def set_case_evolution
    @case_evolution = CaseEvolution.find(params[:id])
  end

  def case_evolution_params
    params.require(:case_evolution).permit(:created_at)
  end
end
