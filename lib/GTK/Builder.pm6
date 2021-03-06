use v6.c;

use Method::Also;
use NativeCall;

use LibXML;
use Data::Dump::Tree;

use GLib::GSList;

use GTK::Raw::Builder;
use GTK::Raw::Types;
use GTK::Raw::Subs;

use GTK;
use GIO::Menu;
use GTK::Adjustment;
use GTK::Application;
use GTK::CSSProvider;
use GTK::Widget;
use GTK::Window;
use GTK::Builder::Subs;
use GTK::Builder::Registry;

use GLib::Roles::Object;

# cw: WHOOPS! Looks like I had already started this. See .register class method!!

role Origin {
  has Str $!origin;

  method origin {
    $!origin
  }

  method setOrigin ($o) {
    $!origin = $o;
  }
}

class GTK::Builder does Associative {
  also does GLib::Roles::Object;

  my (@prefixes, %aliases, %typeClasses, %namespaces);

  has GtkBuilder $!b is implementor;
  has GtkWindow $.window;
  has %!types;
  has $!css;
  has $!top-level;

  has %!widgets handles <
    EXISTS-KEY
    elems
    keys
    values
    pairs
    antipairs
    kv
    sort
  >;

  submethod BUILD(
    :$builder!,
    :$identity,
    :$pod,
    :$ui,
    :$window-name,
    :$style
  ) {
    self!setObject($!b = $builder);             # GTK::Roles::Compat::Object

    # cw: This code is unused. Excise it once stable.
    @prefixes = ('Gtk');

    GTK::Builder.register(GTK::Builder::Registry)
      unless %namespaces<GTK::Builder::Registry>:exists;

    my %sections;
    my ($ui-data, $style-data);
    if $pod {
      for $pod.grep( *.name eq <css ui>.any ).Array {
        # This may not always be true. Keep up with POD spec!
        %sections{ .name } //= $_.contents.map( *.contents[0] ).join("\n");
        last with %sections<ui> && %sections<css>;
      }
      $ui-data    = %sections<ui>;
      $style-data = %sections<css>;
    } else {
       $ui-data    = $ui         if $ui;
       $style-data = $style-data if $style;
    }
    $!css = GTK::CSSProvider.new(style => $style-data) if $style-data;

    if $ui-data {
      self.add_from_string($ui-data);
      $!window = GTK::Window.new( self.get_object($window-name) )
        if $window-name;

# ONLY DO THIS IF BUILDER IS NOT ACTING AS A TEMPLATE!
#
#       die qq:to/ERR/ unless $!window;
# Application window '#application' was not found. Please do one of the following:
#    - Rename the top-level window to 'application' in the .ui file
#    OR
#    - Specify the name of the top-level window using the named parameter
#      :\$window-name in the constructor to GTK::Application
# ERR
    }

    # If using the identity constructor, we must populate %!widgets
    if $identity {
      %!widgets{ .name } = $_ for self.get_objects;
    }

  }

  method GTK::Raw::Definitions::GtkBuilder
    is also<
      GtkBuilder
      Builder
    >
  { $!b }

  multi method new (GtkBuilder $builder, :$ref = True) {
    return Nil unless $builder;

    my $o = self.bless(:$builder, :identity);
    $o.ref if $ref;
    $o;
  }
  multi method new (
    :$pod,
    :$ui,
    :$window-name,
    :$style
  ) {
    my $builder = gtk_builder_new();

    $builder ?? self.bless(:$builder, :$pod, :$ui, :$window-name, :$style)
             !! Nil;
  }

  method new_from_file (Str() $filename) is also<new-from-file> {
    my $builder = gtk_builder_new_from_file($filename);
    my $ui = $filename.IO.slurp;

    $builder ?? self.bless(:$builder, :$ui) !! Nil;
  }

  method new_from_resource (Str() $resource) is also<new-from-resource> {
    my $builder = gtk_builder_new_from_resource($resource);

    # XXX - Get resource data and place into $ui
    $builder ?? self.bless(:$builder) !! Nil;
  }

