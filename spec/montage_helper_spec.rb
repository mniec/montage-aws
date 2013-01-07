require 'spec_helper'

describe MontageHelper do
  before(:each) do
  end

  subject do
    a = Object.new 
    a.extend MontageHelper
    a
  end

  describe "#divide" do
    it "call mArchiveList" do
      subject.should_receive(:exec).with('mArchiveList DSS DSS2B "2.2 3.3" 1 1 /tmp/montage_tmp').exactly(2) do
        File.open('/tmp/montage_tmp',"w") do |f|
          f.write(<<eos
\datatype=fitshdr
|   cntr|  ctype1|  ctype2|naxis1|naxis2|    crval1|    crval2|  crpix1|  crpix2|     cdelt1|     cdelt2|    crota2|       ra1|      dec1|       ra2|      dec2|       ra3|      dec3|       ra4|      dec4|                                                                                                                               URL|                               file|
|    int|    char|    char|   int|   int|    double|    double|  double|  double|     double|     double|    double|    double|    double|    double|    double|    double|    double|    double|    double|                                                                                                                              char|                               char|
       1 RA---TAN DEC--TAN   2556   2556   2.200000   3.300000  1278.50  1278.50 -0.00027778  0.00027778    0.00000   2.450351   3.049973   1.739362   3.049903   1.739032   3.759869   2.701050   3.759847 http://archive.stsci.edu/cgi-bin/dss_search?v=poss2ukstu_blue&r=2.094815&d=3.404994&e=J2000&w=42.60&h=42.60&f=fits&c=gz                poss2ukstu_blue_001_001.fits.gz
       2 RA---TAN DEC--TAN   2556   2556   2.200000   3.300000  1278.50  1278.50 -0.00027778  0.00027778    0.00000   2.450477   3.549965   1.739130   3.549884   1.738800   4.259773   2.701302   4.259748 http://archive.stsci.edu/cgi-bin/dss_search?v=poss2ukstu_blue&r=2.094762&d=3.904971&e=J2000&w=42.60&h=42.60&f=fits&c=gz                poss2ukstu_blue_001_002.fits.gz
       3 RA---TAN DEC--TAN   2556   2556   2.200000   3.300000  1278.50  1278.50 -0.00027778  0.00027778    0.00000   1.949649   3.049973   1.238737   3.049573   1.238050   3.759462   2.701050   3.759847 http://archive.stsci.edu/cgi-bin/dss_search?v=poss2ukstu_blue&r=1.593954&d=3.404810&e=J2000&w=42.60&h=42.60&f=fits&c=gz                poss2ukstu_blue_002_001.fits.gz
       4 RA---TAN DEC--TAN   2556   2556   2.200000   3.300000  1278.50  1278.50 -0.00027778  0.00027778    0.00000   1.949523   3.549965   1.238254   3.549500   1.237566   4.259311   2.701302   4.259748 http://archive.stsci.edu/cgi-bin/dss_search?v=poss2ukstu_blue&r=1.593649&d=3.904760&e=J2000&w=42.60&h=42.60&f=fits&c=gz                poss2ukstu_blue_002_002.fits.gz
eos
)
        end
      end
      res = subject.divide 2.2, 3.3, 1, 1, 10
      res.size.should eq(1)
      
      res =subject.divide 2.2, 3.3, 1,1, 2
      res.size.should eq(2)
    end
  end
  describe "#process_lines" do
    it 'should strip lines and leave only url and filename' do 
      lines = [
                "1 RA---TAN DEC--TAN   2556   2556   2.200000   3.300000  1278.50  1278.50 -0.00027778  0.00027778    0.00000   2.450351   3.049973   1.739362   3.049903   1.739032   3.759869   2.701050   3.759847 http://archive.stsci.edu/cgi-bin/dss_search?v=poss2ukstu_blue&r=2.094815&d=3.404994&e=J2000&w=42.60&h=42.60&f=fits&c=gz                poss2ukstu_blue_001_001.fits.gz\n","
       2 RA---TAN DEC--TAN   2556   2556   2.200000   3.300000  1278.50  1278.50 -0.00027778  0.00027778    0.00000   2.450477   3.549965   1.739130   3.549884   1.738800   4.259773   2.701302   4.259748 http://archive.stsci.edu/cgi-bin/dss_search?v=poss2ukstu_blue&r=2.094762&d=3.904971&e=J2000&w=42.60&h=42.60&f=fits&c=gz                poss2ukstu_blue_001_002.fits.gz\n",
"       3 RA---TAN DEC--TAN   2556   2556   2.200000   3.300000  1278.50  1278.50 -0.00027778  0.00027778    0.00000   1.949649   3.049973   1.238737   3.049573   1.238050   3.759462   2.701050   3.759847 http://archive.stsci.edu/cgi-bin/dss_search?v=poss2ukstu_blue&r=1.593954&d=3.404810&e=J2000&w=42.60&h=42.60&f=fits&c=gz                poss2ukstu_blue_002_001.fits.gz\n",
"       4 RA---TAN DEC--TAN   2556   2556   2.200000   3.300000  1278.50  1278.50 -0.00027778  0.00027778    0.00000   1.949523   3.549965   1.238254   3.549500   1.237566   4.259311   2.701302   4.259748 http://archive.stsci.edu/cgi-bin/dss_search?v=poss2ukstu_blue&r=1.593649&d=3.904760&e=J2000&w=42.60&h=42.60&f=fits&c=gz                poss2ukstu_blue_002_002.fits.gz"
               ]
      res = subject.process_lines lines
      res[0].should eq("http://archive.stsci.edu/cgi-bin/dss_search?v=poss2ukstu_blue&r=2.094815&d=3.404994&e=J2000&w=42.60&h=42.60&f=fits&c=gz poss2ukstu_blue_001_001.fits.gz")
    end
  end
end
