desc "Run continuous integration tasks (spec, ...)"
task :ci => ["clean", "spec", "package:binary"]
