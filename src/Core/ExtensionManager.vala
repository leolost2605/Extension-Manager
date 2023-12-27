public class ExtensionManager : Object {
    private static GLib.Once<ExtensionManager> instance;
    public static ExtensionManager get_default () {
        return instance.once (() => {return new ExtensionManager ();});
    }

    //On end of operation send a null
    public signal void progress (string? label);

    public ListStore extensions { get; construct; }

    private Pk.Client pk_client;

    construct {
        extensions = new ListStore (typeof (Extension));
        pk_client = new Pk.Client ();
    }

    public async void load_extensions () {
        warning ("Started loading extension");
        var known_extensions = new HashTable<string, Extension.ExtensionType> (str_hash, str_equal);
        known_extensions["pantheon-tweaks"] = SWITCHBOARD;
        known_extensions["pantheon-photos"] = GALA;

        try {
            progress (_("Refreshing Cache…"));
            yield pk_client.refresh_cache_async (true, null, (progress, progress_type) => {
                if (progress_type == PERCENTAGE) {
                    warning ("Refresh cache progress: %s", progress.percentage.to_string ());
                }
            });

            progress (_("Downloading Extension List…"));
            var result = yield pk_client.search_names_async (Pk.Filter.NONE, known_extensions.get_keys_as_array (), null, (progress, progress_type) => {
                if (progress_type == PERCENTAGE) {
                    warning (progress.percentage.to_string ());
                }
            });

            foreach (var package in result.get_package_array ()) {
                if (package.get_name () in known_extensions) {
                    extensions.append (new Extension (package, known_extensions[package.get_name ()]));
                }
            }
        } catch (Error e) {
            warning ("Failed to get packages: %s", e.message);
        }

        progress (null);
    }
}