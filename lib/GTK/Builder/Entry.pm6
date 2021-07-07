use v6.c;

use GTK::Raw::Enums;

use GTK::Builder::Widget;

class GTK::Builder::Entry is GTK::Builder::Widget does GTK::Builder::Role {
  my @attributes = <
    activates_default               activates-default
    alignment
    attributes
    buffer
    completion
    cursor_position                 cursor-position
    cursor_hadjustment              cursor-hadjustment
    editable
    enable_emoji_completion         enable-emoji-completion
    has_frame                       has-frame
    im_module                       im-module
    inner_border                    inner-border
    input_hints                     input-hints
    input_purpose                   input-purpose
    invisible_char                  invisible-char
    invisible_char_set              invisible-char-set
    max_length                      max-length
    max_width_chars                 max-width-chars
    overwrite_mode                  overwrite-mode
    placeholder_text                placeholder-text
    populate_all                    populate-all
    position
    primary_icon_activatable        primary-icon-activatable
    primary_icon_name               primary-icon-name
    primary_icon_pixbuf             primary-icon-pixbuf
    primary_icon_sensitive          primary-icon-sensitive
    primary_icon_stock              primary-icon-stock
    primary_icon_storage_type       primary-icon-storage-type
    primary_icon_tooltip_markup     primary-icon-tooltip-markup
    primary_icon_tooltip_text       primary-icon-tooltip-text
    progress_fraction               progress-fraction
    progress_pulse_step             progress-pulse-step
    scroll_offset                   scroll-offset
    secondary_icon_activatable      secondary-icon-activatable
    secondary_icon_name             secondary-icon-name
    secondary_icon_pixbuf           secondary-icon-pixbuf
    secondary_icon_sensitive        secondary-icon-sensitive
    secondary_icon_stock            secondary-icon-stock
    secondary_icon_storage_type     secondary-icon-storage-type
    secondary_icon_tooltip_markup   secondary-icon-tooltip-markup
    secondary_icon_tooltip_text     secondary-icon-tooltip-text
    selection_bound                 selection-bound
    shadow_type                     shadow-types
    show_emoji_icon                 show-emoji-icon
    tabs
    text
    text_length                     text-length
    truncate_multiline              truncate-multiline
    visibility
    width_chars                     width-chars
    xalign
  >;

  multi method properties($v, $o) {
    my @c = self.properties($v, @attributes, $o, -> $_ is rw {

      # Per property special cases
      when 'shadow_type' | 'shadow-type' {
        my $prop = $_;
        $prop .= subst('-', '_', :g) if $prop.contains('-');

        $o<props>{$prop} = do given $o<props>{$prop} {
          when 'etched-in'  { GTK_SHADOW_ETCHED_IN  }
          when 'etched-out' { GTK_SHADOW_ETCHED_OUT }
          when 'none'       { GTK_SHADOW_NONE       }
          when 'out'        { GTK_SHADOW_OUT        }
          when 'in'         { GTK_SHADOW_IN         }
        }

        # Delete dashed version
        $o<props><shadow-type>:delete;
      }

      when 'primary_icon_storage_type'   | 'primary-icon-storage-type'   |
           'secondary_icon_storage_type' | 'secondary-icon-storage-type'
      {
        my $prop = $_;
        $prop .= subst('-', '_', :g) if $prop.contains('-');

        $o<props>{$prop} = do given $o<props>{$prop} {
          when 'icon-set'  { GTK_IMAGE_ICON_SET }
          when 'animation' { GTK_IMAGE_ANIMATION }
          when 'empty'     { GTK_IMAGE_EMPTY }
          when 'pixbuf'    { GTK_IMAGE_PIXBUF }
          when 'stock'     { GTK_IMAGE_STOCK }
          when 'icon-name' { GTK_IMAGE_ICON_NAME }
          when 'gicon'     { GTK_IMAGE_GICON }
          when 'surface'   { GTK_IMAGE_SURFACE }
        }

        # Delete dashed version
        $o<props><primary-icon-storage-type secondary-icon-storage-type>:delete;
      }

      when 'input_hints'   | 'input-hints' {
        my $prop = $_;
        $prop .= subst('-', '_', :g) if $prop.contains('-');

        $o<props>{$prop} = do given $o<props>{$prop} {
          when 'spellcheck'          { GTK_INPUT_HINT_SPELLCHECK }
          when 'inhibit-osk'         { GTK_INPUT_HINT_INHIBIT_OSK }
          when 'no-spellcheck'       { GTK_INPUT_HINT_NO_SPELLCHECK }
          when 'uppercase-sentences' { GTK_INPUT_HINT_UPPERCASE_SENTENCES }
          when 'uppercase-words'     { GTK_INPUT_HINT_UPPERCASE_WORDS }
          when 'none'                { GTK_INPUT_HINT_NONE }
          when 'vertical-writing'    { GTK_INPUT_HINT_VERTICAL_WRITING }
          when 'no-emoji'            { GTK_INPUT_HINT_NO_EMOJI }
          when 'emoji'               { GTK_INPUT_HINT_EMOJI }
          when 'word-completion'     { GTK_INPUT_HINT_WORD_COMPLETION }
          when 'uppercase-chars'     { GTK_INPUT_HINT_UPPERCASE_CHARS }
          when 'lowercase'           { GTK_INPUT_HINT_LOWERCASE }
        }

        $o<props><input-hints>:delete;
      }

      when 'input_purpose' | 'input-purpose' {
        my $prop = $_;
        $prop .= subst('-', '_', :g) if $prop.contains('-');

        $o<props>{$prop} = do given $o<props>{$prop} {
          when 'name'      { GTK_INPUT_PURPOSE_NAME }
          when 'free-form' { GTK_INPUT_PURPOSE_FREE_FORM }
          when 'email'     { GTK_INPUT_PURPOSE_EMAIL }
          when 'alpha'     { GTK_INPUT_PURPOSE_ALPHA }
          when 'url'       { GTK_INPUT_PURPOSE_URL }
          when 'number'    { GTK_INPUT_PURPOSE_NUMBER }
          when 'password'  { GTK_INPUT_PURPOSE_PASSWORD }
          when 'pin'       { GTK_INPUT_PURPOSE_PIN }
          when 'phone'     { GTK_INPUT_PURPOSE_PHONE }
          when 'digits'    { GTK_INPUT_PURPOSE_DIGITS }
        }

        $o<props><input-purpose>:delete;
      }

      when 'text' {
        # Capture attrs for later use
        $o<props><text-attrs> = $o<props><text><attrs>;
        my $t = $o<props><text>:delete;

        $o<props><text> = '"' ~ $t<value> ~ '"';
      }

    });

    @c;
  }

}
