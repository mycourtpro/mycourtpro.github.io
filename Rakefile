
desc %{
  does rm -fR _site/
}
task :clean do
  exec('rm -fR _site/')
end

desc %{
  generate (continually) and serve the Jekyll site on port 4000
}
task :serve do
  exec('bundle exec jekyll --server')
end

desc %{
  generate continually the site (no serving on 4000)
}
task :gen do
  exec('bundle exec jekyll')
end

desc %{
  triggers Compass compilation
}
task :css do
  exec('bundle exec compass compile _scss/')
end

