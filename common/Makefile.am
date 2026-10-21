if !ENABLE_TRANSPARENCY
themedir        = $(datadir)/themes/Ayu-Light-solid
thememiragedir  = $(datadir)/themes/Ayu-Mirage-solid
themedarkdir    = $(datadir)/themes/Ayu-Dark-solid
hdpidir         = $(datadir)/themes/Ayu-Light-solid-hdpi
hdpimiragedir   = $(datadir)/themes/Ayu-Mirage-solid-hdpi
hdpidarkdir     = $(datadir)/themes/Ayu-Dark-solid-hdpi
else
themedir        = $(datadir)/themes/Ayu-Light
thememiragedir  = $(datadir)/themes/Ayu-Mirage
themedarkdir    = $(datadir)/themes/Ayu-Dark
hdpidir         = $(datadir)/themes/Ayu-Light-hdpi
hdpimiragedir   = $(datadir)/themes/Ayu-Mirage-hdpi
hdpidarkdir     = $(datadir)/themes/Ayu-Dark-hdpi
endif

ithemedir       = $(DESTDIR)$(themedir)
ithememiragedir = $(DESTDIR)$(thememiragedir)
ithemedarkdir   = $(DESTDIR)$(themedarkdir)
ihdpidir        = $(DESTDIR)$(hdpidir)
ihdpimiragedir  = $(DESTDIR)$(hdpimiragedir)
ihdpidarkdir    = $(DESTDIR)$(hdpidarkdir)

install-exec-hook:

install-data-local:

if ENABLE_LIGHT
	$(MKDIR_P) $(ithemedir)
	cp $(srcdir)/index.theme $(ithemedir)
endif # ENABLE_LIGHT

if ENABLE_MIRAGE
	$(MKDIR_P) $(ithememiragedir)
	cp $(srcdir)/index.theme-mirage $(ithememiragedir)/index.theme
endif # ENABLE_LIGHT

if ENABLE_DARK
	$(MKDIR_P) $(ithemedarkdir)
	cp $(srcdir)/index.theme-dark $(ithemedarkdir)/index.theme
endif # ENABLE_DARK


if ENABLE_CINNAMON
	$(MKDIR_P) $(ithemedir)/cinnamon

	cd $(srcdir)/cinnamon && cp -R \
		common-assets \
		light-assets \
		cinnamon.css \
		$(ithemedir)/cinnamon

if ENABLE_MIRAGE
	$(MKDIR_P) $(ithememiragedir)/cinnamon

	cd $(srcdir)/cinnamon && cp -R \
		common-assets \
		dark-assets \
		$(ithememiragedir)/cinnamon

	cd $(srcdir)/cinnamon && cp -R \
		cinnamon-mirage.css \
		$(ithememiragedir)/cinnamon/cinnamon.css
endif # ENABLE_MIRAGE

if ENABLE_DARK
	$(MKDIR_P) $(ithemedarkdir)/cinnamon

	cd $(srcdir)/cinnamon && cp -R \
		common-assets \
		dark-assets \
		$(ithemedarkdir)/cinnamon

	cd $(srcdir)/cinnamon && cp -R \
		cinnamon-dark.css \
		$(ithemedarkdir)/cinnamon/cinnamon.css
endif # ENABLE_DARK

endif # ENABLE_CINNAMON


if ENABLE_GNOME_SHELL
	$(MKDIR_P) $(ithemedir)/gnome-shell

	cd $(srcdir)/gnome-shell/$(GNOME_VERSION) && cp -R \
		common-assets \
		light-assets \
		gnome-shell.css \
		$(ithemedir)/gnome-shell

if ENABLE_MIRAGE
	$(MKDIR_P) $(ithememiragedir)/gnome-shell

	cd $(srcdir)/gnome-shell/$(GNOME_VERSION) && cp -R \
		common-assets \
		dark-assets \
		$(ithememiragedir)/gnome-shell

	cd $(srcdir)/gnome-shell/$(GNOME_VERSION) && cp -R \
		gnome-shell-mirage.css \
		$(ithememiragedir)/gnome-shell/gnome-shell.css
