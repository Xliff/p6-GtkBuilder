use v6.c;

use GTK::Builder::Widget;

class GTK::Builder::ToggleButton is GTK::Builder::Widget does GTK::Builder::Role {
  my @attributes = <
    active
    draw-indicator
    inconsistent
  >;

  multi method properties($v, $o) {
    my @c = self.properties($v, @attributes, $o);
    @c;
  }
}
