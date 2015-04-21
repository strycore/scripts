#!/usr/bin/env python

from gi.repository import Gio

XKB_GSETTINGS_SCHEMA = "org.gnome.desktop.input-sources"
XKB_GSETTINGS_NAME = "xkb-options"


def get_xkb_setting():
    return Gio.Settings(XKB_GSETTINGS_SCHEMA)


def set_xkb_option(key, value):
    option = ":".join((key, value))
    setting = get_xkb_setting()
    opts = setting[XKB_GSETTINGS_NAME]
    if option in opts:
        # opts.remove(option)
        pass
    else:
        opts.append(option)

    setting[XKB_GSETTINGS_NAME] = opts


if __name__ == '__main__':
    options = {
        'caps': 'swapescape',
        'compose': 'menu',
        'terminate': 'ctrl_alt_bksp'
    }
    for key, value in options.items():
        set_xkb_option(key, value)
    print get_xkb_setting()[XKB_GSETTINGS_NAME]
