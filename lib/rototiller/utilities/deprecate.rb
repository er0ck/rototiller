module Deprecate

  # deprecate a method and send its args to the new method
  # @param [Symbol] name - name of method to deprecate
  # @param [Symbol] replacement - name of new method
  def alias_and_deprecate(name, replacement)
    define_method(name) do |*args, &block|
      warn "#{name} is deprecated, please use ##{replacement}"
      send replacement, *args, &block
    end
  end

end
