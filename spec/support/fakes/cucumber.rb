module Cucumber
  module Glue
    module Dsl
      class << self
        def register_rb_hook(phase, tag_names, proc)
          proc.call
        end
      end
    end
  end
end
