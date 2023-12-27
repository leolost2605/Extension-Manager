public class Window : Gtk.ApplicationWindow {
    private static Extension.ExtensionType current_type;

    public Window (Application app) {
        Object (
            application: app,
            default_height:300,
            default_width: 300,
            title: "Extension Manager"
        );
    }

    construct {
        var extension_manager = ExtensionManager.get_default ();

        var header_bar = new Gtk.HeaderBar ();
        header_bar.add_css_class (Granite.STYLE_CLASS_FLAT);

        var gala_row = new ExtensionTypeRow (GALA);
        var wingpanel_row = new ExtensionTypeRow (WINGPANEL);
        var switchboard_row = new ExtensionTypeRow (SWITCHBOARD);

        var type_list_box = new Gtk.ListBox () {
            activate_on_single_click = true
        };
        type_list_box.add_css_class (Granite.STYLE_CLASS_RICH_LIST);
        type_list_box.append (gala_row);
        type_list_box.append (wingpanel_row);
        type_list_box.append (switchboard_row);

        var back_button = new Gtk.Button.with_label (_("Back"));
        back_button.add_css_class (Granite.STYLE_CLASS_BACK_BUTTON);

        var type_label = new Gtk.Label ("");

        var top_box = new Gtk.CenterBox () {
            start_widget = back_button,
            center_widget = type_label,
            margin_bottom = 3,
            margin_end = 3,
            margin_start = 3,
            margin_top = 3
        };

        var filter = new Gtk.CustomFilter ((obj) => {
            var extension = (Extension) obj;
            return extension.extension_type == current_type;
        });

        var extension_filter_model = new Gtk.FilterListModel (extension_manager.extensions, filter);

        var extension_list_box = new Gtk.ListBox () {
            vexpand = true,
            activate_on_single_click = true
        };
        extension_list_box.add_css_class (Granite.STYLE_CLASS_RICH_LIST);
        extension_list_box.bind_model (extension_filter_model, (obj) => {
            var extension = (Extension) obj;
            return new ExtensionRow (extension);
        });

        var extension_box = new Gtk.Box (VERTICAL, 0);
        extension_box.append (top_box);
        extension_box.append (new Gtk.Separator (HORIZONTAL));
        extension_box.append (extension_list_box);

        var extension_page = new ExtensionPage ();

        var leaflet = new Adw.Leaflet () {
            can_unfold = false
        };
        leaflet.append (type_list_box);
        leaflet.append (extension_box);
        leaflet.append (extension_page);

        var frame = new Gtk.Frame (null) {
            child = leaflet,
            margin_top = 12,
            margin_bottom = 12,
            margin_start = 12,
            margin_end = 12
        };

        var overlay = new Gtk.Overlay () {
            child = frame
        };

        var overlay_bar = new Granite.OverlayBar (overlay) {
            active = true,
            visible = false
        };

        titlebar = header_bar;
        child = overlay;

        type_list_box.row_activated.connect ((row) => {
            current_type = ((ExtensionTypeRow)row).extension_type;
            filter.changed (DIFFERENT);
            type_label.label = Extension.type_enum_to_label (current_type);
            leaflet.navigate (FORWARD);
        });

        extension_list_box.row_activated.connect ((row) => {
            var extension_row = (ExtensionRow) row;
            extension_page.set_extension (extension_row.extension);
            leaflet.navigate (FORWARD);
        });

        back_button.clicked.connect (() => leaflet.navigate (BACK));

        extension_page.back.connect (() => leaflet.navigate (BACK));

        extension_manager.progress.connect ((label) => {
            if (label == null) {
                overlay_bar.visible = false;
                return;
            }

            overlay_bar.visible = true;
            overlay_bar.label = label;
        });

        extension_manager.load_extensions.begin ();
    }
}