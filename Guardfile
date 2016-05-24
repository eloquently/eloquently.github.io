# A sample Guardfile
# More info at https://github.com/guard/guard#readme

## Uncomment and set this to only include directories you want to watch
# directories %w(app lib config test spec features) \
#  .select{|d| Dir.exists?(d) ? d : UI.warning("Directory #{d} does not exist")}

## Note: if you are using the `directories` clause above and you are not
## watching the project directory ('.'), then you will want to move
## the Guardfile to a watched dir and symlink it back, e.g.
#
#  $ mkdir config
#  $ mv Guardfile config/
#  $ ln -s config/Guardfile .
#
# and, you'll have to watch "config/Guardfile" instead of "Guardfile"

guard 'livereload' do
    watch(%r{_site/.+\.html})
    watch(%r{_site/css/.+})
    watch(%r{_site/img/.+})
    watch(%r{_site/js/.+})


    watch(%r{_serve/.+\.html})
    watch(%r{_serve/css/.+})
    watch(%r{_serve/img/.+})
    watch(%r{_serve/js/.+})
end