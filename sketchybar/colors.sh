#!/bin/bash



# Check is dark mode enabled
if [[ $(defaults read -g AppleInterfaceStyle 2> /dev/null) == "Dark" ]]; then
    export BLACK=0xff232634
    export WHITE=0xffcad3f5
    # export RED=0xffe78284
    export RED=0xffeebebe
    export GREEN=0xffa6d189
    export BLUE=0xff8caaee
    export YELLOW=0xffe5c890
    export ORANGE=0xffef9f76
    export MAGENTA=0xffc6a0f6
    export GREY=0xff939ab7
    export TRANSPARENT=0x00000000
    export BAR_COLOR=0xff1e1e2e
    # export BAR_BORDER_COLOR=0xffeebebe #0xa024273a
    export BAR_BORDER_COLOR=0xffbabbf1
    export ICON_COLOR=$WHITE # Color of all icons
    export LABEL_COLOR=$WHITE # Color of all labels
    export BACKGROUND_1=0xff303446
    export BACKGROUND_2=0xff232634
    export POPUP_BACKGROUND_COLOR=0xff1e1e2e
    export POPUP_BORDER_COLOR=$WHITE
    export SHADOW_COLOR=$BLACK
else
    export BLACK=0xff181926
    export WHITE=0xff4c4f69
    export RED=0xffe64553
    export GREEN=0xff40a02b
    export BLUE=0xff7287fd
    export YELLOW=0xffdf8e1d
    export ORANGE=0xfffe640b
    export MAGENTA=0xff209fb5
    export GREY=0xffacb0be
    export TRANSPARENT=0x00000000
    export BAR_COLOR=0xffeff1f5
    # export BAR_BORDER_COLOR=0xffdce0e8 #0xa024273a
    export BAR_BORDER_COLOR=0xffbabbf1
    export ICON_COLOR=0xff7287fd # Color of all icons
    export LABEL_COLOR=0xff7287fd # Color of all labels
    export BACKGROUND_1=0xffdce0e8
    export BACKGROUND_2=0xffccd0da
    export POPUP_BACKGROUND_COLOR=0xffdce0e8
    export POPUP_BORDER_COLOR=0xff7287fd
    export SHADOW_COLOR=$BLACK
fi

