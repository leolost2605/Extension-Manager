public class WelcomeView : Adw.Bin {
    construct {
        var placeholder = new Granite.Placeholder (_("Welcome")) {
            description = _("In ordered for Extension Manager to work, you will need to add an external software source."),
            halign = CENTER,
            valign = CENTER
        };
        var auto_button = placeholder.append_button (new ThemedIcon ("emblem-default"), _("Let Extension Manager add the source"), _("This will ask for your admin password"));
        var manually_button = placeholder.append_button (new ThemedIcon ("open-menu"), _("Manually add source"), _("This will show a dialog on how to add the source manually"));

        child = placeholder;

        auto_button.visible = false;
        auto_button.clicked.connect (() => {
            add_repo.begin ();
        });

        manually_button.clicked.connect (() => {
            var message_dialog = new Granite.MessageDialog (_("Add the PPA"), _("This will guide you through adding a PPA which is a 'Personal Package Archive'. In this case the PPA contains a curated list of extensions."), new ThemedIcon ("system-run")) {
                transient_for = (Gtk.Window) get_root (),
                resizable = true
            };
            
            var install_label = new Gtk.Label (_("If you have never added a PPA on your system before, you might need to run this command first:")) {
                wrap = true,
                halign = START
            };

            var install_terminal_label = new Gtk.Label ("sudo apt install -y software-properties-common") {
                selectable = true,
                margin_bottom = 4,
                margin_end = 4,
                margin_start = 4,
                margin_top = 4,
                halign = START
            };

            var install_terminal_bin = new Adw.Bin () {
                child = install_terminal_label
            };
            install_terminal_bin.add_css_class (Granite.STYLE_CLASS_TERMINAL);
            
            var add_label = new Gtk.Label (_("Add the PPA for the extensions:")) {
                wrap = true,
                margin_top = 12,
                halign = START
            };

            var add_terminal_label = new Gtk.Label ("sudo add-apt-repository -y ppa:leolost/extensions") {
                selectable = true,
                margin_bottom = 4,
                margin_end = 4,
                margin_start = 4,
                margin_top = 4,
                halign = START
            };

            var add_terminal_bin = new Adw.Bin () {
                child = add_terminal_label
            };
            add_terminal_bin.add_css_class (Granite.STYLE_CLASS_TERMINAL);

            message_dialog.custom_bin.spacing = 6;
            message_dialog.custom_bin.orientation = VERTICAL;
            message_dialog.custom_bin.append (install_label);
            message_dialog.custom_bin.append (install_terminal_bin);
            message_dialog.custom_bin.append (add_label);
            message_dialog.custom_bin.append (add_terminal_bin);

            message_dialog.response.connect (message_dialog.destroy);
            message_dialog.present ();
        });
    }

    //TODO: Think about whether we might want to collect the root password and then use this otherwise it's unfortunately not possible
    private async void add_repo () {
        try {
            var subprocess = new Subprocess (
                STDERR_PIPE | STDOUT_PIPE,
                "flatpak-spawn",
                "--host",
                "sudo",
                "add-apt-repository",
                "-y",
                "ppa:leolost/extensions"
            );

            Bytes stderr;
            Bytes stdout;
            yield subprocess.communicate_async (null, null, out stdout, out stderr);

            var stderr_data = Bytes.unref_to_data (stderr);
            var stdout_data = Bytes.unref_to_data (stdout);
            if (stderr_data != null) {
                critical ("Failed to save flatpak apps: %s", (string) stderr_data);
            } else if (stdout_data != null) {
                critical ("Output: %s", (string) stdout_data);
            }
        } catch (Error e) {
            critical ("Failed to create add-apt-repository subprocess: %s", e.message);
        }
    }
}