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
          res << lines.shift(per_machine).join("\n")
        end
      end
      if rest > 0
        res << lines.shift(rest).join("\n")
      end
      res
    end
    
    def get dir, lines
      lines.each  do |l|
        url, file = l.split(/\s+/)
        path = File.join(dir,file.sub('.gz',''))
        exec "mArchiveGet '#{url}' #{path}"
      end
    end
    
    def make_list out, dir
      exec "mImgtbl #{dir} #{out}"
    end
    
    def make_template template, x, y, h, w
      exec "mHdr '#{x} #{y}' #{h} #{template}"
    end

    def project projdir, stats, rawdir, rawtbl, template
      exec "mProjExec -p #{rawdir} #{rawtbl} #{template} #{projdir} #{stats}"
    end

    def add res, projdir, projtbl, template
      exec "mAdd -p #{projdir} #{projtbl} #{template} #{res}"
    end

    def grayJPEG finalfits, finaljpeg
      exec "mJPEG -gray #{finalfits} 20% 99.98% loglog -out #{finaljpeg}"
    end
    
    def exec cmd
      puts "trying to exec: #{cmd}"
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
