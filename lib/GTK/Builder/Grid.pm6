use v6.c;

use GTK::Builder::Widget;

class GTK::Builder::Grid is GTK::Builder::Widget does GTK::Builder::Role {
  my @attributes = <
    baseline-row
    column-homogeneous
    column-spacing
    row-homogeneous
    row-spacing
  >;

  # multi method properties($v, $o) {
  #   my @c = self.properties($v, @attributes, $o, -> $prop is rw {
  #     given $prop {
  #       when @attributes.any {
  #         $prop ~~ s:g/ '-' / '_' /;
  #       }
  #     }
  #   });
  #
  #   @c;
  # }

  method populate($v, $o) {
    my @c;

    use Data::Dump::Tree;

    for $o<children>.List {
      my $attach = qq:to/ATTACH/.chomp;
{ sprintf($v, $o<id>) }.attach(
{ sprintf($v, $_<objects><id>) },
  { .<packing><left-attach> // .<packing><left_attach> // 0 },
  { .<packing><top-attach>  // .<packing><top_attach>  // 0 },
  { .<packing><width>       //                            1 },
  { .<packing><height>      //                            1 }
);
ATTACH

      $attach ~~ s:g/\r?\n//;
      @c.append: $attach;
    }
    @c;
  }

}
