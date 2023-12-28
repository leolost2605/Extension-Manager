/*
 * This is a simple program that allows correct formatting of the known-extensions keyfile
 * It has to be compiled manually with valac and isn't included in any meson.build nor the final installation
 */

public static int main (string[] args) {
    var key_file = new KeyFile ();

    try {
        key_file.load_from_file ("./known-extensions", NONE);

        key_file.set_string (args[1], "COMMENT", args[2]);
    
        key_file.save_to_file ("./known-extensions");
    } catch (Error e) {
        critical (e.message);
    }

    return 0;
}