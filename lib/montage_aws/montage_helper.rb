module MontageAWS
  class MontageHelper
    def divide x, y, height, width,  machines
      loc = "/tmp/montage_tmp"
      exec %{mArchiveList DSS DSS2B "#{x} #{y}" #{width} #{height} #{loc}}

      lines = File.open(loc).readlines
      lines.shift 3 #skip headers
      lines = process_lines(lines)
      
      per_machine = lines.size / machines
      rest = lines.size % machines
      
      res = []
      if per_machine > 0
        1.upto machines do
          res << lines.shift(per_machine).join("")
        end
      end
      if rest > 0
        res << lines.shift(rest).join("")
      end
      res
    end
    
    def exec cmd
      system cmd
    end

    def process_lines lines
      lines.map do |l|
        _,url,file = */(http:\/\/[^\s]+)\s+(.+)/.match(l)
        "#{url} #{file}"
      end
    end
    
  end
end
