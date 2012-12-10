Gem::Specification.new do |s|
  s.name        = 'montage_aws'
  s.version     = '0.0.1'
  s.date        = '2012-12-10'
  s.summary     = "Montage computiation using Amazon Web Services"
  s.description = "A Grid Systems class project aiming to utilise Amazon Web Services for doing montage computaton. "
  s.authors     = ["Michal Niec", "Pawel Pikula"]
  s.email       = 'michalniec@gmail.com'
  s.files       = `git ls-files`.split("\n")
  s.executables = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.homepage    =
    'https://www.git.npspace.pl/awscomp'
end
