#-*- mode: ruby -*-

task :default => "montage_aws.gem"

file "montage_aws.gem" => "montage_aws.gemspec" do
  sh "gem build 'montage_aws.gemspec'"
end	       

task :install => ["montage_aws.gem"] do
  sh "gem install montage_aws --no-ri --no-rdoc"
end
