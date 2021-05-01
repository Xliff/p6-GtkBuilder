use GTK::Raw::Types;

use LibXML;

use GTK::Application;
use GTK::Builder;

my $app = GTK::Application.new( name => 'org.genex.builder-subset-test' );
my ($count, @windows) = 0;
sub add-new ($d) {
  # my $name = $d.getAttribute('id');
  # my $b    = GTK::Builder.new-from-string(qq:to/UIDEF/);
    # <?xml version="1.0" encoding="UTF-8"?>
    # <interface>
    # { (~$d).sprintf($count) }
    # </interface>
    # UIDEF
  my $b    = GTK::Builder.new-from-string($d);

  my $bc = $b.top-level;
  @windows.push($bc);
  $bc.name = $b.top-level-id;
  $bc.no-show-all = False;
  $bc.show-all;
  $bc;
}

$app.activate.tap({
  my $def = GTK::Builder.templateToUI(
    "{ $*PROGRAM.dirname }/cursor-slot.ui".IO.slurp
  );

  my $css    = GTK::CSSProvider.new( pod => $=pod );
  my $vbox   = GTK::Box.new-vbox;
  my $vbox-i = GTK::Box.new-vbox;
  $vbox-i.pack_start( add-new($def) );
  $vbox.pack-start($vbox-i, True, True);

  my $button = GTK::Button.new-with-label('Add Another One!');
  $button.clicked.tap({
    if +@windows < 10 {
      $vbox-i.pack_start( add-new($def) );
    }
  });
  $vbox.pack-end($button);

  $app.window.set-size-request(300, 800);
  $app.window.add($vbox);
  $app.window.show-all;
});

$app.run;

=begin css
#CursorSlot0 { background: #7F1919; }
#CursorSlot1 { background: #7F4C19; }
#CursorSlot2 { background: #7F7F19; }
#CursorSlot3 { background: #4C7F19; }
#CursorSlot4 { background: #197F19; }
#CursorSlot5 { background: #197F4C; }
#CursorSlot6 { background: #197F7F; }
#CursorSlot7 { background: #194C7F; }
#CursorSlot8 { background: #19197F; }
#CursorSlot9 { background: #4C197F; }
=end css
