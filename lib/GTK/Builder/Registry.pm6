use v6.c;

use GTK::TypeClass;

class GTK::Builder::Registry {

  # cw: For those long dead and deprecated type names, that you might find in
  #     .glade files for decades to come.
  method aliases {
    (
      'GtkVBox' => 'GTK::Box',
      'GtkHBox' => 'GTK::Box'
    ).Map
  }

  method typeClass {
    %typeClass.Map
  }

}
