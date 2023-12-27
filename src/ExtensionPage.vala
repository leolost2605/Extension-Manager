public class ExtensionPage : Gtk.Box {
    public signal void back ();

    private Extension extension;
    private Gtk.Label name_label;
    private Gtk.Label title_label;
    private Gtk.Label summary_label;
    private Gtk.Label description_label;

    construct {
        var back_button = new Gtk.Button.with_label (_("Back"));
        back_button.add_css_class (Granite.STYLE_CLASS_BACK_BUTTON);

        name_label = new Gtk.Label ("");

        var top_box = new Gtk.CenterBox () {
            start_widget = back_button,
            center_widget = name_label,
            margin_bottom = 3,
            margin_end = 3,
            margin_start = 3,
            margin_top = 3
        };

        title_label = new Gtk.Label ("") {
            xalign = 0,
            hexpand = true
        };
        title_label.add_css_class (Granite.STYLE_CLASS_H2_LABEL);

        summary_label = new Gtk.Label ("") {
            xalign = 0
        };

        var install_button = new Gtk.Button.with_label (_("Install")) {
            valign = CENTER,
            halign = CENTER
        };

        var top_grid = new Gtk.Grid () {
            row_spacing = 3,
            column_spacing = 3,
            margin_bottom = 12,
            margin_end = 12,
            margin_start = 12,
            margin_top = 12
        };
        top_grid.attach (title_label, 0, 0);
        top_grid.attach (summary_label, 0, 1);
        top_grid.attach (install_button, 1, 0);

        var color_box = new Gtk.Box (VERTICAL, 0);
        color_box.append (top_grid);

        description_label = new Gtk.Label ("") {
            halign = CENTER,
            margin_top = 12,
            margin_bottom = 12,
            margin_start = 12,
            margin_end = 12
        };

        orientation = VERTICAL;
        append (top_box);
        append (new Gtk.Separator (HORIZONTAL));
        append (color_box);
        append (description_label);

        back_button.clicked.connect (() => back ());
    }

    public void set_extension (Extension extension) {
        this.extension = extension;

        name_label.label = extension.name;
        title_label.label = extension.name;
        summary_label.label = extension.summary;
        description_label.label = extension.description != null && extension.description.strip () != "" ? extension.description : _("No description provided");
    }
}