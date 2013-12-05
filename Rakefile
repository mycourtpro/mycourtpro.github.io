
desc %{
  does rm -fR _site/
}
task :clean do
  sh('rm -fR _site/')
end

desc %{
  generate (continually) and serve the Jekyll site on port 4000
}
task :serve do
  puts
  puts '  http://localhost:4000/'
  puts
  sh('bundle exec jekyll serve --watch')
end

desc "shortcut for 'rake serve'"
task :s => :serve

desc %{
  builds the jekyll site
}
task :build do
  sh('bundle exec jekyll build')
end

desc "shortcut for 'rake build'"
task :b => :build

desc %{
  triggers Compass compilation
}
task :css do
  sh('bundle exec compass compile _compass/')
end

desc "shortcut for 'rake css'"
task :c => :css

# hidden, used only once
task :copy do

  # bootstrap js files order matters
  # the order is given in _compass/vendor/bootstrap/javascript/bootstrap.js

  sh(
    'java -jar _tools/google-closure-compiler.jar ' +
    '--warning_level DEFAULT ' +
    '--language_in ECMASCRIPT5 ' +
    '--js' +
    ' _compass/vendor/bootstrap/javascripts/bootstrap-transition.js' +
    ' _compass/vendor/bootstrap/javascripts/bootstrap-affix.js' +
    ' _compass/vendor/bootstrap/javascripts/bootstrap-alert.js' +
    ' _compass/vendor/bootstrap/javascripts/bootstrap-button.js' +
    ' _compass/vendor/bootstrap/javascripts/bootstrap-carousel.js' +
    ' _compass/vendor/bootstrap/javascripts/bootstrap-collapse.js' +
    ' _compass/vendor/bootstrap/javascripts/bootstrap-dropdown.js' +
    ' _compass/vendor/bootstrap/javascripts/bootstrap-modal.js' +
    ' _compass/vendor/bootstrap/javascripts/bootstrap-scrollspy.js' +
    ' _compass/vendor/bootstrap/javascripts/bootstrap-tab.js' +
    ' _compass/vendor/bootstrap/javascripts/bootstrap-tooltip.js' +
    ' _compass/vendor/bootstrap/javascripts/bootstrap-popover.js' +
    ' _compass/vendor/bootstrap/javascripts/bootstrap-typeahead.js' +
    ' > js/bootstrap.min.js')

  sh('cp _compass/vendor/bootstrap/images/* images/')
  sh('cp _compass/vendor/font-awesome/fonts/* fonts/')
end

# hidden, not much use
task :kss do
  sh('find . -name .sass-cache | xargs rm -fR')
end

