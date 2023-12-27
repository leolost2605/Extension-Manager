public class ExtensionManager : Object {
    private static GLib.Once<ExtensionManager> instance;
    public static ExtensionManager get_default () {
        return instance.once (() => {return new ExtensionManager ();});
    }

    private const string KEY_GROUP = "EXTENSIONS";
    private const string CACHE_FILE = "KNOWN-EXTENSIONS";
    private const string URL = "https://raw.githubusercontent.com/leolost2605/Extension-Manager/main/data/known-extensions";

    //On end of operation send a null
    public signal void progress (string? label);

    public ListStore extensions { get; construct; }

    private Pk.Client pk_client;

    construct {
        extensions = new ListStore (typeof (Extension));
        pk_client = new Pk.Client ();
    }

    public async void load_extensions () {
        progress (_("Downloading Extension List…"));
        var file_contents = yield get_extensions_file_content ();

        if (file_contents == null) {
            progress (null);
            return;
        }

        var known_extensions = load_known_extensions (file_contents);

        if (known_extensions == null) {
            progress (null);
            return;
        }

        try {
            progress (_("Refreshing Software Cache…"));
            yield pk_client.refresh_cache_async (true, null, () => {});

            progress (_("Getting Extensions…"));
            var result = yield pk_client.search_names_async (Pk.Filter.NONE, known_extensions.get_keys_as_array (), null, () => {});

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

    private async string? get_extensions_file_content () {
        var remote_file = File.new_for_uri (URL);
        var cache_file = File.new_build_filename (Environment.get_user_cache_dir (), CACHE_FILE);

        bool use_remote = false;
        if (remote_file.query_exists ()) {
            try {
                yield remote_file.copy_async (cache_file, OVERWRITE);
            } catch (Error e) {
                use_remote = true;
                warning ("Failed to copy remote file to local cache: %s", e.message);
            }
        } else {
            warning ("Couldn't find remote file!");
        }

        uint8[] contents;
        try {
            if (use_remote) {
                yield remote_file.load_contents_async (null, out contents, null);
            } else {
                yield cache_file.load_contents_async (null, out contents, null);
            }
        } catch (Error e) {
            critical ("Failed to load contents of file: %s", e.message);
            return null;
        }

        return (string) contents;
    }

    public HashTable<string, Extension.ExtensionType>? load_known_extensions (string contents) {
        var key_file = new KeyFile ();

        try {
            key_file.load_from_data ((string) contents, contents.length, NONE);
        } catch (Error e) {
            critical ("Failed to parse keyfile: %s", e.message);
            return null;
        }

        var result = new HashTable<string, Extension.ExtensionType> (str_hash, str_equal);

        try {
            foreach (var key in key_file.get_keys (KEY_GROUP)) {
                result[key] = (Extension.ExtensionType) key_file.get_integer (KEY_GROUP, key);
            }
        } catch (Error e) {
            critical ("Failed to get key group and keys: %s", e.message);
        }

        return result;
    }
}