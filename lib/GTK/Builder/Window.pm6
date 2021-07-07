use v6.c;

use GTK::Builder::Widget;

class GTK::Builder::Window is GTK::Builder::Widget does GTK::Builder::Role {
  my @attributes = <
    accept_focus                    accept-focus
    application
    attached_to                     attached-to
    decorated
    deletable
    destroy_with_parent             focus_on_map
    focus
    focus_on_map                    focus-on-map
    focus_visible                   focus-visible
    gravity
    has_resize_grip                 has-resize-grip
    hide_titlebar_when_maximized    hide-titlebar-when-maximized
    icon
    icon_list                       icon-name
    icon_name                       icon-name
    mnemonic_modifier               mnemonic-modifier
    mnemonics_visible               mnemonics-visible
    modal
    resizable
    role
    screen
    skip_pager_hint                 skip-pager-hint
    skip_taskbar_hint               skip-taskbar-hint
    startup_id                      startup-id
    title
    titlebar
    transient_for                   transient-for
    type_hint                       type-hint
    urgency_hint                    urgency-hint
    window_position                 window-position
  >;

  multi method properties($v, $o) {
    my @c = self.properties($v, @attributes, $o, -> $_ is rw {

      # Per property special cases
      when 'gravity' {
        $o<props><gravity> = do given $o<props><gravity> {
          when 'north-west'                  { 'GDK_GRAVITY_NORTH_WEST' }
          when 'north'                       { 'GDK_GRAVITY_NORTH'      }
          when 'north-east'                  { 'GDK_GRAVITY_NORTH_EAST' }
          when 'west'                        { 'GDK_GRAVITY_WEST'       }
          when 'center'                      { 'GDK_GRAVITY_CENTER'     }
          when 'east'                        { 'GDK_GRAVITY_EAST'       }
          when 'south-west'                  { 'GDK_GRAVITY_SOUTH_WEST' }
          when 'south'                       { 'GDK_GRAVITY_SOUTH'      }
          when 'south-east'                  { 'GDK_GRAVITY_SOUTH_EAST' }
          when .starts-with('GTK_GRAVITY_')  { $_ }
        }
      }

    });

    @c;
  }

}
