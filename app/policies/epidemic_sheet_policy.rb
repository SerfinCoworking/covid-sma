class EpidemicSheetPolicy < ApplicationPolicy
  def dashboard?
    user.has_any_role?(:admin, :medico, :estadistica, :invitado)
  end

  def index?
    user.has_any_role?(:admin, :medico, :estadistica, :invitado)
  end

  def show?
    index?
  end

  def create?
    user.has_any_role?(:admin, :medico, :estadistica)
  end

  def new?
    create?
  end

  def new_contact?
    create?
  end

  def update?
    user.has_any_role?(:admin, :medico, :estadistica)
  end

  def edit?
    update?
  end

  def destroy?
    user.has_any_role?(:admin)
  end

  def delete?
    destroy?
  end
  
  def set_in_sisa?
    user.has_any_role?(:admin, :sisa) && !record.is_in_sisa
  end
  
  def set_in_sisa_modal?
    set_in_sisa?
  end

  def get_by_patient_id?
    user.has_any_role?(:admin, :medico, :estadistica)
  end
end