endif # ENABLE_MIRAGE

if ENABLE_DARK
	$(MKDIR_P) $(ithemedarkdir)/gnome-shell

	cd $(srcdir)/gnome-shell/$(GNOME_VERSION) && cp -R \
		common-assets \
		dark-assets \
		$(ithemedarkdir)/gnome-shell

	cd $(srcdir)/gnome-shell/$(GNOME_VERSION) && cp -R \
		gnome-shell-dark.css \
		$(ithemedarkdir)/gnome-shell/gnome-shell.css
endif # ENABLE_DARK

endif # ENABLE_GNOME_SHELL


if ENABLE_GTK2

if ENABLE_LIGHT
	$(MKDIR_P) $(ithemedir)/gtk-2.0

	cd $(srcdir)/gtk-2.0 && cp -R \
		assets \
		menubar-toolbar \
		*.rc \
		gtkrc \
		$(ithemedir)/gtk-2.0
endif # ENABLE_LIGHT

if ENABLE_MIRAGE
	$(MKDIR_P) $(ithememiragedir)/gtk-2.0

	cd $(srcdir)/gtk-2.0 && cp -R \
		menubar-toolbar \
		*.rc \
		$(ithememiragedir)/gtk-2.0

	cd $(srcdir)/gtk-2.0 && cp -R \
		assets-dark \
		$(ithememiragedir)/gtk-2.0/assets

	cd $(srcdir)/gtk-2.0 && cp -R \
		gtkrc-mirage \
		$(ithememiragedir)/gtk-2.0/gtkrc
endif # ENABLE_MIRAGE

if ENABLE_DARK
	$(MKDIR_P) $(ithemedarkdir)/gtk-2.0

	cd $(srcdir)/gtk-2.0 && cp -R \
		menubar-toolbar \
		*.rc \
		$(ithemedarkdir)/gtk-2.0

	cd $(srcdir)/gtk-2.0 && cp -R \
		assets-dark \
		$(ithemedarkdir)/gtk-2.0/assets

	cd $(srcdir)/gtk-2.0 && cp -R \
		gtkrc-dark \
		$(ithemedarkdir)/gtk-2.0/gtkrc
endif # ENABLE_DARK

endif # ENABLE_GTK2


if ENABLE_GTK3

if ENABLE_LIGHT
	$(MKDIR_P) $(ithemedir)/gtk-3.0

	cd $(srcdir)/gtk-3.0/$(GNOME_VERSION) && cp -R \
		assets \
		gtk.css \
		gtk-dark.css \
		$(ithemedir)/gtk-3.0
endif # ENABLE_LIGHT

if ENABLE_MIRAGE
	$(MKDIR_P) $(ithememiragedir)/gtk-3.0

	cd $(srcdir)/gtk-3.0/$(GNOME_VERSION) && cp -R \
		assets \
		gtk-dark.css \
		$(ithememiragedir)/gtk-3.0

	cd $(srcdir)/gtk-3.0/$(GNOME_VERSION) && cp -R \
		gtk-mirage.css \
		$(ithememiragedir)/gtk-3.0/gtk.css
endif # ENABLE_MIRAGE

if ENABLE_DARK
	$(MKDIR_P) $(ithemedarkdir)/gtk-3.0

	cd $(srcdir)/gtk-3.0/$(GNOME_VERSION) && cp -R \
		assets \
		$(ithemedarkdir)/gtk-3.0

	cd $(srcdir)/gtk-3.0/$(GNOME_VERSION) && cp -R \
		gtk-dark.css \
		$(ithemedarkdir)/gtk-3.0/gtk.css
endif # ENABLE_DARK

if !ENABLE_TRANSPARENCY

if ENABLE_LIGHT
	cd $(srcdir)/gtk-3.0/$(GNOME_VERSION) && cp -R \
		gtk-solid.css \
		$(ithemedir)/gtk-3.0/gtk.css

	cd $(srcdir)/gtk-3.0/$(GNOME_VERSION) && cp -R \
		gtk-solid-dark.css \
		$(ithemedir)/gtk-3.0/gtk-dark.css
