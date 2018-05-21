#!/bin/bash -e

function do_Install_Base_Dependencies(){
    echo
    echo '-- Installing Base Dependencies --'

    if [[ $BASE == "debian" ]]; then
        apt-get update -qq

        # Base dependencies
        apt-get -y -qq install build-essential git clang patch bison flex \
                               python-dev python3-dev \
                               autotools-dev autoconf gettext pkgconf autopoint yelp-tools \
                               docbook docbook-xsl libtext-csv-perl \
                               zlib1g-dev libdbus-glib-1-dev \
                               libtool libicu-dev libnspr4-dev \
                               policykit-1 > /dev/null

    elif [[ $BASE == "fedora" ]]; then
        dnf -y -q upgrade

        # Base dependencies
        dnf -y -q install @c-development @development-tools clang redhat-rpm-config gnome-common python-devel \
                          pygobject2 dbus-python perl-Text-CSV perl-XML-Parser gettext-devel gtk-doc ninja-build \
                          zlib-devel libffi-devel \
                          libtool libicu-devel nspr-devel
    else
        echo
        echo '-- Error: invalid BASE code --'
        exit 1
    fi
}

function do_Install_Dependencies(){
    echo
    echo '-- Installing Dependencies --'

    if [[ $BASE == "debian" ]]; then
        # Testing dependencies
        apt-get -y -qq install libgtk-3-dev gir1.2-gtk-3.0 xvfb gnome-desktop-testing dbus-x11 dbus \
                               libedit-dev libgl1-mesa-dev > /dev/null

    elif [[ $BASE == "fedora" ]]; then
        # Testing dependencies
        dnf -y -q install gtk3 gtk3-devel gobject-introspection Xvfb gnome-desktop-testing dbus-x11 dbus \
                          cairo intltool libxslt bison nspr zlib python3-devel dbus-glib libicu libffi pcre libxml2 libxslt libtool flex \
                          cairo-devel zlib-devel libffi-devel pcre-devel libxml2-devel libxslt-devel \
                          libedit-devel libasan libubsan lcov mesa-libGL-devel

        if [[ $DEV == "devel" ]]; then
            dnf -y -q install time
        fi
    fi
}

function do_Install_Extras(){
    echo
    echo '-- Installing Extra Dependencies --'

    if [[ $BASE == "debian" ]]; then
        # Distros development versions of needed libraries
        apt-get -y -qq install libgirepository1.0-dev > /dev/null

    elif [[ $BASE == "fedora" ]]; then
        # Distros development versions of needed libraries
        dnf -y -q install gobject-introspection-devel

        # Distros development versions of needed libraries
        dnf -y debuginfo-install glib2-devel gobject-introspection-devel gtk3-devel expat fontconfig cairo

        if [[ $STATIC == "settings" ]]; then
            # GNOME Settings dependencies
            dnf -y -q install accountsservice-devel cheese-libs-devel chrpath clutter-gtk-devel colord-devel  \
                          colord-gtk-devel cups-devel desktop-file-utils docbook-style-xsl gdk-pixbuf2-devel \
                          gettext git glib2-devel gnome-bluetooth-libs-devel gnome-desktop3-devel \
                          gnome-online-accounts-devel gnome-settings-daemon-devel grilo-devel \
                          gsettings-desktop-schemas-devel gtk3-devel ibus-devel intltool libcanberra-devel \
                          libgtop2-devel libgudev-devel libnma-devel libpwquality-devel libsmbclient-devel \
                          libsoup-devel libwacom-devel libX11-devel libXi-devel libxml2-devel libxslt \
                          libXxf86misc-devel meson ModemManager-glib-devel NetworkManager-libnm-devel \
                          polkit-devel pulseaudio-libs-devel upower-devel \
                          python3-dbusmock xorg-x11-server-Xvfb mesa-dri-drivers
        fi
    fi
}

function do_Install_Analyser(){
    echo
    echo '-- Installing Static Analysers --'
    mkdir -p /cwd

    if [[ $BASE == "fedora" ]]; then
        # Static analysers
        dnf -y -q install git cppcheck tokei nodejs python-devel

        # Install needed packages
        pip install cpplint
        npm install -g eslint
    fi
}
