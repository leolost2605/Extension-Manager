public class ExtensionRow : Gtk.ListBoxRow {
    public Extension extension { get; construct; }

    public ExtensionRow (Extension extension) {
        Object (extension: extension);
    }

    construct {
        var image = new Gtk.Image.from_icon_name ("application-x-addon") {
            icon_size = LARGE
        };

        var header_label = new Granite.HeaderLabel (extension.name) {
            secondary_text = extension.summary,
            hexpand = true
        };

        var caret = new Gtk.Image.from_icon_name ("pan-end-symbolic");

        var box = new Gtk.Box (HORIZONTAL, 0);
        box.append (image);
        box.append (header_label);
        box.append (caret);

        child = box;
    }
}