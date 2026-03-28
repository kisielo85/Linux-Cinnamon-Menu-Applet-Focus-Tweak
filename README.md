# Linux-Cinnamon-Menu-Applet-Focus-Tweak
A little tweak to make the Cinnamon Menu behave a bit more Windows-like

![preview](preview.gif)


## how to use

#### Option 1:
download and run [cinnamon_menu_tweak.sh](https://github.com/kisielo85/Linux-Cinnamon-Menu-Applet-Focus-Tweak/blob/main/cinnamon_menu_tweak.sh)

``sh cinnamon_menu_tweak.sh``
<br><br>
#### Option 2
edit ``/usr/share/cinnamon/js/ui/popupMenu.js``

in ``_onEventCapture`` (line 3666)

change<br>``let activeMenuContains = this._eventIsOnActiveMenu(event);`` (line 3685)<br>
to<br>``let activeMenuContains = event.get_source().get_style_class_name != undefined;``

at the end of this function change<br>
``return true;`` (line 3702)<br>
to:<br>``return false;``
