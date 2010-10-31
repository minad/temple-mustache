module Temple
  module Mustache
    class Engine < Temple::Engine
      use Temple::Mustache::Parser
      use Temple::Mustache::Compiler
      filter :EscapeHTML, :use_html_safe
      filter :MultiFlattener
      filter :StaticMerger
      filter :DynamicInliner
      generator :ArrayBuffer
    end
  end
end
