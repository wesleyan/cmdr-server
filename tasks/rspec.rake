begin
  require 'spec'
  require 'spec/rake/spectask'
rescue LoadError

end

begin
  require 'spec/rake/spectask'

  desc "Run the specs under spec/"
  Spec::Rake::SpecTask.new do |t|
    t.spec_opts = ['--options', "spec/spec.opts"]
    t.spec_files = FileList['spec/**/*_spec.rb']
  end
rescue NameError, LoadError
  # No loss, warning printed already
end
