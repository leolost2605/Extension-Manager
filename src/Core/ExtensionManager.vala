public class ExtensionManager : Object {
    private static GLib.Once<ExtensionManager> instance;
    public static ExtensionManager get_default () {
        return instance.once (() => {return new ExtensionManager ();});
    }

    public ListStore extensions { get; construct; }

    private Pk.Client pk_client;

    construct {
        extensions = new ListStore (typeof (Extension));
        pk_client = new Pk.Client ();
        load_extensions.begin ();
        warning ("Started loading extension");
    }

    public async void load_extensions () {
        string[] known_extensions = { "com.github.pantheon-tweaks.pantheon-tweaks", "io.elementary.photos" };

        var pool = new AppStream.Pool ();

        try {
            yield pool.load_async (null);
        } catch (Error e) {
            warning ("Failed to load AppStream Pool: %s", e.message);
            return;
        }

        //  var components = pool.get_components_by_extends ("io.elementary.switchboard").as_array ();
        //  foreach (var component in components) {
        //      warning (component.id);
        //      extensions.append (new Extension.from_component (component));
        //  }
        warning ("Finished");
        var components = pool.get_components ();
        foreach (var component in components) {
            if ("elementary" in component.id) {
                warning (component.id);
            }
        }
        //  if (components.length != 1) {
        //      warning ("More than one component found");
        //  } else {
        //      extensions.append (new Extension.from_component (components[0]));
        //  }
        
        //  foreach (var extension in known_extensions) {
        //      var components = pool.get_components_by_id (extension).as_array ();
        //      if (components.length != 1) {
        //          warning ("More than one component found");
        //      } else {
        //          extensions.append (new Extension.from_component (components[0]));
        //      }
        //  }
        return;

        return;
        try {
            yield pk_client.refresh_cache_async (true, null, (progress, progress_type) => {
                if (progress_type == PERCENTAGE) {
                    warning ("Refresh cache progress: %s", progress.percentage.to_string ());
                }
            });
            var result = yield pk_client.search_names_async (Pk.Filter.NONE, known_extensions, null, (progress, progress_type) => {
                if (progress_type == PERCENTAGE) {
                    warning (progress.percentage.to_string ());
                }
            });
            foreach (var package in result.get_package_array ()) {
                if (package.get_name () in known_extensions) {
                    extensions.append (new Extension (package));
                    warning ("FOUND!!!");
                }
                warning (package.package_id);
            }
            warning (result.get_exit_code ().to_string ());
        } catch (Error e) {
            warning ("Failed to get packages: %s", e.message);
        }
    }
}