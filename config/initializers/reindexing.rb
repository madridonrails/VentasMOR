ActiveRecord::Base.class_eval do
  def self.reindexes(association, options={})
    flag_name   = "@thinking_sphinx_#{association}_needs_reindex"
    flag_lambda = case options[:if]
      when Symbol, String then
        lambda {|record| record.send(options[:if])}
      when Proc then
        options[:if]
      end

    if flag_lambda
      before_save do |record|
        record.instance_variable_set(flag_name, flag_lambda.call(record))
        :"prevent the return value of instance_variable_get from halting"
      end
    end

    after_commit_method_name = "thinking_sphinx_reindex_#{association}"
    after_commit after_commit_method_name
    macro = reflect_on_association(association).macro
    if [:has_many, :has_and_belongs_to_many].include?(macro)
      define_method(after_commit_method_name) do
        if !flag_lambda || instance_variable_get(flag_name)
          collection = send(association)
          unless collection.empty?
            logger.info("reindexing #{association} of #{self.class} with ID #{self.id}")
            child = collection.first
            child.transaction do
              # The find_each iterator is provided by pseudo_cursors.
              collection.find_each do |record|
                record.delta = true
                record.save_without_after_commit_callback(false)
              end
            end
            child.send(:index_delta)
          end
        end
      end
    else
      define_method(after_commit_method_name) do
        if !flag_lambda || instance_variable_get(flag_name)
          logger.info("reindexing #{association} of #{self.class} with ID #{self.id}")
          send(association).save(false) rescue :ignore
        end
      end
    end
  end
end
