module Persistible
  module ClassMethods
    def all_instances!
      descendants.flat_map do |descendant|
        descendant.table.entries.map { |fila| get_instancia_by_descendant(descendant, fila) }
      end
    end

    def get_instancia_by_descendant( descendant, fila )
      instancia = descendant.new
      instancia.id = fila[:id]
      instancia.refresh!
      instancia
    end

    def descendants
      ObjectSpace.each_object(Class).select { |klass| klass <= self }.reject(&:singleton_class?)
    end

    def get_validates(no_blank, from, to, validate)
      validates = []
      validates << Hash[:no_blank, no_blank] unless no_blank.nil?
      validates << Hash[:from, from] unless from.nil?
      validates << Hash[:to, to] unless to.nil?
      validates << Hash[:validate, validate] unless validate.nil?
      validates
    end

    def has_many(tipo, named: raise('named requerido'), no_blank: nil, from: nil, to: nil, validate: nil, default: nil)
      has_field(tipo, named, no_blank, from, to, validate, HasManyPersistible.new, default)
    end

    def has_one(tipo, named: raise('named requerido'), no_blank: nil, from: nil, to: nil, validate: nil, default: nil)
      has_field(tipo, named, no_blank, from, to, validate, HasOnePersistible.new, default)
    end

    def has_field(tipo, named, no_blank, from, to, validate, relation, default)
      ancestors_persistibles = self.ancestors.filter {|a| a.include?(Persistible) }

      atributos_ancestros = []
      ancestors_persistibles.each do |ancestor|
        atributos_ancestros = atributos_ancestros + ancestor.attr_persistibles.atributos
      end

      attr_accessor named.to_sym
      tabla_clase = attr_persistibles


      atributos_ancestros.each do |atributo|
        next if tabla_clase.repite_columna?(atributo)
        tabla_clase.agregar_columna!(atributo)
      end

      relation.type = tipo
      relation.named = named
      relation.crear_validaciones(from, to, no_blank, validate)
      relation.default = default
      tabla_clase.agregar_columna!(relation)
    end

    def find_by_id_from_table(id)
      table.entries.find { |fila| fila[:id] == id }
    end

    def method_missing(m, *args, &block)
      if es_find_by(m)
        primer_parametro = args[0]
        nombre_metodo = m.to_s.delete_prefix('find_by_')

        all_instances!.filter do |instancia|
          case primer_parametro
          when Proc
            valor_atributo_instancia = instancia.send(nombre_metodo)
            instancia.instance_exec(*valor_atributo_instancia, &primer_parametro)
          else
            valor_atributo_instancia =  instancia.send(nombre_metodo, *args[1, args.size])
            valor_atributo_instancia === primer_parametro
          end
        end
      else
        super
      end
    end

    def respond_to_missing?(m, include_private = false)
      es_find_by(m) || super
    end


    def attr_persistibles
      @attr_persistibles ||= AtributosPersistibles.new(name)
    end

    def table
      @table ||= table_by_name(self)
    end

    def table_by_name(klass)
      TADB::DB.table(klass.name)
    end

    private

    def es_find_by(m)
      m.to_s =~ /find_by_(.*)/ && method_defined?(Regexp.last_match(1))
    end
  end
end