module Gcm
  class Base < ActiveRecord::Base   #nodoc
    self.abstract_class = true
  end
end