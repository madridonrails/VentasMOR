ActiveRecord::Base.class_eval do  
  class << self
    
    def l10n_date(*syms)
      syms.each do |s|
        class_eval <<-EOS
          def #{s}_as_string
            #{s}.strftime("%d/%m/%Y") rescue ''
          end
        
          def #{s}_as_string=(v)
            if date = VentasgemUtils.parse_date(v)
              self.#{s} = date
            else
              self.errors.add(:#{s}, "fecha inválida")
            end
          end
        EOS
      end
    end
    
    def l10n_decimal(*syms)
      syms.each do |s|
        class_eval <<-EOS
        before_save do |record|
          if record.#{s}_before_type_cast.is_a?(String)
            record.#{s} = VentasgemUtils.parse_decimal(record.#{s}_before_type_cast)
          end
        end
        EOS
      end
    end
    
    def inherited_with_normalization(subclass)
      inherited_without_normalization(subclass)
      
      subclass.class_eval do
        # At this point we do not know for sure the table name of this model, it
        # could have a set_table_name afterwards, acts_as_versioned constructs
        # the model for versions as an anonymous class and then it sets the
        # table name by hand for example. We initialized this cattr explicitly
        # to nil to make this apparent.
        cattr_accessor :attributes_to_normalize_cache
        self.attributes_to_normalize_cache = nil

        # If this class has a pair x, x_normalized that we do want to manage
        # with this stuff just add :x to this cattr.
        cattr_accessor :attributes_not_to_normalize
        self.attributes_not_to_normalize = []
        
        # Let models be able to skip normalization of selected attributes.
        def self.skip_normalization_for(*attrs)
          self.attributes_not_to_normalize += attrs
        end
        
        # Flag to disable normalization altogether for this model.
        cattr_accessor :disable_normalization
        self.disable_normalization = false
        
        def self.attributes_to_normalize
          if attributes_to_normalize_cache.nil?
            self.attributes_to_normalize_cache = []
            column_names.map do |cn|
                if cn =~ /^(.*)_normalized$/ && column_names.include?($1) && !attributes_not_to_normalize.include?($1)
                  attributes_to_normalize_cache << $1
                end
            end
          end
          attributes_to_normalize_cache
        end
        
        def normalize_attributes
          return if self.class.disable_normalization
          self.class.attributes_to_normalize.each do |a|
            write_attribute("#{a}_normalized", VentasgemUtils.normalize_for_db(send(a)))
          end
        end
        before_save :normalize_attributes
      end
    end
      
    alias_method_chain :inherited, :normalization
  end
end
