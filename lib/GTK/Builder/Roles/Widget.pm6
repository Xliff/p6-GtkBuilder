my %attr-attribute-alias;

role WidgetRole       { }
role ParentWidgetRole { }

role GTK::Builder::Roles::Widget {

  method GTK::Raw::Definitions::Widget
  { self.parent-attribute.get_value(self) }

  method widget-attributes {
    self.^attributes.grep( * ~~ WidgetRole )
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

  # cw: Named such so as to NOT conflict with GTK, and we don't really
  #     want the parent object, but the parent attribute.
  method parent-attribute {
    state $p = self.^attributes.grep( * ~~ ParentWidgetRole )[0];
    $p;
  }
  method parent-class {
    self.parent-attribute.type
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

  $a but WidgetRole;
  $a but ParentWidgetRole;
}


sub getAttributeUIName ($n) is export {
  %attr-attribute-alias{$n}.defined ?? %attr-attribute-alias{$n} !! $n
}
