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