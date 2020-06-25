Gem::Specification.new do |spec|
  spec.name          = "ny-apiauth"
  spec.version       = "1.0.0"
  spec.authors       = ["P Kirwin"]
  spec.email         = ["peter@puzzlesandwich.com"]

  spec.summary       = "A method for validating requests across NY APIs"
  spec.homepage      = "http://www.puzzlesandwich.com"

  spec.files         = ["lib/apiauth.rb"]
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'jwt'
end
