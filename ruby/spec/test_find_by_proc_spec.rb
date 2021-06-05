require_relative 'spec_models/find_by_proc/student_find_by_proc.rb'

describe 'test_find_by_proc' do
  let(:nombre_un_estudiante) do
    "Pedro Perez"
  end

  let(:un_estudiante) do
    un_estudiante = Student.new
    un_estudiante.full_name = nombre_un_estudiante
    un_estudiante.grade = 7
    un_estudiante
  end

  let(:nombre_otro_estudiante) do
    "Maria Sanchez"
  end

  let(:otro_estudiante) do
    otro_estudiante = Student.new
    otro_estudiante.full_name = nombre_otro_estudiante
    otro_estudiante.grade = 5
    otro_estudiante
  end

  # it 'retorna los estudiantes con id igual a 5' do
  #   Student.find_by_id("5")
  # end

  it 'retorna los estudiantes con grade mayor a 6' do
    un_estudiante.save!
    otro_estudiante.save!

    estudiantes_aprobados = Student.find_by_grade(proc { |grade| grade > 6 })
    expect(estudiantes_aprobados.length).to be 1
    expect(estudiantes_aprobados[0].full_name).to eq(nombre_un_estudiante)
  end

  it 'falla porque el bloque lanza un error' do
    un_estudiante.save!
    otro_estudiante.save!

    expect {Student.find_by_full_name(proc { |name| name.this_message_doesnt_exist()})}.to raise_error(NoMethodError)
  end
end