  method new_from_string (
    Str() $ui       is copy,
    Int() $length   =  -1,
          :$process =  True
  )
    is also<new-from-string>
  {
    # cw: Consider parsing this using a proper XML parser so
    #     we can use a subset of the passed XML.

    die '$length must not be negative' unless $length > -2;
    my gssize $l = $length;
    my        $builder = gtk_builder_new_from_string($ui, $l);

    $builder ?? self.bless(:$builder, :$ui) !! Nil;
  }

  #  new-from-buf??

  method register (GTK::Builder:U: *@registries) {
    for @registries -> \t {
      if t.^lookup('aliases') -> $r {
        for $r(t).pairs {
          if .key eq 'PREFIX' {
            @prefixes.push: .value;
            next;
          }
          if %aliases{ .key }:exists {
            say qq:to/M/.chomp;
              { .key } already registered for { %aliases{ .key }
              }, skipping...
              M
          } else {
            # cw: I could be convinced to let %aliases go...
            %aliases{ .key } = .value;
            ( %typeClasses{ .key } = (.value but Origin) ).setOrigin(t.^name);
          }
        }
      }

      if t.^lookup('typeClass') -> $m {
        my $ns-name = t.^name;
        for $m(t).pairs {
          if %typeClasses{ .key } -> $ke {
            say "Type { $ke } already set by package { $ke.origin }";
          } else {
            ( %typeClasses{ .key } = (.value but Origin)).setOrigin($ns-name);
          }
        }
        %namespaces{$ns-name} = True;
      }
    }
  }

  method templateToUI (
    GTK::Builder:U:

    $template,
    :$url          = False,
    :&dom-callback = Callable
  ) {
    my %opts;

    %opts<url>          = $url;
    %opts<dom-callback> = &dom-callback;
    prepTemplate(%$template, |%opts, :serial);
  }

  method AT-KEY(Str $key) {
    die "Requested control '$key' does not exist."
      unless  %!widgets{$key}:exists;
    %!widgets{$key};
  }

  # ???????????? SIGNALS ????????????
  # ???????????? SIGNALS ????????????

  method !getTypes (
    :$ui_def,
    :$file,
    :$resource
  ) {
    my %parent-types := %!types;

    {
      with $file     { }
      with $resource { }
      with $ui_def   {
        my $dom = LibXML.parse(string => $ui_def).root;

        my $firstLoop = True;
        for $dom.find('//object | //menu') {
          my ($id, $args, $type) = ( .getAttribute('id') );

          if $firstLoop {
            $!top-level = $id;
            $firstLoop = False;
          }

          unless .name eq 'menu' {
            $type = do given .getAttribute('class') {
              when 'GtkAdjustment' {
                $args = ['cast', GtkAdjustment];
                proceed;
              }

              default {
                %typeClasses{$_}
              }
            }
          }
          %parent-types{$id} = [ $type, $args ] if $id;
        }

      }
    }
  }

  method !postProcess(
    :$ui_def,
    :$file,
    :$resource
  ) {
    my $args;

    self!getTypes(:$ui_def, :$file, :$resource);
    for %!types.keys -> $k {
      CONTROL {
        when     CX::Warn { .message.say; .backtrace.concise.say; .resume }
        default           { .rethrow }
      }

      my $o = self.get_object($k);

      given %!types{$k}[1][0] {
        when 'cast' {
          $o = nativecast(%!types{$k}[1][1], $o);
        }
        when 'option' {
          $args = %!types{$k}[1][1];
        }
      }
      # Use type names to dynamically create objects.
      # Use $args to pass along additional arguments.
      %!widgets{$k} = do {
        my $wt = %!types{$k}[0];
        my $at = %aliases{$wt} // $wt;

        CATCH {
          default {
           say qq:to/D/.chomp;
              Error encountered when processing { $k } ({ $at }): { .message }
              D

            exit;
          }
        }

        when $args.defined {
           # After significant review, I don't think there will be many
           # uses of this when case, since much of this work is already done
           # by GtkBuilder. The only situations I see this handling are P6-state
           # related issues, like container storage situations.
          ::( $at ).new($o, $args.pairs);
        }

        default {
          CATCH {
            default { note($_) }
          }
          say "Requiring { $at }..." if ::( $at ) ~~ Failure;
          require ::($ = $at);
          ::($ = $at).new($o);
        }
      }

    }

    # cw: Duplication of work?
    #
    # cw: -XXX- In case the object representation is lost, widget data
    #     should be assigned to the pointer's qData so it can be recovered,
    #     later.
    # self.set-data(
    #   "widget-{ $_ }:{ %!widgets{$_}.objectType.name }",
    #   %!widgets{$_}.GtkWidget.p
    # );

    #ddt %!widgets;
  }

