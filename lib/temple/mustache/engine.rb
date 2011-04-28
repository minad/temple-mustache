module Temple
  module Mustache
    class Engine < Temple::Engine
      use Temple::Mustache::Parser
      use Temple::Mustache::Compiler
      filter :ControlFlow
      filter :Escapable, :use_html_safe
      filter :MultiFlattener
      filter :DynamicInliner
      generator :ArrayBuffer
    end
  end
end
