/*
* Copyright © 2020 Cerne Zan
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Cerne Zan <mail@cernezan.com>
*/
namespace Feedbin{
    public class MainWindow : Gtk.Window {
    private Feedbin.WebView web_view;
    // private Gtk.Revealer back_revealer;
    private Gtk.Revealer settings_revealer;
    private Gtk.Revealer home_revealer;

    public MainWindow (Gtk.Application application) {
        Object (
            application: application,
            border_width: 0,
            icon_name: FeedbinApp.instance.application_id,
            resizable: true,
            title: "Feedbin",
            window_position: Gtk.WindowPosition.CENTER
        );
    }

    construct {
        
        default_height = 700;
        default_width = 1200;

        Gdk.RGBA rgba = { 0, 0, 0, 1 };
        rgba.parse ("#1365DF");
        Granite.Widgets.Utils.set_color_primary (this, rgba);
        var home = new Gtk.Button.from_icon_name ("go-home", Gtk.IconSize.LARGE_TOOLBAR) {
            tooltip_text = "Home"
        };

        home_revealer = new Gtk.Revealer () {
            transition_type = Gtk.RevealerTransitionType.CROSSFADE
        };
        home_revealer.add (home);

        var settings_button = new Gtk.Button.from_icon_name ("avatar-default", Gtk.IconSize.LARGE_TOOLBAR) {
            tooltip_text = "Settings"
        };

        settings_revealer = new Gtk.Revealer () {
            transition_type = Gtk.RevealerTransitionType.CROSSFADE
        };
        settings_revealer.add (settings_button);

        var header = new Gtk.HeaderBar () {
            has_subtitle = false,
            show_close_button = true
        };
        // header.pack_start (back_revealer);
        header.pack_start (home_revealer);
        header.pack_end (settings_revealer);
        


        web_view = new Feedbin.WebView ();
        web_view.load_uri ("https://" + FeedbinApp.instance.domain);

        var logo = new Gtk.Image.from_resource ("/com/github/cernezan/feedbin-elementary/logo-dark.png") {
            expand = true,
            margin_bottom = 48
        };

        var stack = new Gtk.Stack () {
            transition_duration = 300,
            transition_type = Gtk.StackTransitionType.UNDER_UP
        };
        stack.get_style_context ().add_class ("loading");
        stack.add_named (logo, "loading");
        stack.add_named (web_view, "web");

        set_titlebar (header);
        add (stack);

        web_view.load_changed.connect ((load_event) => {
            if (load_event == WebKit.LoadEvent.FINISHED) {
                stack.visible_child_name = "web";
            }
        });

        home.clicked.connect (() => {
            web_view.load_uri ("https://" + FeedbinApp.instance.domain);
        });

        settings_button.clicked.connect (() => {
            web_view.load_uri ("https://" + FeedbinApp.instance.domain + "/settings");
        });

        web_view.load_changed.connect (on_loading);
        web_view.notify["uri"].connect (on_loading);
        web_view.notify["estimated-load-progress"].connect (on_loading);
        web_view.notify["is-loading"].connect (on_loading);
    }
    


    private void on_loading () {
        home_revealer.reveal_child = (
            web_view.uri != "https://" + FeedbinApp.instance.domain + "/login" &&
            web_view.uri != "https://" + FeedbinApp.instance.domain + "/signup" &&
            web_view.uri != "https://" + FeedbinApp.instance.domain + "/password_resets/new" &&
            web_view.uri != "https://" + FeedbinApp.instance.domain + "/sites"
        );

        settings_revealer.reveal_child = (
            web_view.uri != "https://" + FeedbinApp.instance.domain + "/login" &&
            web_view.uri != "https://" + FeedbinApp.instance.domain + "/signup" &&
            web_view.uri != "https://" + FeedbinApp.instance.domain + "/password_resets/new" &&
            web_view.uri != "https://" + FeedbinApp.instance.domain + "/settings"
        );
    }
}
}