endif # ENABLE_LIGHT

if ENABLE_MIRAGE
	cd $(srcdir)/gtk-3.0/$(GNOME_VERSION) && cp -R \
		gtk-solid-mirage.css \
		$(ithememiragedir)/gtk-3.0/gtk.css

	cd $(srcdir)/gtk-3.0/$(GNOME_VERSION) && cp -R \
		gtk-solid-dark.css \
		$(ithememiragedir)/gtk-3.0/gtk-dark.css
endif # ENABLE_MIRAGE

if ENABLE_DARK
	cd $(srcdir)/gtk-3.0/$(GNOME_VERSION) && cp -R \
		gtk-solid-dark.css \
		$(ithemedarkdir)/gtk-3.0/gtk.css
endif # ENABLE_DARK

endif #!ENABLE_TRANSPARENCY

endif # ENABLE_GTK3


if ENABLE_GTK4

if ENABLE_LIGHT
	$(MKDIR_P) $(ithemedir)/gtk-4.0

	cd $(srcdir)/gtk-4.0 && cp -R \
		assets \
		gtk.css \
		gtk-dark.css \
		$(ithemedir)/gtk-4.0
endif # ENABLE_LIGHT

if ENABLE_MIRAGE
	$(MKDIR_P) $(ithememiragedir)/gtk-4.0

	cd $(srcdir)/gtk-4.0 && cp -R \
		assets \
		gtk-dark.css \
		$(ithememiragedir)/gtk-4.0

	cd $(srcdir)/gtk-4.0 && cp -R \
		gtk-mirage.css \
		$(ithememiragedir)/gtk-4.0/gtk.css
endif # ENABLE_MIRAGE

if ENABLE_DARK
	$(MKDIR_P) $(ithemedarkdir)/gtk-4.0

	cd $(srcdir)/gtk-4.0 && cp -R \
		assets \
		$(ithemedarkdir)/gtk-4.0

	cd $(srcdir)/gtk-4.0 && cp -R \
		gtk-dark.css \
		$(ithemedarkdir)/gtk-4.0/gtk.css
endif # ENABLE_DARK

if !ENABLE_TRANSPARENCY

if ENABLE_LIGHT
	cd $(srcdir)/gtk-4.0 && cp -R \
		gtk-solid.css \
		$(ithemedir)/gtk-4.0/gtk.css

	cd $(srcdir)/gtk-4.0 && cp -R \
		gtk-solid-dark.css \
		$(ithemedir)/gtk-4.0/gtk-dark.css
endif # ENABLE_LIGHT

if ENABLE_MIRAGE
	cd $(srcdir)/gtk-4.0 && cp -R \
		gtk-solid-mirage.css \
		$(ithememiragedir)/gtk-4.0/gtk.css

	cd $(srcdir)/gtk-4.0 && cp -R \
		gtk-solid-dark.css \
		$(ithememiragedir)/gtk-4.0/gtk-dark.css
endif # ENABLE_MIRAGE

if ENABLE_DARK
	cd $(srcdir)/gtk-4.0 && cp -R \
		gtk-solid-dark.css \
		$(ithemedarkdir)/gtk-4.0/gtk.css
endif # ENABLE_DARK

endif #!ENABLE_TRANSPARENCY

endif # ENABLE_GTK4


if ENABLE_METACITY

if ENABLE_LIGHT
	cp -R $(srcdir)/metacity-1 $(ithemedir)

	cd $(ithemedir)/metacity-1 && rm metacity-theme-1-dark.xml metacity-theme-2-dark.xml
endif # ENABLE_LIGHT

if ENABLE_MIRAGE
	cp -R $(srcdir)/metacity-1 $(ithememiragedir)

	cd $(ithememiragedir)/metacity-1 && \
		mv metacity-theme-1-dark.xml metacity-theme-1.xml && \
		mv metacity-theme-2-dark.xml metacity-theme-2.xml
endif # ENABLE_MIRAGE

