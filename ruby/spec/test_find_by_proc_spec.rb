require_relative 'spec_models/find_by_proc/student_find_by_proc.rb'

describe 'test_find_by_proc' do
  it 'retorna los estudiantes con grade mayor a 6' do
    estudiante_aprobado = Student.new
    nombre_estudiante_aprobado = "Pedro Perez"
    estudiante_aprobado.full_name = nombre_estudiante_aprobado
    estudiante_aprobado.grade = 7
    estudiante_desaprobado = Student.new
    nombre_estudiante_desaprobado = "Maria Sanchez"
    estudiante_desaprobado.full_name = nombre_estudiante_desaprobado
    estudiante_desaprobado.grade = 5

    estudiante_aprobado.save!
    estudiante_desaprobado.save!

    estudiantes_aprobados = Student.find_by_grade(proc { |grade| grade > 6 })
    expect(estudiantes_aprobados.length).to be 1
    expect(estudiantes_aprobados[0].full_name).to eq(nombre_estudiante_aprobado)
  end
end