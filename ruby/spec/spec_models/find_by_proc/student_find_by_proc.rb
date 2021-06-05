require_relative '../../../src/persistible'

class Student_FindByProc
  include Persistible

  has_one String, named: :full_name
  has_one Numeric, named: :grade
end

