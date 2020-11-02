use HarfBuzz;
use Test;
plan 2;

my $file := 't/fonts/NimbusRoman-Regular.otf';
my $size := 36;
my $text := 'LVAT';
my HarfBuzz $hb .= new: :$file, :$size, :$text;
my @info = $hb.shaper;
my @expected = [
  { ax => 17.86, ay => 0.0, dx => 0.0, dy => 0.0, g => 45, name => 'L' },
  { ax => 21.67, ay => 0.0, dx => 0.0, dy => 0.0, g => 55, name => 'V' },
  { ax => 24.05, ay => 0.0, dx => 0.0, dy => 0.0, g => 34, name => 'A' },
  { ax => 22.00, ay => 0.0, dx => 0.0, dy => 0.0, g => 53, name => 'T' },
];

if HarfBuzz.version < v2.6.6 {
    # name not available in older HarfBuzz versions
    .<name>:delete for flat @expected, @info;
}
is-deeply @info, @expected, "content default kern";

$hb .= new: :$file, :$size, :$text, :features[ '-kern' ];
@info = $hb.shaper;

@expected = [
  { ax => 22.00, ay => 0.0, dx => 0.0, dy => 0.0, g => 45, name => 'L' },
  { ax => 25.99, ay => 0.0, dx => 0.0, dy => 0.0, g => 55, name => 'V' },
  { ax => 25.99, ay => 0.0, dx => 0.0, dy => 0.0, g => 34, name => 'A' },
  { ax => 22.00, ay => 0.0, dx => 0.0, dy => 0.0, g => 53, name => 'T' },
];

if HarfBuzz.version < v2.6.6 {
    # name not available in older HarfBuzz versions
    .<name>:delete for flat @expected, @info;
}
is-deeply @info, @expected, "content default kern";