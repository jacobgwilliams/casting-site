class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # UUID primary keys are set in migrations; this keeps generated records consistent.
end
