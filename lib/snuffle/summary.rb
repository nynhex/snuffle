module Snuffle

  class Summary

    include PoroPlus

    attr_accessor :class_name, :path_to_file, :object_candidates, :source_file

  end

end