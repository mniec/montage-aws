require 'tmpdir'

module MontageAWS
  class ProjectAndDownload

    def initialize  params
      @activity_task = params[:activity_task]
      @montage_helper = params[:montage_helper]
      @s3 = params[:s3]
      @logger = params[:logger]
      @config = params[:config]
    end
    
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
      @montage_helper.get rawdir, lines
      @activity_task.record_heartbeat! :details=> "33%"
      info "making list"
      @montage_helper.make_list rawtbl, rawdir
      info "making template"
      @montage_helper.make_template templ, x, y, h, w
      info "projecting"
      @montage_helper.project projdir, stats, rawdir, rawtbl, templ
      @activity_task.record_heartbeat! :details=> "66%"
      
      upload_results "#{@activity_task.activity_id}", Dir.glob("#{projdir}/*")

      @activity_task.record_heartbeat! :details=> "100%"
      @activity_task.complete!
    end
    
    
    def upload_results prefix, files
      return if files.size == 0
      b = @s3.buckets[@config[:s3_bucket]]
      files.each do |file|
        b.objects["#{prefix}/#{file}"].write(Pathname.new(file))
      end
    end

    def info msg
      @logger.puts msg
    end
  end
end
