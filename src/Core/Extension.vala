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
    public Pk.Package package { get; construct set; }

    public Extension (Pk.Package package, ExtensionType extension_type) {
        Object (
            package: package,
            name: package.get_name (),
            summary: package.summary,
            description: package.description,
            installed: INSTALLED in package.info,
            extension_type: extension_type
        );
    }

    public void toggle_install (Pk.ProgressCallback callback) {
        if (installed) {
            uninstall.begin (callback);
        } else {
            install.begin (callback);
        }
    }

    public async void update (Pk.ProgressCallback callback) {
        var client = new Pk.Client ();

        try {
            yield client.install_packages_async (Pk.TransactionFlag.NONE, { package.package_id }, null, callback);

            yield reload_package ();
        } catch (Error e) {
            warning ("Failed to install %s: %s", package.package_id, e.message);
        }
    }

    public async void install (Pk.ProgressCallback callback) {
        var client = new Pk.Client ();

        try {
            yield client.install_packages_async (Pk.TransactionFlag.NONE, { package.package_id }, null, callback);
        } catch (Error e) {
            warning ("Failed to install %s: %s", package.package_id, e.message);
        }

        yield reload_package ();
    }

    public async void uninstall (Pk.ProgressCallback callback) {
        var client = new Pk.Client ();

        try {
            yield client.remove_packages_async (Pk.TransactionFlag.NONE, { package.package_id }, true, true, null, callback);
        } catch (Error e) {
            warning ("Failed to uninstall %s: %s", package.package_id, e.message);
        }

        yield reload_package ();
    }

    private async void reload_package () {
        var client = new Pk.Client ();

        try {
            var result = yield client.search_names_async (Pk.Filter.NONE, { name }, null, () => {});

            if (result.get_package_array ().length == 0) {
                critical ("Couldn't refresh package %s: Package not found", name);
            }

            foreach (var package in result.get_package_array ()) {
                if (package.get_name () == name) {
                    this.package = package;
                    installed = INSTALLED in package.info;
                }
            }
        } catch (Error e) {
            warning ("Failed to refresh package: %s", e.message);
        }
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