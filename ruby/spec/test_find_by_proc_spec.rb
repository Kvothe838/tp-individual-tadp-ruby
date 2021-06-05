require_relative 'spec_models/find_by_proc/student_find_by_proc.rb'

describe 'test_find_by_proc' do
  let(:nombre_un_estudiante) do
    "Pedro Perez"
  end

  let(:un_estudiante) do
    un_estudiante = Student_FindByProc.new
    un_estudiante.full_name = nombre_un_estudiante
    un_estudiante.grade = 7
    un_estudiante
  end

  let(:nombre_otro_estudiante) do
    "Maria Sanchez"
  end

  let(:otro_estudiante) do
    otro_estudiante = Student_FindByProc.new
    otro_estudiante.full_name = nombre_otro_estudiante
    otro_estudiante.grade = 5
    otro_estudiante
  end

  context 'test find_by_what con proc' do
    before do
      un_estudiante.save!
      otro_estudiante.save!
    end

    it 'retorna los estudiantes con id igual a 5' do
      estudiantes_con_id_5 = Student_FindByProc.find_by_id("5")
      expect(estudiantes_con_id_5.length).to be 0
    end

    it 'retorna los estudiantes con grade mayor a 6' do
      estudiantes_aprobados = Student_FindByProc.find_by_grade(proc { |grade| grade > 6 })
      expect(estudiantes_aprobados.length).to be 1
      expect(estudiantes_aprobados[0].full_name).to eq(nombre_un_estudiante)
    end

    it 'falla porque el bloque lanza un error' do
      filtrador = proc { |name| name.this_message_doesnt_exist()}
      expect {Student_FindByProc.find_by_full_name(filtrador)}.to raise_error(NoMethodError)
    end
  end
end