module MontageAWS
  class ProjectAndDownload
    def initialize activity_task, params
      @activity_task = activity_task
      @montage_helper = params[:montage_helper]
      @s3 = params[:s3]
    end
    
    def execute
      @activity_task.record_heartbeat! :details=> "0%"
      x,y,h,w = @activity_task.workflow_execution.input.split(" ").map {|x| x.to_f}
      run_id = @activity_task.workflow_execution.run_id
      lines = @activity_task.input.split("\n").map {|x| x.strip}
      
      dir     = Dir.mktmpdir
      rawdir  = File.join dir, "raw"
      projdir = File.join dir, "proj"
      rawtbl  = File.join dir, "raw.tbl"
      templ   = File.join dir, "template.hdr"
      stats   = File.join dir, "stats.tbl"
      
      Dir.mkdir rawdir
      Dir.mkdir projdir

      @montage_helper.get rawdir, lines
      @activity_task.record_heartbeat! :details=> "33%"
      @montage_helper.make_list rawtbl, rawdir
      @montage_helper.make_template templ, x, y, h, w
      @montage_helper.project rawdir, rawtbl, templ, projdir, stats
      @activity_task.record_heartbeat! :details=> "66%"
      
      upload_results "#{run_id}/#{@activity_task.activity_id}", Dir.glob("#{projdir}/*")
      @activity_task.record_heartbeat! :details=> "100%"
      @activity_task.complete!
    end
    
    
    def upload_results prefix, files
      return if files.size == 0
      b = @s3.buckets['montage']
      files.each do |file|
        b.objects["#{prefix}/#{file}"].write(Pathname.new(file))
      end
    end
  end
end
