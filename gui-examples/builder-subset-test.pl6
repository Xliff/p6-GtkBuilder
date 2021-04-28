use GTK::Raw::Types;

use LibXML;

use GTK::Application;
use GTK::Builder;

my $app = GTK::Application.new( name => 'org.genex.builder-subset-test' );
my ($count, @windows) = 0;
sub add-new ($d) {
  my $name = $d.getAttribute('id');
  my $b    = GTK::Builder.new-from-string(qq:to/UIDEF/);
    <?xml version="1.0" encoding="UTF-8"?>
    <interface>
    { (~$d).sprintf($count) }
    </interface>
    UIDEF

  my $bc = $b{ my $ctrl-name = $name.sprintf($count++) };
  @windows.push($bc);
  $bc.name = $ctrl-name;
  $bc.show-all;
  $bc;
}

$app.activate.tap({
  my $def = LibXML.parse(
    location => "{ $*PROGRAM.dirname }/cursor-slot.ui"
  ).root.find('//*[@id="area"]')[0];

  # Must convert to "template" so that top-level ID can be assured unique.
  $def.setAttribute('id', 'area%s');

  my $css = GTK::CSSProvider.new( pod => $=pod );

  my $vbox   = GTK::Box.new-vbox;
  my $vbox-i = GTK::Box.new-vbox;
  $vbox-i.pack_start( add-new($def) );
  $vbox.pack-start($vbox-i, True, True);

  my $button = GTK::Button.new-with-label('Add Another One!');
  $button.clicked.tap({
    return unless +@windows < 10;
    $vbox-i.pack_start( add-new($def) );
  });
  $vbox.pack-end($button);

  $app.window.set-size-request(300, 800);
  $app.window.add($vbox);
  $app.window.show-all;
});

$app.run;

=begin css
#area0 { background: #7F1919; }
#area1 { background: #7F4C19; }
#area2 { background: #7F7F19; }
#area3 { background: #4C7F19; }
#area4 { background: #197F19; }
#area5 { background: #197F4C; }
#area6 { background: #197F7F; }
#area7 { background: #194C7F; }
#area8 { background: #19197F; }
#area9 { background: #4C197F; }
=end css
