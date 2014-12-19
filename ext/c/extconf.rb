require 'mkmf'

have_header('ruby.h')

# -Wno-unused-value is used due to the vec.h library emitting a bunch of
# warnings I can't do anything about (but they do annoy me).
$CFLAGS << ' -Wextra -Wall -pedantic -Wno-unused-value -std=c99'

if ENV['DEBUG']
  $CFLAGS << ' -O0 -g'
else
  $CFLAGS << ' -O3'
end

create_makefile('libll')
