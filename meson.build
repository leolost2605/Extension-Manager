# project name and programming language
project('io.github.leolost2605.extension-manager', 'vala', 'c')

# Include the translations module
i18n = import('i18n')

# Set our translation domain
add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

# Create a new executable, list the files we want to compile, list the dependencies we need, and install
executable(
    meson.project_name(),
    'src' / 'Application.vala',
    'src' / 'CategoryRow.vala',
    'src' / 'ExtensionPage.vala',
    'src' / 'ExtensionRow.vala',
    'src' / 'Window.vala',
    'src' / 'Core' / 'Extension.vala',
    'src' / 'Core' / 'ExtensionManager.vala',
    dependencies: [
        dependency('gtk4'),
        dependency('packagekit-glib2'),
        dependency('libadwaita-1'),
        dependency('granite-7')
    ],
    install: true
)

subdir('data')
subdir('po')
