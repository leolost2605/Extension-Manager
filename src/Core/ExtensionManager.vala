public class ExtensionManager : Object {
    private static GLib.Once<ExtensionManager> instance;
    public static ExtensionManager get_default () {
        return instance.once (() => {return new ExtensionManager ();});
    }

    private const string TYPE_KEY = "TYPE";
    private const string COMMENT_KEY = "COMMENT";
    private const string CACHE_FILE = "KNOWN-EXTENSIONS";
    private const string URL = "https://raw.githubusercontent.com/leolost2605/Extension-Manager/main/data/known-extensions";

    //On end of operation send a null
    public signal void progress (string? label);

    public ListStore extensions { get; construct; }
    public bool ppa_available { get; private set; }

    private Pk.Client pk_client;
    private Pk.Control control;

    construct {
        extensions = new ListStore (typeof (Extension));
        pk_client = new Pk.Client ();
        control = new Pk.Control ();

        //For some reason repo_list_changed doesn't get emitted
        control.updates_changed.connect (() => check_repo_list.begin ());
        check_repo_list.begin ();
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
            var sack = result.get_package_sack ();

            try {
                yield sack.get_details_async (null, () => {});
            } catch (Error e) {
                warning ("Failed to get package details: %s", e.message);
            }

            try {
                yield sack.get_update_detail_async (null, () => {});
            } catch (Error e) {
                warning ("Failed to get package update details: %s", e.message);
            }

            foreach (var package in sack.get_array ()) {
                if (package.get_name () in known_extensions) {
                    known_extensions[package.get_name ()].set_package_detailed (package);
                    extensions.append (known_extensions[package.get_name ()]);
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

    private HashTable<string, Extension>? load_known_extensions (string contents) {
        var key_file = new KeyFile ();

        try {
            key_file.load_from_data ((string) contents, contents.length, NONE);
        } catch (Error e) {
            critical ("Failed to parse keyfile: %s", e.message);
            return null;
        }

        var result = new HashTable<string, Extension> (str_hash, str_equal);

        try {
            foreach (var extension in key_file.get_groups ()) {
                var extension_type = (Extension.ExtensionType) key_file.get_integer (extension, TYPE_KEY);

                string? comment = null;
                if (key_file.has_key (extension, COMMENT_KEY)) {
                    comment = key_file.get_string (extension, COMMENT_KEY);
                }

                result[extension] = new Extension (extension, extension_type, comment);
            }
        } catch (Error e) {
            critical ("Failed to get load extensions: %s", e.message);
        }

        return result;
    }

    private async void check_repo_list () {
        warning ("Checking repo list");
        try {
            var result = yield pk_client.get_repo_list_async (Pk.Filter.NONE, null, () => {});

            ppa_available = false;
            foreach (var repo in result.get_repo_detail_array ()) {
                //A bit lazy matching but should be good enough
                //The repo_id is long and (I think) might be inconsistent across devices
                if ("leolost" in repo.repo_id && "extensions" in repo.repo_id) {
                    ppa_available = true;
                    break;
                }
            }
        } catch (Error e) {
            warning ("Failed to check repolist: %s", e.message);
        }
    }
}