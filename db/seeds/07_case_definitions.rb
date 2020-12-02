DiagnosticMethod.create(name: 'Test rápido')
DiagnosticMethod.create(name: 'PCR')
DiagnosticMethod.create(name: 'Contacto epidemiológico')

ContactType.create(name: 'Conviviente')
ContactType.create(name: 'Social')
ContactType.create(name: 'Laboral')

CaseStatus.create(name: 'Sospechoso', badge: 'secondary', needs_diagnostic: false)
CaseStatus.create(name: 'Pendiente', badge: 'warning', needs_diagnostic: true)
CaseStatus.create(name: 'Positivo', badge: 'danger', needs_diagnostic: true)
CaseStatus.create(name: 'Negativo', badge: 'secondary', needs_diagnostic: true)
CaseStatus.create(name: 'Recuperado', badge: 'success', needs_diagnostic: false)
CaseStatus.create(name: 'Fallecido', badge: 'dark', needs_diagnostic: false)
CaseStatus.create(name: 'Bloqueado', badge: 'primary', needs_diagnostic: false)

SpecialDevice.create(name: 'No')
SpecialDevice.create(name: 'DetectAR')
SpecialDevice.create(name: 'Unidad centinela IRA')
SpecialDevice.create(name: 'Corte transversal')

