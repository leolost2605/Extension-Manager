public class Extension : Object {
    public enum ExtensionType {
        GALA,
        SWITCHBOARD,
        WINGPANEL
    }

    public string name { get; construct; }
    public string summary { get; construct; }
    public string description { get; construct; }
    public bool installed { get; construct set; }
    public ExtensionType extension_type { get; construct; }
    public Pk.Package package { get; construct; }

    public Extension (Pk.Package package, ExtensionType extension_type) {
        Object (
            package: package,
            name: package.get_name (),
            summary: package.summary,
            description: package.description,
            installed: (package.info == INSTALLED),
            extension_type: extension_type
        );
    }

    public async void install () {
        //TODO
    }

    public async void uninstall () {
        //TODO
    }

    public static string type_enum_to_label (ExtensionType extension_type) {
        switch (extension_type) {
            case GALA:
                return _("Window Manager");
            case SWITCHBOARD:
                return _("Settings");
            case WINGPANEL:
                return _("Top Panel Indicators");
        }

        return _("Unknown");
    }
}