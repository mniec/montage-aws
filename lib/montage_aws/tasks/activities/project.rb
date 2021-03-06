require 'tmpdir'
require 'fileutils'

module MontageAWS
  class Project < ActivityTask

    def execute
      @activity_task.record_heartbeat! :details=> "0%"

      lines = @activity_task.input.split("\n").map {|x| x.strip}
      x,y,h,w = lines.shift.split(" ").map {|x| x.to_f}
      
      dir     = Dir.mktmpdir
      rawdir  = File.join dir, "raw"
      projdir = File.join dir, "proj"
      rawtbl  = File.join dir, "raw.tbl"
      templ   = File.join dir, "template.hdr"
      stats   = File.join dir, "stats.tbl"
      
      Dir.mkdir rawdir
      Dir.mkdir projdir
      
      info "fetching images"
      @montage.get rawdir, lines
      @activity_task.record_heartbeat! :details=> "33%"
      info "making list"
      @montage.make_list rawtbl, rawdir
      info "making template"
      @montage.make_template templ, x, y, h, w
      info "projecting"
      @montage.project projdir, stats, rawdir, rawtbl, templ
      @activity_task.record_heartbeat! :details=> "66%"
      
      files = Dir.glob("#{projdir}/*")
      ids = upload_results("#{@activity_task.activity_id}", files)

      FileUtils.remove_dir dir, :force => true

      @activity_task.record_heartbeat! :details=> "100%"
      @activity_task.complete! :result => ids.join("\n")
    end
    
    
    def upload_results prefix, files
      bucket_name = @config[:s3_bucket]
      return if files.size == 0
      b = @s3.buckets[bucket_name]
      files.map do |file|
        id = "#{prefix}/#{File.basename(file)}"
        b.objects[id].write(Pathname.new(file))
        id
      end
    end

    def info msg
      @logger.puts msg
    end
  end
end
