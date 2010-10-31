require 'bacon'
require 'temple'
require 'temple/mustache'

class Bacon::Context
  def mustache(src, dict = {})
    Temple::Mustache::Template.new { src }.render(dict)
  end
end

describe Temple::Mustache::Template do

  it 'should iterate over objects' do
    src = %q{
<ul>
  {{#person}}
    <li class="person">
      <div class="name">{{name}}</div>
    </li>
  {{/person}}
</ul>
}
    ans = %q{
<ul>
  <li class="person">
      <div class="name">Joe</div>
    </li>
  <li class="person">
      <div class="name">Jack</div>
    </li>
  </ul>
}

    dict = {
      :person => [
        {:name => 'Joe'},
        {:name => 'Jack'},
      ]
    }

    mustache(src, dict).should.equal ans
  end

  it 'should handle non-false values' do
    src = %q{
{{#person}}
  <div class="person">
    <div class="name">{{name}}</div>
  </div>
{{/person}}
}

    ans = %q{
<div class="person">
    <div class="name">Joe</div>
  </div>
}

    dict = {
      :person => {
        :name => 'Joe',
      }
    }

    mustache(src, dict).should.equal ans
  end

  it 'should handle false values' do
    src = %q{
{{#person}}
  <div class="person">
    <div class="name">{{name}}</div>
  </div>
{{/person}}
{{^person}}
  No Person
{{/person}}
}

    ans = %q{
No Person
}

    mustache(src).should.equal ans
  end


  it 'should handle comments' do
    src = %q{
<h1>Today{{! ignore me }}.</h1>
}

    ans = %q{
<h1>Today.</h1>
}

    mustache(src).should.equal ans
  end

  it 'should set delimiter' do
    src = %q{
* {{a}}
{{=<% %>=}}
* <% b %>
<%={{ }}=%>
* {{c}}
}

    ans = %q{
* 1

* 2

* 3
}

    dict = {
      :a => 1,
      :b => 2,
      :c => 3,
    }

    mustache(src, dict).should.equal ans
  end

  it 'should handle procs' do
    src = %q{
  {{#proc}}
    {{value}}
  {{/proc}}
}

    ans = %q{
  
    foo
  }

    dict = {
      :proc => proc {|text|
        text.gsub('{{value}}', 'foo')
      }
    }

    mustache(src, dict).should.equal ans
  end
end
