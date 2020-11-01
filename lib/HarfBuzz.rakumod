unit class HarfBuzz:ver<0.0.1>;

use HarfBuzz::Blob;
use HarfBuzz::Buffer;
use HarfBuzz::Face;
use HarfBuzz::Font;
use HarfBuzz::Raw;
use NativeCall;
use CStruct::Packing;

has Str:D $.file is required;
has HarfBuzz::Buffer $!buf handles<length>;
has HarfBuzz::Font $!font handles<face size scale>;

method glyphs {
    class Iteration does Iterable does Iterator {
        has UInt $.idx = 0;
        has HarfBuzz::Buffer:D $.buf is required;
        has HarfBuzz::Font:D $.font is required handles<size scale>;
        has hb_glyph_position $!Pos = $!buf.raw.get-glyph-positions(0);
        has hb_glyph_info     $!Info = $!buf.raw.get-glyph-infos(0);
        method iterator { self }
        method pull-one {
            if $!idx < $!buf.length {
                my hb_glyph_position:D $pos = $!Pos[$!idx];
                my hb_glyph_info:D $info = $!Info[$!idx];
                $!idx++;
                my @vec = @.scale.map: $.size / *;
                my Str:D $name = $!font.glyph-name($info.codepoint);
                HarfBuzz::Glyph.new: :$pos, :$info, :$name, :$!buf, :@vec;
            }
            else {
                IterationEnd;
            }
        }
    }
    Iteration.new: :$!buf, :$!font;
}

method version {
    hb_version(my uint32 $major, my uint32 $minor, my uint32 $micro);
    Version.new: [$major, $minor, $micro];
}

submethod TWEAK( :@scale = [1000, 1000], Numeric :$size, Str :$text) {
    my HarfBuzz::Face:D $face .= new: :$!file;
    $!font .= new: :$face, :@scale;
    $!font.size = $_ with $size;
    $!buf .= new;
    $!buf.add-text($_) with $text;
    $!buf.guess-segment-properties();
    $!font.shape: :$!buf;
}
