# installation-scripts

As the squeezebox platform is effectively now end of life, until something better turns up I wanted to reduce my dependency on proprietary hardware and move everything to the more open Raspberry Pi platform. Currently I have a Raspberry Pi serving music that is connected to various Squeezebox devices (Classic and Radio). The Classic is wired in to my M-DAC which in turn feeds a power amplifier.

Historically a stumbling block in all of this has been getting  USB audio output from the Raspberry Pi to play nicely with my Audiolab M-DAC. However, it appears that with either latest Rasbian updates or the Raspberry Pi 2 hardware, this is now resolved and I can stream bit perfect music to the M-DAC using Squeezelite running on the Raspberry Pi connected to the DAC via USB. The M-DAC has a handy test feature that enables you to verify with predefined waveforms that the transferred sound is indeed bit perfect. Happy days!

Part of the reason I want to stick with Raspberry Pi is that I have all sorts of nice hardware integration features via the RPi GPIO that allows me to control various parts of my setup. These include:

- 5v line trigger to bring my Bryston power amp in and out of standby (it consumes a lot of juice!)
- 433Mhz transmitter to control a 4-way power adapter to switch M-DAC off at the mains (standby is not controllable via the supplied IR remote)
- provide IR repeater functionality (for YouView box and M-DAC) so that these can all be hidden away in the attic (this is based on standard blaster functionality provided by the Squeezebox combined with JOHN SMITHs excellent IRBlaster plugin for squeezeserver)
- provide an additional web interface for iPhone to generate IR codes controlling various devices over wifi (including M-DAC, Squeezebox, and YouView box). This is currently achieved using a customised version of JOHN SMITHs plugin and the blaster functionality provided by Squeezebox Classic. My plan is to convert this to LIRC running on RPi.

Given the increased reliance on RPi the key thing is to document the setup and make sure that I am not dependent on any external repositories to install. Given the product is end of life - these may get moved around or disappear entirely! From my perspective, documenting the process means ensuring that the entire install can be scripted. That way in 10 years time when something breaks or needs to be modified I have everything required to get up and running again. Therefore I have hosted all source code in my own github repo and all binaries are publically hosted in Amazon S3.

Key requirements are: 
- Squeezeserver 7.8.0 running on Raspberry Pi 2
- Squeezelite running on the same RPi
- Latest BBC iPlayer and 3rd party Spotify plugins from triode (with HLS fix natively applied in iPlayer plugin)
- wiringPi and Codesend (433Utils) to provide GPIO access and control of 433MHz transmitter devices (these are a couple of quid on Amazon)

Right now the basic installation process is to clone this git repo on to your RPi, change in to the newly created directory and run the install.sh command. I'll try to provide further detail later...



