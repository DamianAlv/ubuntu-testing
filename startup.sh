#!/bin/bash

if [ ! -f home/.vnc/passwd ] ; then

    if  [ -z "$PASSWORD" ] ; then
        PASSWORD=`pwgen -c -n -1 12`
        echo -e "PASSWORD = $PASSWORD" > home/password.txt
    fi

    echo "$USER:$PASSWORD" | chpasswd

    # Set up vncserver
    su $USER -c "mkdir home/.vnc && echo '$PASSWORD' | vncpasswd -f > home/.vnc/passwd && chmod 600 home/.vnc/passwd && touch home/.Xresources"
    chown -R $USER:$USER $HOME

    if [ ! -z "$SUDO" ]; then
        case "$SUDO" in
            [yY]|[yY][eE][sS])
                adduser $USER sudo
        esac
    fi

else

    VNC_PID=`find home/.vnc -name '*.pid'`
    if [ ! -z "$VNC_PID" ] ; then
        vncserver -kill :1
        rm -rf /tmp/.X1*
    fi

fi

if [ ! -z "$NGROK" ] ; then
        case "$NGROK" in
            [yY]|[yY][eE][sS])
                su ubuntu -c "home/ngrok/ngrok http 6080 --log home/ngrok/ngrok.log --log-format json" &
                sleep 5
                NGROK_URL=`curl -s http://127.0.0.1:4040/status | grep -P "http://.*?ngrok.io" -oh`
                su ubuntu -c "echo -e 'Ngrok URL = $NGROK_URL/vnc.html' > home/ngrok/Ngrok_URL.txt"
        esac
fi

/usr/bin/supervisord -n
