class Category < ActiveRecord::Base
  default_scope { order(:id) }
end
