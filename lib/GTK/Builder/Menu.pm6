use v6.c;

use GTK::Builder::Widget;

class GTK::Builder::Menu is GTK::Builder::Widget does GTK::Builder::Role {

  method populate($v, $o) {
    my @c;
    @c.push: "{ sprintf($v, $o<id>) }.append({ sprintf($v, $_<id>) });"
      for $o<children>.map( *<objects> );
    @c;
  }

}
