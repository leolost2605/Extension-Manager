public class ExtensionTypeRow : Gtk.ListBoxRow {
    public Extension.ExtensionType extension_type { get; construct; }

    public ExtensionTypeRow (Extension.ExtensionType extension_type) {
        Object (extension_type: extension_type);
    }

    construct {
        var label = new Gtk.Label (Extension.type_enum_to_label (extension_type)) {
            hexpand = true,
            xalign = 0
        };

        var caret = new Gtk.Image.from_icon_name ("pan-end-symbolic");

        var box = new Gtk.Box (HORIZONTAL, 0);
        box.append (label);
        box.append (caret);

        child = box;
    }
}