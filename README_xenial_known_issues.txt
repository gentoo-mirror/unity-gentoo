- Unity via unity-base/unity-settings-daemon strips the 'grp' option for XKB keyboard layouts (see LP# 1315867 and overlay issue #133)
	* This can lead to problems trying to use group keyboard layout(s)/variant(s) customised key+combo switching
		Based on bug, requires upstream to patch support into unity-settings-daemon,unity,compiz and unity-control-center

- Certain QT5 applications in Gentoo require QT_QPA_PLATFORMTHEME environment variable to be unset (usually set to 'appmenu-qt5' by /etc/profile.d/appmenu-qt5.sh)
	Otherwise the application's GUI windows refuses to show with the following hang error:
		GLib-GObject-WARNING **: cannot register existing type 'GdkDisplayManager'
		GLib-CRITICAL **: g_once_init_leave: assertion 'result != 0' failed
		GLib-GObject-CRITICAL **: g_object_new: assertion 'G_TYPE_IS_OBJECT (object_type)' failed
	Applications so far include:
		net-misc/dropbox

- Lockscreen fails to function when onscreen reader (orca) is activated Super+Alt+S (broken since Trusty, see LP# 1310404)

- Mir display server completely broken:
	* Opens to a black screen with seemingly no fatal errors in /var/log/lightdm/unity-system-compositor.log
	* Likely due to new code re-write in Xmir, tracking bugs here ->
		https://bugs.launchpad.net/ubuntu/+source/xorg-server/+bugs?field.tag=xmir
	* >=mir-0.17.0+15.10.20151008.2-0ubuntu1 now breaks building mesa-11.0.2-1ubuntu4:
		/var/tmp/portage/media-libs/mesa-11.0.2_p1_p04/work/mesa-11.0.2/src/egl/drivers/dri2/platform_mir.c: In function ‘create_gbm_bo_from_buffer’:
		/var/tmp/portage/media-libs/mesa-11.0.2_p1_p04/work/mesa-11.0.2/src/egl/drivers/dri2/platform_mir.c:167:21: error: dereferencing pointer to incomplete type
			data.fd = package->fd[0];
					 ^
	 - Only solution is to use Xenial version of media-libs/mesa

- Webapps completely broken since Xenial, net-libs/oxide-qt to be fixed by upstream (see LP# 1332996 and LP# 1341565)
	* No solution at this time except to totally disable webapps (unity-base/unity-meta[-webapps])
- Webapps plugin is broken for chromium since Vivid release, browser will not prompt for webapp installation on sites such as Gmail, Youtube or Facebook
	* Use Firefox if you want webapps to work
- Webapps plugins for >=www-client/firefox-43 stops working as Firefox now require addon signing and so disable the webapps plugins as their signature cannot be verified
	* In Firefox's addressbar type 'about:config' and set 'xpinstall.signatures.required' from 'true' to 'false'. Plugins should now be enabled in 'Tools > Addons' after restarting Firefox

- Window control buttons can no longer currently be configured to be on the right using dconf/unity-tweak-tool
	* Possibly due to changes in >=gtk-3.10 GtkHeaderBar client side decorations and ubuntu-themes

- Xrandr does not work in Mir (unable to get a list of valid screen resolutions other than the one being used, screen rotate does nothing)

- Ubuntu's patched Gnome packages become outdated with Gnome versions available in portage tree
  * The striving goal is to have Gnome from the portage tree and Unity desktop from the overlay able to be installed and function together side-by-side
  * Ubuntu heavily patch and fork a number of Gnome packages that are crucial to Unity's and Gnome's desktop function
  * Ubuntu's development of these packages lags greatly behind the changes Gnome upstream make, and so also lags behind what
        Gnome versions become available and are subsequently dropped in the portage tree
  * The most important packages affected are as follows:
        gnome-base/gnome-desktop
        gnome-base/gnome-session
        gnome-base/gnome-settings-daemon
        unity-base/unity-settings-daemon (Ubuntu fork of gnome-base/gnome-settings-daemon)
        unity-base/unity-control-center (Ubuntu fork of gnome-base/gnome-control-center)
  * The flow-on effect of this development lag and subsequent version mismatch is that some updated features in Gnome can break in Unity
