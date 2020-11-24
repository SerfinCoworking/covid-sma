module EpidemicSheetsHelper
  def label_case_definition_status(a_case)
    if a_case.sospechoso?
      return 'light'
    elsif a_case.pendiente?
      return 'warning'
    elsif a_case.positivo?
      return 'danger'
    elsif a_case.negativo?
      return 'primary'
    end
  end
end
