# A sample Guardfile
# More info at https://github.com/guard/guard#readme

## Uncomment and set this to only include directories you want to watch
directories(%w(lib spec))

## Uncomment to clear the screen before every task
# clearing :on

group :spec, halt_on_fail: true do
  guard :rspec, cmd: 'bundle exec rspec' do
    require 'guard/rspec/dsl'
    dsl = Guard::RSpec::Dsl.new(self)

    # Feel free to open issues for suggestions and improvements

    # RSpec files
    rspec = dsl.rspec
    watch(rspec.spec_helper) { rspec.spec_dir }
    watch(rspec.spec_support) { rspec.spec_dir }
    watch(rspec.spec_files)

    # Ruby files
    ruby = dsl.ruby
    dsl.watch_spec_files_for(ruby.lib_files)
  end

  guard :rubocop do
    watch(/.+\.rb$/)
    watch(/(?:.+\/)?\.rubocop(?:_todo)?\.yml$/) { |m| File.dirname(m[0]) }
  end
end
