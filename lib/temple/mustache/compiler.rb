module Temple
  module Mustache
    # The Generator is in charge of taking an array of Mustache tokens,
    # usually assembled by the Parser, and generating an interpolatable
    # Ruby string. This string is considered the "compiled" template
    # because at that point we're relying on Ruby to do the parsing and
    # run our code.
    #
    # For example, let's take this template:
    #
    #   Hi {{thing}}!
    #
    # If we run this through the Parser we'll get these tokens:
    #
    #   [:multi,
    #     [:static, "Hi "],
    #     [:mustache, :etag, "thing"],
    #     [:static, "!\n"]]
    #
    # Now let's hand that to the Generator:
    #
    # >> puts Mustache::Generator.new.compile(tokens)
    # "Hi #{CGI.escapeHTML(ctx[:thing].to_s)}!\n"
    #
    # You can see the generated Ruby string for any template with the
    # mustache(1) command line tool:
    #
    #   $ mustache --compile test.mustache
    #   "Hi #{CGI.escapeHTML(ctx[:thing].to_s)}!\n"
    class Compiler < Filter
      set_default_options :dictionary => 'self',
                          :partial    => 'partial'

      temple_dispatch :mustache

      def compile(exp)
        [:multi,
         [:block, "_mudict = #{options[:dictionary]}"],
         super]
      end

      # Callback fired when the compiler finds a section token. We're
      # passed the section name and the array of tokens.
      def on_mustache_section(name, content, raw_content)
        content = compile!(content)

        tmp1, tmp2 = tmp_var, tmp_var
        [:multi,
         [:block,   "if #{tmp1} = _mudict[#{name.to_sym.inspect}]"],
         [:block,   "  if #{tmp1} == true"],
         content,
         [:block,   "  elsif Proc === #{tmp1}"],
         [:dynamic, "    #{tmp1}.call(#{raw_content.inspect})"],
         [:block,   '  else'],
         [:block,   "    #{tmp1} = [#{tmp1}] if #{tmp1}.respond_to?(:has_key?) || !#{tmp1}.respond_to?(:map)"],
         [:block,   "    #{tmp2} = _mudict"],
         [:block,   "    #{tmp1}.each {|_mudict|"],
         content,
         [:block,   '    }'],
         [:block,   "    _mudict = #{tmp2}"],
         [:block,   '  end'],
         [:block,   'end']]
      end

      # Fired when we find an inverted section. Just like `on_section`,
      # we're passed the inverted section name and the array of tokens.
      def on_mustache_inverted_section(name, content)
        content = compile!(content)

        tmp = tmp_var
        [:multi,
         [:block, "#{tmp} = _mudict[#{name.to_sym.inspect}]"],
         [:block, "if !#{tmp} || #{tmp}.respond_to?(:empty) && #{tmp}.empty?"],
         content,
         [:block, 'end']]
      end

      # Fired when the compiler finds a partial. We want to return code
      # which calls a partial at runtime instead of expanding and
      # including the partial's body to allow for recursive partials.
      def on_mustache_partial(name)
        [:dynamic, "#{options[:partial]}(#{name.to_sym.inspect})"]
      end

      # A tag
      def on_mustache_tag(name, escape)
        if escape
          [:escape, :dynamic, "_mudict[#{name.to_sym.inspect}]"]
        else
          [:dynamic, "_mudict[#{name.to_sym.inspect}]"]
        end
      end

      private

      # Generate unique temporary variable name
      #
      # @return [String] Variable name
      def tmp_var
        @tmp_var ||= 0
        "_mutmp#{@tmp_var += 1}"
      end

    end
  end
end
