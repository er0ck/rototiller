module Beaker
  module Hosts
    def sut
      find_only_one('agent')
    end
  end
end
