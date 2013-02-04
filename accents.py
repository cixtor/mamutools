#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Orthographic Accent
# http://www.cixtor.com/
# http://es.wikipedia.org/wiki/Acento_ortogr%C3%A1fico
#
# The orthographic accent or 'tilde' is a sign used in Spanish generally over a
# vowel (a, e, i, o, u). In some Romances languages, as Spanish and Catalan, is
# often used the diacritic accent to difference some words from others with the
# same writing but with different meanings and use cases.
#
# In several languages ​​the orthographic accent has some variants, including: the
# acute accent (´), the circumflex accent (^) or grave accent (`). In many languages​​,
# each type of accent can fall on different types of speech. In Spanish, the acute
# accent is the only thing that can go over a vowel. In French the circumflex
# accent is used to indicate the elongation of a vowel by the loss of the letter
# "s" implosive, although in Portuguese the same accent is intended to indicate
# the degree of opening of the vowel.
#
import gtk
import pango

class SpanishAccent:
    def destroy(self, widget, data=None):
        gtk.main_quit()

    def keypress(self, widget, event):
        if event.keyval == gtk.keysyms.Escape:
            gtk.main_quit()

    def __init__(self):
        window = gtk.Window(gtk.WINDOW_TOPLEVEL)
        pango_font = pango.FontDescription('Monospace 20')
        label = gtk.Label('á é í ó ú ñ ¿ ¡\nÁ É Í Ó Ú Ñ ? !')

        window.connect('destroy', self.destroy)
        window.connect('key-press-event', self.keypress)

        window.set_position(gtk.WIN_POS_CENTER)
        window.set_title('Orthographic Accent')
        window.set_border_width(10)
        label.modify_font(pango_font)
        label.set_property('selectable', True)
        window.add(label)

        window.show_all()
        gtk.main()

if __name__ == "__main__":
    application = SpanishAccent()
