public class ExtensionPage : Gtk.Box {
    public signal void back ();

    private Extension extension;
    private Gtk.Label name_label;
    private Granite.HeaderLabel title_label;
    private Gtk.Label summary_label;
    private Gtk.Label size_label;
    private Gtk.Label description_label;
    private Gtk.Label whats_new_content_label;
    private Gtk.Button install_button;

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

        title_label = new Granite.HeaderLabel ("") {
            hexpand = true
        };
        title_label.add_css_class (Granite.STYLE_CLASS_H2_LABEL);

        summary_label = new Gtk.Label ("") {
            xalign = 0
        };

        install_button = new Gtk.Button.with_label (_("Install")) {
            valign = CENTER,
            halign = CENTER,
            width_request = 86
        };

        size_label = new Gtk.Label ("") {
            valign = CENTER,
            halign = CENTER,
        };

        var top_grid = new Gtk.Grid () {
            row_spacing = 3,
            column_spacing = 3,
            margin_bottom = 12,
            margin_end = 12,
            margin_start = 12,
            margin_top = 12
        };
        top_grid.attach (title_label, 0, 0);
        top_grid.attach (summary_label, 0, 1);
        top_grid.attach (install_button, 1, 0);
        top_grid.attach (size_label, 1, 1);

        var color_box = new Gtk.Box (VERTICAL, 0);
        color_box.append (top_grid);

        description_label = new Gtk.Label ("") {
            halign = CENTER,
            margin_top = 12,
            margin_bottom = 12,
            margin_start = 12,
            margin_end = 12,
            wrap = true
        };

        var whats_new_label = new Granite.HeaderLabel (_("What's New:")) {
            halign = START,
            margin_top = 12,
            margin_bottom = 12,
            margin_start = 12,
            margin_end = 12
        };
        whats_new_label.add_css_class (Granite.STYLE_CLASS_H3_LABEL);

        whats_new_content_label = new Gtk.Label ("") {
            halign = CENTER,
            margin_top = 12,
            margin_bottom = 12,
            margin_start = 12,
            margin_end = 12
        };

        orientation = VERTICAL;
        append (top_box);
        append (new Gtk.Separator (HORIZONTAL));
        append (color_box);
        append (description_label);
        append (whats_new_label);
        append (whats_new_content_label);

        back_button.clicked.connect (() => back ());

        install_button.clicked.connect (() => extension.toggle_install (progress_callback));
    }

    public void set_extension (Extension extension) {
        if (extension != null) {
            extension.notify["installed"].disconnect (check_install_button_label);
        }

        this.extension = extension;

        name_label.label = extension.name;
        title_label.label = extension.name;
        summary_label.label = extension.summary;
        size_label.label = GLib.format_size (extension.size);
        description_label.label = extension.description != null && extension.description.strip () != "" ? extension.description : _("No description provided");
        whats_new_content_label.label = extension.changelog;

        extension.notify["installed"].connect (check_install_button_label);
        check_install_button_label ();
    }

    private void check_install_button_label () {
        install_button.label = extension.installed ? _("Uninstall") : _("Install");
    }

    private void progress_callback (Pk.Progress progress, Pk.ProgressType progress_type) {
        install_button.label = status_to_title (progress.status);
        if (progress.percentage >= 0 &&
            progress.percentage <= 100 &&
            progress.status != Pk.Status.FINISHED &&
            progress.status != Pk.Status.CANCEL &&
            progress.status != Pk.Status.WAIT &&
            progress.status != Pk.Status.WAITING_FOR_LOCK &&
            progress.status != Pk.Status.WAITING_FOR_AUTH
        ) {
            install_button.label += " (%d%)".printf (progress.percentage);
        }
    }

    private unowned string status_to_title (Pk.Status status) {
        // From https://github.com/elementary/appcenter/blob/master/src/Core/ChangeInformation.vala#L51
        switch (status) {
            case Pk.Status.SETUP:
                return _("Starting");
            case Pk.Status.WAIT:
                return _("Waiting");
            case Pk.Status.RUNNING:
                return _("Running");
            case Pk.Status.QUERY:
                return _("Querying");
            case Pk.Status.INFO:
                return _("Getting information");
            case Pk.Status.REMOVE:
                return _("Removing packages");
            case Pk.Status.DOWNLOAD:
                return _("Downloading");
            case Pk.Status.REFRESH_CACHE:
                return _("Refreshing software list");
            case Pk.Status.UPDATE:
                return _("Installing updates");
            case Pk.Status.CLEANUP:
                return _("Cleaning up packages");
            case Pk.Status.OBSOLETE:
                return _("Obsoleting packages");
            case Pk.Status.DEP_RESOLVE:
                return _("Resolving dependencies");
            case Pk.Status.SIG_CHECK:
                return _("Checking signatures");
            case Pk.Status.TEST_COMMIT:
                return _("Testing changes");
            case Pk.Status.COMMIT:
                return _("Committing changes");
            case Pk.Status.REQUEST:
                return _("Requesting data");
            case Pk.Status.FINISHED:
                return _("Finished");
            case Pk.Status.CANCEL:
                return _("Cancelling");
            case Pk.Status.DOWNLOAD_REPOSITORY:
                return _("Downloading repository information");
            case Pk.Status.DOWNLOAD_PACKAGELIST:
                return _("Downloading list of packages");
            case Pk.Status.DOWNLOAD_FILELIST:
                return _("Downloading file lists");
            case Pk.Status.DOWNLOAD_CHANGELOG:
                return _("Downloading lists of changes");
            case Pk.Status.DOWNLOAD_GROUP:
                return _("Downloading groups");
            case Pk.Status.DOWNLOAD_UPDATEINFO:
                return _("Downloading update information");
            case Pk.Status.REPACKAGING:
                return _("Repackaging files");
            case Pk.Status.LOADING_CACHE:
                return _("Loading cache");
            case Pk.Status.SCAN_APPLICATIONS:
                return _("Scanning applications");
            case Pk.Status.GENERATE_PACKAGE_LIST:
                return _("Generating package lists");
            case Pk.Status.WAITING_FOR_LOCK:
                return _("Waiting for package manager lock");
            case Pk.Status.WAITING_FOR_AUTH:
                return _("Waiting for authentication");
            case Pk.Status.SCAN_PROCESS_LIST:
                return _("Updating running applications");
            case Pk.Status.CHECK_EXECUTABLE_FILES:
                return _("Checking applications in use");
            case Pk.Status.CHECK_LIBRARIES:
                return _("Checking libraries in use");
            case Pk.Status.COPY_FILES:
                return _("Copying files");
            case Pk.Status.INSTALL:
            default:
                return _("Installing");
        }
    }
}