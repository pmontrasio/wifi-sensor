# Sensor 

This is a project forked from https://github.com/pmontrasio/decibel which was a WiFi dbm meter demoed at http://www.italian-elixir.org/ running on a Raspberry Pi 3. Slides at https://connettiva.eu/elixirday2016/

This version of Sensor sets the antenna in monitor mode and it scans the 2.4 WiFi channels, 5 seconds per channel.
It counts the number of unique mac addresses listed as source or destination of the IP packets seen by antenna.
It uploads the count (not the addresses!) to a server every minute. This is something the original project didn't do.

## Prerequisites

A WiFi card with support for monitor mode. See the section about Cards below.


## Installation

To install Elixir on the Raspberry PI check the file ```INSTALL.md```. It requires compiling Erlang from sources and adding Elixir to it.

To install on a Linux, Mac or Windows check http://elixir-lang.org/

*This software has been tested only on Linux, Ubuntu and Raspbian*. If you make it run on MacOS or Windows please share your experience.

We need to give some capability to ```beam.smp``` (the multiprocessor one), which is used by Erlang and Elixir on the Raspberry.

```
sudo setcap cap_net_admin=ep /usr/local/lib/erlang/erts-8.1/bin/beam.smp
```

and to remove the capability

```
sudo setcap -r /usr/local/lib/erlang/bin/erl
sudo setcap -r $HOME/elixir/bin/iex
```

## Run

Once you have Elixir, enter the directory of this project and

```
mkfifo pipe
cat <<EOF > config/secret.exs
# This is the file for the secrets of your project.
# You don't check this into version control.

use Mix.Config

config :sensor,
  control_pipe: "/home/you/path/to/sensor/pipe"
EOF
mix sensor wlan1 https://your.server/url
```

Send a RETURN at any time to the ```pipe``` named pipe in the project directory to perform a graceful shutdown, which will reset the WiFi card to managed mode. This will do:

```
echo stop > pipe
```

## Internals

The internals of the application are discussed in the TUTORIAL.md file.


## Autostart

To autostart the application at boot fix the pathnames of ```systemd/sensor.service``` and the other scripts in the ```systemd``` directory to suit the path for your installation. Check also that ```User=pi``` in ```systemd/sensor.service``` matches the one you are using to run the application. Then

```
cp systemd/sensor.service /etc/systemd/system/sensor.service
sudo chmod 644 !$
sudo chown root.root !$
sudo systemctl daemon-reload
sudo systemctl enable sensor
sudo systemctl start sensor
```

And 

```
sudo journalctl -f -u sensor.service
sudo systemctl stop sensor
```

Now you can try ```echo stop > pipe``` to bring down the application and see systemd bring it up again.

You should have these processes running.

```
pi       24546     1  0 21:27 ?        00:00:00 /bin/bash /home/pi/codemotion/sensor/systemd/exec_start
pi       24550 24546 17 21:27 ?        00:00:03 /usr/local/lib/erlang/erts-8.1/bin/beam.smp -- -root /usr/local/lib/erlang 
pi       24572 24550  0 21:27 ?        00:00:00 erl_child_setup 1024
pi       24585 24572  0 21:27 ?        00:00:00 inet_gethost 4
pi       24586 24585  0 21:27 ?        00:00:00 inet_gethost 4
root     24774 24572  0 21:27 ?        00:00:00 sudo /home/pi/codemotion/sensor/_build/dev/lib/epcap/priv/epcap -t 0 -d /ho
nobody   24801 24774  0 21:27 ?        00:00:00 /home/pi/codemotion/sensor/_build/dev/lib/epcap/priv/epcap -t 0 -d /home/pi
nobody   24900 24801  1 21:27 ?        00:00:00 /home/pi/codemotion/sensor/_build/dev/lib/epcap/priv/epcap -t 0 -d /home/pi
```


# WiFi adapters with monitor mode

## Cards

Sensor was run again on a Raspberry PI 3.

The internal WiFi adapter of the Raspberry Pi 3 doesn't have monitor mode. I used TP-LINK TL-WN722N, which works well but it works only on the 2.4 GHz band.

https://www.raspberrypi.org/forums/viewtopic.php?f=28&t=49432

These cards are known to work with Kali Linux, but they are not certified to work with the Raspberry
http://www.wirelesshack.org/top-kali-linux-compatible-usb-adapters-dongles-2015.html

It's the chip inside the card that makes the difference. The good chips apparently are

* Atheros AR9271
* Ralink RT3070
* Ralink RT3572
* Realtek 8187L (Wireless G adapters)

https://github.com/raspberrypi/linux/issues/369
It seems that the driver for the rtl8192cu works now.


## More on monitor mode

https://en.wikipedia.org/wiki/Monitor_mode

Monitor mode is one of the seven modes that 802.11 wireless cards can operate in: Master (acting as an access point), Managed (client, also known as station), Ad hoc, Mesh, Repeater, Promiscuous, and Monitor mode.

You can use it to listen to all packets but you're not connected to an access point so you can't decrypt them.
You can only look at public information such as mac addresses.


# TODO

Spend more time on channels with more traffic.
