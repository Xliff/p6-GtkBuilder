use v6.c;

use GTK::Builder::Subs;

use GTK::BuilderWidgets;

#use lib <t .>;
#use ui_to_code;
#use Grammar::Tracer;
#use Data::Dump::Tree;

grammar BuilderGrammar {
  rule TOP {
    '<?xml version="1.0" encoding="UTF-8"?>'
    <comment>?
    '<interface>' <pieces>+ '</interface>'
    <comment>?
  }
  rule pieces {
    <object> || <template> || <comment> || <requires>
  }
  rule comment {
    '<!--' .+ '-->'
  }
  rule requires {
    '<requires'  <attr>+ %% \s+ '/>'
  }
  rule object {
    '<object' <attr>+ %% \s+ '>'
    [
      <child>      |
      <property>   |
      <packing>    |
      <signal>     |
      <attributes> |
      <style>
    ]+
    '</object>'
  }
  rule template {
    '<template' <attr>+ %% \s+ '>'
    <child>*
    '</template>'
  }
  rule child {
    '<child'(\s+ <attr>+ %% \s+)?'>'
    [ <object> | <packing> | '<placeholder'\s*'/>' ]*
    '</child>'
    |
    '<child' <attr>+ %% \s+ '/>'
  }
  rule style {
    '<style>' '<class' <attr>'/>' '</style>'
  }
  rule attributes {
    '<attributes>' <attribute>+ '</attributes>'
  }
  rule attribute {
    '<attribute' <attr>+ %% \s+ '/>'
  }
  rule signal {
    '<signal' <attr>+ %% \s+ '/>'
  }
  rule packing {
    '<packing>' <property>+ '</packing>'
  }
  rule property {
    '<property' <attr>+ %% \s+ '>'<value>'</property>'
  }
  token attr {
    # Double or single quotes
    <name=ident>'="' $<val>=[ <-[\"]>+ ] '"'
  }
  token ident {
    <[A..Za..z0..9_\-\+\.]>+
  }
  token value {
    <[A..Za..z0..9_\:\-\.\,\@\/\=\&\;\"]+ :space>+
  }
}

class BuilderActions {
  method !buildAttr ($match) {
    my %attrs;
    return {} without $match || $match<attr>;
    %attrs.append($_.made) for $match<attr>.List;
    {
      name  => %attrs<name>,
      attrs => %attrs
    };
  }

  method TOP ($/) {
    my @items;
    for $/<pieces>.List {
      my $obj;
      my $item = do {
        when $_<object>.defined   { 'object'   }
        when $_<template>.defined { 'template' }
        default                   { 'WTF'      }
      }
      @items.push(%(
        objects => $_{$item}.made,
        #order  => $++
      ));
    }
    make @items;
  }

  method object ($/) {
    state %collider;

    my $attrs = self!buildAttr($/);
    my (%property, %packing, %attributes, %style, @children);
    for (%property, %packing, %attributes, %style) -> $hash {
      my $hname = $hash.name.substr(1);
      next unless $/{$hname}.defined;
      for $/{$hname}.List {
        my $s = $_.made;
        $hash.append($s.pairs);
      }
    }
    for $/<child>.List.grep( *<attrs><type>.defined.not ) {
      my $s = $_.made;
      @children.push($s)
    }

    my $class = $attrs<attrs><class>;
    make {
      class     => $class,
      id        => $attrs<attrs><id> // 'anon' ~ $class ~ %collider{$class}++,
      children  => @children.Array,
      props     => %property,
      packing   => %packing,
      attrs     => %attributes,
      style     => %style,
    };
  }

  # Is this right?
  method template ($/) {
    my $attrs = self!buildAttr($/);
    my @children;
    for $/<child>.List {
      my $c = $_.made;
      @children.push($_.made) if $c.defined && $c.elems;
    }
    make {
      class    => $attrs<attrs><parent>,
      id       => "template{$++}",
      children => @children.Array
    };
  }

  method child ($/) {
    my %attrs = self!buildAttr($/);
    my (%object, %packing);
    for (%object, %packing) -> $hash {
      my $hname = $hash.name.substr(1);
      next unless $/{$hname}.defined;
      $hash.append( .made.pairs ) for $/{$hname};
    }
    make {
      attributes => %attrs,
      objects    => %object,
      packing    => %packing
    };
  }

  method attributes ($/) {
    my %attrs = self!buildAttr($_) for $/<attribute>.List;
    make {
      %attrs<name> => %attrs<attrs><val>
    };
  }

  method packing ($/) {
    my %pack;
    %pack.append( .made.pairs ) for $/<property>.List;
    make %pack;
  }

  method property ($/) {
    my $attrs = self!buildAttr($/);
    my $extras = %( $attrs<attrs>.pairs.grep( *.key ne 'name' ) );
    if $extras.elems {
      make {
        $attrs<name> => {
          attrs => $extras,
          value => $/<value>.Str
        }
      };
    } else {
      make {
        $attrs<name> => $/<value>.Str;
      }
    }
  }

  method style ($/) {
    make {
      class => $/<attr>.made.value
    };
  }

  method attr ($/) {
    make $/<name>.Str => $/<val>.Str;
  }
}

sub MAIN($filename) {
  my $contents;
  if $filename ne '-' {
    die "Cannot find file '$filename'.\n" unless $filename.IO.e;
    $contents = $filename.IO.open.slurp;
  } else {
    $contents = slurp;
  }
  $contents = prepTemplate($contents, :serial);

  my $bw = GTK::BuilderWidgets.new(var => 'b');
  without $bw {
    say 'Cannot continue witout working GTK::BuilderWidgets instance!';
    exit;
  }

  my $p = BuilderGrammar.parse($contents, actions => BuilderActions);
  without $p {
    say 'Could not parse UI file!';
    exit;
  }

  say $bw.get-code-list($p.made).join("\n");
}
