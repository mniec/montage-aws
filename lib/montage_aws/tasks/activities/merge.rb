require 'tmpdir'
require 'fileutils'

module MontageAWS
  class Merge < ActivityTask

    def execute
      lines = @activity_task.input.split("\n").map { |x| x.strip }
      x, y, h, w = lines.shift.split(" ").map { |x| x.to_f }

      dir = Dir.mktmpdir
      projdir = File.join dir, 'projdir'
      template = File.join dir, 'template.hdr'
      projtbl = File.join dir, 'proj.tbl'
      finaldir = File.join dir, 'final'
      finalfits = File.join finaldir, 'final.fits'
      finaljpeg = File.join finaldir, 'final.jpg'

      Dir.mkdir projdir
      Dir.mkdir finaldir

      download_files projdir, lines

      @montage.make_template template, x, y, h, w
      @montage.make_list projtbl, projdir
      @montage.add finalfits, projdir, projtbl, template
      @montage.grayJPEG finalfits, finaljpeg
      ids = upload_results("#{@activity_task.activity_id}", [finaljpeg])

      FileUtils.remove_dir dir, :force => true

      @activity_task.record_heartbeat! :details => "100%"
      @activity_task.complete! :result => ids.first
    end

    def download_files dir, files
      bucket_name = @config[:s3_bucket]
      b = @s3.buckets[bucket_name]
      files.each do |f|
        obj = b.objects[f]
        basename = File.basename(f)
        output = File.join(dir, basename)

        File.open(output, 'w') do |fd|
          obj.read { |chunk| fd.write(chunk) }
        end
      end
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
  end
end