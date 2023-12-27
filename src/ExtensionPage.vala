public class ExtensionPage : Gtk.Box {
    public signal void back ();

    private Extension extension;
    private Gtk.Label name_label;

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

        orientation = VERTICAL;
        append (top_box);
        append (new Gtk.Separator (HORIZONTAL));

        back_button.clicked.connect (() => back ());
    }

    public void set_extension (Extension extension) {
        this.extension = extension;

        name_label.label = extension.name;
    }
}