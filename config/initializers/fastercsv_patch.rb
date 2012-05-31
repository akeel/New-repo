module Mangu
  module MonkeyPatch
    module FasterCSVPatch
      def self.foreach(path, options = Hash.new, &block)
        File.open(path, "rb", options) do |csv|
          csv.each(&block)
        end
      end
    end
  end
end
FasterCSV.send(:include, Mangu::MonkeyPatch::FasterCSVPatch)