if ENABLE_DARK
	cp -R $(srcdir)/metacity-1 $(ithemedarkdir)

	cd $(ithemedarkdir)/metacity-1 && \
		mv metacity-theme-1-dark.xml metacity-theme-1.xml && \
		mv metacity-theme-2-dark.xml metacity-theme-2.xml
endif # ENABLE_DARK

endif # ENABLE_METACITY


if ENABLE_UNITY

if ENABLE_LIGHT
	cp -R $(srcdir)/unity $(ithemedir)

	cd $(ithemedir)/unity && rm -rf window-buttons-dark
endif # ENABLE_LIGHT

if ENABLE_MIRAGE
	cp -R $(srcdir)/unity $(ithememiragedir)

	cd $(ithememiragedir)/unity && \
	rm -rf window-buttons && \
	mv window-buttons-dark window-buttons
endif # ENABLE_MIRAGE

if ENABLE_DARK
	cp -R $(srcdir)/unity $(ithemedarkdir)

	cd $(ithemedarkdir)/unity && \
	rm -rf window-buttons && \
	mv window-buttons-dark window-buttons
endif # ENABLE_DARK

endif # ENABLE_UNITY


if ENABLE_XFWM

if ENABLE_LIGHT
	$(MKDIR_P) $(ithemedir)/xfwm4 $(ihdpidir)/xfwm4

	cd $(srcdir)/xfwm4 && \
		cp -R assets/*.png $(ithemedir)/xfwm4 && \
		cp themerc $(ithemedir)/xfwm4/themerc && \
		cp -R assets-hdpi/*.png $(ihdpidir)/xfwm4 && \
		cp themerc-hdpi $(ihdpidir)/xfwm4/themerc
endif # ENABLE_LIGHT

if ENABLE_MIRAGE
	$(MKDIR_P) $(ithememiragedir)/xfwm4 $(ihdpimiragedir)/xfwm4

	cd $(srcdir)/xfwm4 && \
		cp -R assets-mirage/*.png $(ithememiragedir)/xfwm4 && \
		cp themerc-mirage $(ithememiragedir)/xfwm4/themerc && \
		cp -R assets-mirage-hdpi/*.png $(ihdpimiragedir)/xfwm4 && \
		cp themerc-mirage-hdpi $(ihdpimiragedir)/xfwm4/themerc
endif # ENABLE_MIRAGE

if ENABLE_DARK
	$(MKDIR_P) $(ithemedarkdir)/xfwm4 $(ihdpidarkdir)/xfwm4

	cd $(srcdir)/xfwm4 && \
		cp -R assets-dark/*.png $(ithemedarkdir)/xfwm4 && \
		cp themerc-dark $(ithemedarkdir)/xfwm4/themerc && \
		cp -R assets-dark-hdpi/*.png $(ihdpidarkdir)/xfwm4 && \
		cp themerc-dark-hdpi $(ihdpidarkdir)/xfwm4/themerc
endif # ENABLE_DARK

endif # ENABLE_XFWM


uninstall-local:
	rm -rf $(ithemedir)

if ENABLE_MIRAGE
	rm -rf $(ithememiragedir)
endif # ENABLE_MIRAGE

if ENABLE_DARK
	rm -rf $(ithemedarkdir)
endif # ENABLE_DARK

if ENABLE_XFWM
	rm -rf $(ihdpidir)

if ENABLE_MIRAGE
	rm -rf $(ihdpimiragedir)
endif # ENABLE_MIRAGE

if ENABLE_DARK
	rm -rf $(ihdpidarkdir)
endif # ENABLE_DARK
endif # ENABLE_XFWM


EXTRA_DIST = $(srcdir)/cinnamon \
	     $(srcdir)/gnome-shell \
	     $(srcdir)/gtk-2.0 \
	     $(srcdir)/gtk-3.0 \
	     $(srcdir)/gtk-4.0 \
	     $(srcdir)/metacity-1 \
	     $(srcdir)/unity \
	     $(srcdir)/xfwm4 \
	     $(srcdir)/index.theme \
	     $(srcdir)/index.theme-mirage \
	     $(srcdir)/index.theme-dark
