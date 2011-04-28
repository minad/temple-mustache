module Temple
  module Mustache
    Template = Temple::Templates::Tilt(Temple::Mustache::Engine, :register_as => :mustache)
  end
end
