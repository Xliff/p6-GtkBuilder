use v6.c;

use Method::Also;

use GTK::Raw::Types;

my %attr-attribute-alias;

role WidgetRole       { }
role ParentWidgetRole { }

role GTK::Builder::Roles::Widget {

  method GTK::Raw::Definitions::GtkWidget
    is also<GtkWidget>
  { ::?CLASS.parent-attribute.get_value(self).GtkWidget }

  method widget-attributes {
    ::?CLASS.^attributes.grep( * ~~ WidgetRole )
  }

  method builder-name {
    state %anti-attr-attribute-name;

    INIT {
      my %aliases = %attr-attribute-alias.antipairs.Hash;
      %anti-attr-attribute-name{ $_ } = %aliases{$_} // $_
        for %attr-attribute-alias.keys;
    }

    %anti-attr-attribute-name.Map
  }

  proto method assign-attributes (|)
  { * }

  multi method assign-attributes ($builder is copy) {
    my \T = ::('GTK::Builder');

    say "T:{ T.^name } / { T.WHERE }";
    say "B:{ $builder.^name } / { $builder.WHAT.WHERE }";

    $builder = T.new($builder) if $builder ~~ GtkBuilder;
    # cw: Have to get creative, here!
    die '.assign-attributes only accepts GTK::Builder-compatible arguments'
      unless $builder.get_type == T.get_type;

    # cw: -XXX- Need to set attributes. Leverage use of attribute names and
    #     traits like builder-name.
    for self.^attributes {
      next unless $_ ~~ WidgetRole;

      my $name = .name.substr(2);
      if $builder{ %attr-attribute-alias{$name} // $name } -> $v {
        .set_value(self, $v);
      } else {
        warn "No widget value found for control '$name'";
      }
    }
  }

  # cw: Named such so as to NOT conflict with GTK, and we don't really
  #     want the parent object, but the parent attribute.
  method parent-attribute {
    state $p = ::?CLASS.^attributes.grep( * ~~ ParentWidgetRole )[0];
    $p;
  }
  method parent-class {
    ::?CLASS.parent-attribute
  }

}

multi sub trait_mod:<is> (Attribute $a, :$widget is required)
  is export
{
  $a but WidgetRole;
}

multi sub trait_mod:<is> (Attribute $a, :$builder-name is required)
  is export
{
  %attr-attribute-alias{ $a.name.substr(2) } =
    $builder-name ~~ Positional ?? $builder-name[0] !! $builder-name
}

multi sub trait_mod:<is> (Attribute $a, :$parent-widget is required)
  is export
{
  state %classes;

  die 'Can only have one parent widget per class!'
    unless ++%classes{ $a.package.^name } < 2;

  $a does WidgetRole;
  $a does ParentWidgetRole;
}


sub getAttributeUIName ($n) is export {
  %attr-attribute-alias{$n}.defined ?? %attr-attribute-alias{$n} !! $n
}
