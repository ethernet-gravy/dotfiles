#!/usr/bin/env sh
lisgd -d /dev/input/by-id/usb-Wacom_Co._Ltd._Pen_and_multitouch_sensor-event-if00 -t 10 -T 5 -r 30 -g "1,RL,R,*,R,niri msg action focus-column-right" -g "1,LR,L,*,R,niri msg action focus-column-left" -g "1,DU,B,*,R,niri msg action open-overview" >> ~/output.txt