  # cw: Get top-level control?
  method top-level-id { $!top-level }
  method top-level    { self.AT-KEY($!top-level) }

  # ???????????? ATTRIBUTES ????????????
  method application (:$raw = False) is rw {
    Proxy.new(
      FETCH => sub ($) {
        my $app = gtk_builder_get_application($!b);

        $app ??
          ( $raw ?? $app !! GTK::Application.new($app) )
          !!
          Nil;
      },
      STORE => sub ($, GtkApplication() $application is copy) {
        gtk_builder_set_application($!b, $application);
      }
    );
  }

  method translation_domain is rw is also<translation-domain> {
    Proxy.new(
      FETCH => sub ($) {
        gtk_builder_get_translation_domain($!b);
      },
      STORE => sub ($, Str() $domain is copy) {
        gtk_builder_set_translation_domain($!b, $domain);
      }
    );
  }
  # ???????????? ATTRIBUTES ????????????

  # ???????????? METHODS ????????????
  method add_callback_symbol (
    Str() $callback_name,
    &callback_symbol
  )
    is also<add-callback-symbol>
  {
    gtk_builder_add_callback_symbol($!b, $callback_name, &callback_symbol);
  }

  # YYY - Return type?
  method add_from_file (
    Str() $filename,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<add-from-file>
  {
    clear_error;
    gtk_builder_add_from_file($!b, $filename, $error);
    set_error($error);
    self!postProcess(:file($filename));
  }

  # YYY - Return type?
  method add_from_resource (
    Str() $resource_path,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<add-from-resource>
  {
    clear_error;
    gtk_builder_add_from_resource($!b, $resource_path, $error);
    set_error($error);
    self!postProcess(:resource($resource_path));
  }

  # YYY - Return type?
  method add_from_string (
    Str() $buffer,
    $length?,
    CArray[Pointer[GError]] $error? #= gerror
  )
    is also<add-from-string>
  {
    my $len = $length // -1;
    die '$length cannot be negative' unless $len > -2;

    my $err = $error // gerror;
    die '$error must be a GError object or pointer' unless $error ~~ CArray;

    clear_error;
    my $rc = gtk_builder_add_from_string($!b, $buffer, $len, $err);
    self!postProcess( ui_def => $buffer );
    set_error($error);
    $rc;
  }

  # YYY - Return type?
  method add_objects_from_file (
    Str() $filename,
    @object_ids,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<add-objects-from-file>
  {
    die '@objects must be a list of strings'unless @object_ids.all ~~ Str;
    my $oi = CArray[Str].new;
    my $i = 0;

    $oi[$i++] = $_ for @object_ids;
    clear_error;
    gtk_builder_add_objects_from_file($!b, $filename, $oi, $error);
    set_error($error);
    #self!postHandle;
  }

  # YYY - Return type?
  method add_objects_from_resource (
    Str() $resource_path,
    @object_ids,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<add-objects-from-resource>
  {
    die '@objects must be a list of strings'unless @object_ids.all ~~ Str;
    my $oi = CArray[Str].new;
    my $i = 0;

    $oi[$i++] = $_ for @object_ids;
    clear_error;
    gtk_builder_add_objects_from_resource($!b, $resource_path, $oi, $error);
    set_error($error);
    #self!postProcess;
  }

  proto method add_objects_from_string(|)
    is also<add-objects-from-string>
    { * }

  # YYY - Return type?
  multi method add_objects_from_string (
    Str() $buffer,
    @object_ids = ()
  ) {
    samewith($buffer, -1, @object_ids);
  }
  multi method add_objects_from_string (
    Str() $buffer,
    Int() $length,
    @object_ids,
    CArray[Pointer[GError]] $error = gerror
  ) {
    die '@objects must be a list of strings'
      unless @object_ids.elems.not || @object_ids.all ~~ Str;
    #die '$length cannot be negative' unless $length > -2;

    my gsize $l = $length;
    my $oi = CArray[Str].new;
    my $i = 0;

    $oi[$i++] = $_ for @object_ids;
    clear_error;
    my $rc = gtk_builder_add_objects_from_string(
      $!b,
      $buffer,
      $length,
      $oi,
      $error
    );
    set_error($error);
    self!postProcess( ui_def => $buffer );
    $rc;
  }

  method connect_signals (gpointer $user_data = gpointer)
    is also<connect-signals>
  {
    gtk_builder_connect_signals($!b, $user_data);
  }

  method connect_signals_full (
    GtkBuilderConnectFunc $func,
    gpointer $user_data
  )
    is also<connect-signals-full>
  {
    gtk_builder_connect_signals_full($!b, $func, $user_data);
  }

  method error_quark is also<error-quark> {
    gtk_builder_error_quark();
  }

  method expose_object (Str() $name, GObject() $object)
    is also<expose-object>
  {
    gtk_builder_expose_object($!b, $name, $object);
  }

  # YYY - Return type?
  method extend_with_template (
    GtkWidget()             $widget,
    Int()                   $template_type,
    Str()                   $buffer,
    Int()                   $length,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<extend-with-template>
  {
    die '$length cannot be negative' unless $length > -2;
    my gsize $l = $length;
    clear_error;
    gtk_builder_extend_with_template(
      $!b, $widget, $template_type, $buffer, $l, $error
    );
    set_error($error);
    self!postProcess;
  }

  method get_object (Str() $name) is also<get-object> {
    my $o = gtk_builder_get_object($!b, $name);

    $o === GtkWidget ?? Nil !! $o;
  }

  method get_objects (
    :$glist  = False,
    :$raw    = False,
    :$object = False,
    :$widget = False
  )
    is also<get-objects>
  {
    die 'Cannot use $object and $widget in the same call!'
      unless $object ^^ $widget;

    my $ol = gtk_builder_get_objects($!b);

    return Nil unless $ol;
    return $ol if $glist;

    $ol = $object ?? GLib::GList.new($ol) but GLib::Roles::ListData[GObject]
                  !! GLib::GList.new($ol) but GLib::Roles::ListData[GtkWidget];

    $raw ?? $ol.Array
         !! $ol.Array.map({
              $object ?? GLib::Roles::Object.new-object-obj($_)
                      !! ( $widget ?? GTK::Widget.new($_)
                                   !! GTK::Widget.CreateObject.new($_) )
            });
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &gtk_builder_get_type, $n, $t );
  }

  method get_type_from_name (Str() $type_name)
    is also<get-type-from-name>
  {
    gtk_builder_get_type_from_name($!b, $type_name);
  }

  method lookup_callback_symbol (Str() $callback_name)
    is also<lookup-callback-symbol>
  {
    gtk_builder_lookup_callback_symbol($!b, $callback_name);
  }

  # YYY - Return type?
  method value_from_string (
    GParamSpec              $pspec,
    Str()                   $string,
    GValue()                $value,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<value-from-string>
  {
    clear_error;
    gtk_builder_value_from_string($!b, $pspec, $string, $value, $error);
    set_error($error);
  }

  # YYY - Return type?
  method value_from_string_type (
    Int()                   $type,
    Str()                   $string,
    GValue()                $value,
    CArray[Pointer[GError]] $error   = gerror
  )
    is also<value-from-string-type>
  {
    my GType $t = $type;

    clear_error;
    gtk_builder_value_from_string_type($!b, $t, $string, $value, $error);
    set_error($error);
  }

  # ???????????? METHODS ????????????

}
