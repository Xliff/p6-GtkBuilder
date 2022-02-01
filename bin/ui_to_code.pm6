use v6.c;

unit package ui_to_code;

our $ui-template is export = q:to/TEMPLATE/;
<?xml version="1.0" encoding="UTF-8"?>
<interface>
  <object class="GtkMenu" id="menu1">
    <child>
      <object class="GtkMenuItem" id="menuitem1">
        <property name="label" translatable="yes">Email message</property>
        <property name="use-underline">1</property>
      </object>
    </child>
    <child>
      <object class="GtkMenuItem" id="menuitem2">
        <property name="label" translatable="yes">Embed message</property>
        <property name="use-underline">1</property>
      </object>
    </child>
  </object>
  <template class="GtkMessageRow" parent="GtkListBoxRow">
    <child>
      <object class="GtkGrid" id="grid1">
        <property name="hexpand">1</property>
        <child>
          <object class="GtkImage" id="avatar_image">
            <property name="width-request">32</property>
            <property name="height-request">32</property>
            <property name="halign">center</property>
            <property name="valign">start</property>
            <property name="margin-top">8</property>
            <property name="margin-bottom">8</property>
            <property name="margin-start">8</property>
            <property name="margin-end">8</property>
            <property name="icon-name">image-missing</property>
          </object>
          <packing>
            <property name="left-attach">0</property>
            <property name="top-attach">0</property>
            <property name="height">5</property>
          </packing>
        </child>
        <child>
          <object class="GtkBox" id="box1">
            <property name="hexpand">1</property>
            <property name="baseline-position">top</property>
            <child>
              <object class="GtkButton" id="button2">
                <property name="can-focus">1</property>
                <property name="receives-default">1</property>
                <property name="valign">baseline</property>
                <property name="relief">none</property>
                <child>
                  <object class="GtkLabel" id="source_name">
                    <property name="valign">baseline</property>
                    <property name="label" translatable="0">Username</property>
                    <attributes>
                      <attribute name="weight" value="bold"/>
                    </attributes>
                  </object>
                </child>
              </object>
            </child>
            <child>
              <object class="GtkLabel" id="source_nick">
                <property name="valign">baseline</property>
                <property name="label" translatable="0">@nick</property>
                <style>
                  <class name="dim-label"/>
                </style>
              </object>
              <packing>
                <property name="position">1</property>
              </packing>
            </child>
            <child>
              <object class="GtkLabel" id="short_time_label">
                <property name="valign">baseline</property>
                <property name="label" translatable="yes">38m</property>
                <style>
                  <class name="dim-label"/>
                </style>
              </object>
              <packing>
                <property name="pack-type">end</property>
                <property name="position">2</property>
              </packing>
            </child>
          </object>
          <packing>
            <property name="left-attach">1</property>
            <property name="top-attach">0</property>
          </packing>
        </child>
        <child>
          <object class="GtkLabel" id="content_label">
            <property name="halign">start</property>
            <property name="valign">start</property>
            <property name="xalign">0</property>
            <property name="yalign">0</property>
            <property name="label" translatable="0">Message</property>
            <property name="wrap">1</property>
          </object>
          <packing>
            <property name="left-attach">1</property>
            <property name="top-attach">1</property>
          </packing>
        </child>
        <child>
          <object class="GtkBox" id="resent_box">
            <child>
              <object class="GtkImage" id="image2">
                <property name="icon-name">media-playlist-repeat</property>
              </object>
            </child>
            <child>
              <object class="GtkLabel" id="label4">
                <property name="label" translatable="yes">Resent by</property>
              </object>
              <packing>
                <property name="position">1</property>
              </packing>
            </child>
            <child>
              <object class="GtkLinkButton" id="resent_by_button">
                <property name="label" translatable="0">reshareer</property>
                <property name="can-focus">1</property>
                <property name="receives-default">1</property>
                <property name="relief">none</property>
                <property name="uri">http://www.gtk.org</property>
              </object>
              <packing>
                <property name="position">2</property>
              </packing>
            </child>
          </object>
          <packing>
            <property name="left-attach">1</property>
            <property name="top-attach">2</property>
          </packing>
        </child>
        <child>
          <object class="GtkBox" id="box3">
            <property name="spacing">6</property>
            <child>
              <object class="GtkButton" id="expand_button">
                <property name="label" translatable="yes">Expand</property>
                <property name="can-focus">1</property>
                <property name="receives-default">1</property>
                <property name="relief">none</property>
                <signal name="clicked" handler="expand_clicked" swapped="yes"/>
              </object>
            </child>
            <child>
              <object class="GtkBox" id="extra_buttons_box">
                <property name="visible">0</property>
                <property name="spacing">6</property>
                <child>
                  <object class="GtkButton" id="reply-button">
                    <property name="label" translatable="yes">Reply</property>
                    <property name="can-focus">1</property>
                    <property name="receives-default">1</property>
                    <property name="relief">none</property>
                  </object>
                </child>
                <child>
                  <object class="GtkButton" id="reshare-button">
                    <property name="label" translatable="yes">Reshare</property>
                    <property name="can-focus">1</property>
                    <property name="receives-default">1</property>
                    <property name="relief">none</property>
                    <signal name="clicked" handler="reshare_clicked" swapped="yes"/>
                  </object>
                  <packing>
                    <property name="position">1</property>
                  </packing>
                </child>
                <child>
                  <object class="GtkButton" id="favorite-button">
                    <property name="label" translatable="yes">Favorite</property>
                    <property name="can-focus">1</property>
                    <property name="receives-default">1</property>
                    <property name="relief">none</property>
                    <signal name="clicked" handler="favorite_clicked" swapped="yes"/>
                  </object>
                  <packing>
                    <property name="position">2</property>
                  </packing>
                </child>
                <child>
                  <object class="GtkMenuButton" id="more-button">
                    <property name="can-focus">1</property>
                    <property name="receives-default">1</property>
                    <property name="relief">none</property>
                    <property name="popup">menu1</property>
                    <child>
                      <object class="GtkLabel" id="label7">
                        <property name="label" translatable="yes">More...</property>
                      </object>
                    </child>
                  </object>
                  <packing>
                    <property name="position">3</property>
                  </packing>
                </child>
              </object>
              <packing>
                <property name="position">1</property>
              </packing>
            </child>
          </object>
          <packing>
            <property name="left-attach">1</property>
            <property name="top-attach">3</property>
          </packing>
        </child>
        <child>
          <object class="GtkRevealer" id="details_revealer">
            <child>
              <object class="GtkBox" id="box5">
                <property name="orientation">vertical</property>
                <child>
                  <object class="GtkBox" id="box7">
                    <property name="margin-top">2</property>
                    <property name="margin-bottom">2</property>
                    <property name="spacing">8</property>
                    <child>
                      <object class="GtkFrame" id="frame1">
                        <property name="shadow-type">none</property>
                        <child>
                          <object class="GtkLabel" id="n_reshares_label">
                            <property name="label" translatable="0">&lt;b&gt;2&lt;/b&gt;
