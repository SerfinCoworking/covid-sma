class PatientPolicy < ApplicationPolicy
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

  def update?
    user.has_any_role?(:admin, :estadistica)
  end

  def edit?
    update?
  end

  def set_parent_contact?
    update?
  end

  def destroy?
    user.has_any_role?(:admin)
  end

  def validate?
    if record.Temporal?
      update?
    end
  end
end