Reshares</property>
                            <property name="use-markup">1</property>
                          </object>
                        </child>
                        <child type="label_item"/>
                      </object>
                    </child>
                    <child>
                      <object class="GtkFrame" id="frame2">
                        <property name="shadow-type">none</property>
                        <child>
                          <object class="GtkLabel" id="n_favorites_label">
                            <property name="label" translatable="0">&lt;b&gt;2&lt;/b&gt;
FAVORITES</property>
                            <property name="use-markup">1</property>
                          </object>
                        </child>
                        <child type="label_item"/>
                      </object>
                      <packing>
                        <property name="position">1</property>
                      </packing>
                    </child>
                  </object>
                  <packing>
                    <property name="position">1</property>
                  </packing>
                </child>
                <child>
                  <object class="GtkBox" id="box6">
                    <child>
                      <object class="GtkLabel" id="detailed_time_label">
                        <property name="label" translatable="0">4:25 AM - 14 Jun 13 </property>
                        <style>
                          <class name="dim-label"/>
                        </style>
                      </object>
                    </child>
                    <child>
                      <object class="GtkButton" id="button5">
                        <property name="label" translatable="yes">Details</property>
                        <property name="can-focus">1</property>
                        <property name="receives-default">1</property>
                        <property name="relief">none</property>
                        <style>
                          <class name="dim-label"/>
                        </style>
                      </object>
                      <packing>
                        <property name="position">1</property>
                      </packing>
                    </child>
                  </object>
                  <packing>
                    <property name="position">2</property>
                  </packing>
                </child>
              </object>
            </child>
          </object>
          <packing>
            <property name="left-attach">1</property>
            <property name="top-attach">4</property>
          </packing>
        </child>
      </object>
    </child>
  </template>
</interface>
TEMPLATE
