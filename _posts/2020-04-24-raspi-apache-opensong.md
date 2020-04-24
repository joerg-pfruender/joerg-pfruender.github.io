---
layout: post
title:  "Raspberry Pi and Smartphones as 21st centuries songbook"
date:   2020-04-24 19:00:00 +0200
categories: [raspberrypi, songbook]
tags: [raspberrypi, opensong, apache]
---

Since many years we have been using [OpenSong&#8599;](http://www.opensong.org/) to display songs in the church via projector.

But that has two disadvantages:

1. Someone always needs to do the job to prepare the playlist for the next service.
2. You need a wall and a projector do display it.

In former times we all had songbooks and everyone looked for the songs on his own.
Nowadays everybody has smartphones. Whatabout using them as songbooks?

You just need to have a webserver that anybody can access in your church's wifi.

# 1. Use a cheap raspberry pi

* Since witten songs do not have a big footprint on data you can just buy a cheap [Raspberry Pi&#8599;](https://www.raspberrypi.org/).
* Install [Raspbian&#8599;](https://www.raspberrypi.org/downloads/) on it.
* During installation you should choose a really good password.

During the next steps you will need to use the terminal for setup. In these cases I will write the commands like that:

    $ that-is-my-terminal-command

# 2. Change hostname 

Use `raspi-conig` to change the hostname to `songbook`

    $ sudo raspi-config

* Follow the steps on [https://pimylifeup.com/raspberry-pi-hostname/#raspiconfighostname &#8599;](https://pimylifeup.com/raspberry-pi-hostname/#raspiconfighostname).
* Reboot
* Test if the new name works:

        $ hostname
        
  It should print `songbook`
  
* Get the pi address of your raspberry pi

        $ hostname -i
        
  It should display 4 numbers separated with dots like `192.168.0.34`, that is the ip address. Write it down.  


# 3. Install Apache

More information about apache on raspberry pi can be found on [https://www.raspberrypi.org/documentation/remote-access/web-server/apache.md &#8599;](https://www.raspberrypi.org/documentation/remote-access/web-server/apache.md)

       $ sudo apt update
       $ sudo apt install apache2 -y

After installation go to your webbrowser (Firefox / Chromium etc. ) and insert `http://songbook` into the url line.
It should show somethink like

![Apache index.html](/assets/songbook/songbook-apache.png)

* Make sure that there is really and `http://` in front of "songbook"
* Make sure your browser and your raspberry pi are in the same network (wifi).
* Try the ip address instead of `songbook`.

The page you are viewing can be found in `/var/www/html/index.html`.

# 3. Activate ssh

Since this should be a server where keyboard, mouse and monitor are not always connected we need remote access. 
Use raspi-config to active ssh:

    $ sudo raspi-config
    
![config ssh 1](/assets/songbook/raspi-config-ssh1.png)
![config ssh 2](/assets/songbook/raspi-config-ssh2.png)
![config ssh 3](/assets/songbook/raspi-config-ssh3.png)

After activating ssh you can try to ssh to the raspberry pi from another computer:

* On Windows you can use [Putty&#8599;](https://www.putty.org/).
* On MacOS and Linux ssh is built in.

In our example it is:

    $ ssh pi@192.168.0.34

Then it will ask you a question, say yes if it will be your first connection between those two computers.

# 4. Copy the files

1. Now we create a new directory `words` inside the apache's directory: Inside the ssh shell use the commands:

        $ cd /var/www/html/
        $ sudo rm index.html
        $ sudo mkdir words
        $ sudo chown pi:pi words
        
   If you have some images or pds with chords you can also create an other folder `chords`:

        $ cd /var/www/html/
        $ sudo mkdir chords
        $ sudo chown pi:pi chords
 
2. Since we activated `ssh` we can now use `scp` to copy the files.
 
    * On Windows you can use [WinSCP&#8599;](https://winscp.net/)
    * On MacOX and Linux `scp` is built in.
  
   Go to the directory, where your [OpenSong&#8599;](http://www.opensong.org/) files are. There should be an directory "songs". Go into that directory. In our example it is:
   
        $ scp * pi@192.168.0.34:/var/www/html/words/
        
   You should replace `192.168.0.34` with the ip of your own raspberry pi.
   
   You can do that with some images and the directory "chords" accordingly.
   
3. Test the installation with your browser again: `http://songbook`. You should see something like:

   ![Apache Songs](/assets/songbook/apache2.png)
   
   If you click on "words" you should see your songs. If you click on one song, you should be able to view it.
   

Until now, that is still a bit ugly.
Let's pimp that a bit:

# Nicer layout for OpenSong songs

A really simple approach is injecting some css to the xml files.
That is not perfect, but a first start:

1. create a file `opensong.css`:

        * {
          font-family: Helvetica,sans-serif;
          background-color: #ffffff;
          color: #000000;
          font-size: 14px;
          display: block;
          margin-bottom: 4px;
        }
        
        title {
          font-size: 18px;    
        }
        
        author {
          font-size: 16px;    
        }
        
        author::before {
            content: "Author: ";
        }
        
        copyright {
          font-size: 16px;    
        }
        
        copyright::before {
            content: "Copyright: ";
        }
        
        
        ccli::before {
            content: "CCLI-Licence: ";
        }
        
        
        capo, tempo, timesig, theme, alttheme, user1, user2, user2 {
          display: none;
        }
        
        presentation {
           font-family: Courier;
        }
        
        presentation::before {
            content: "Order: ";
        }
        
        lyrics {
          font-family: Courier;
          white-space: pre;
          font-size: 15px;
        }


2. Copy that file into the folder with the other opensong files using scp.
3. Install mod_substitute on the raspberry pi's apache:
    
        $ sudo a2enmod substitute
        
4. Edit `/etc/apache2/apache2.conf` using nano:
        
        $ sudo nano /etc/apache2/apache2.conf
        
   Look for some lines starting with `<Directory` .
   At the bottom of that section add:
   
       <Directory /var/www/html/words/>
         SetOutputFilter SUBSTITUTE 
         Substitute "s|<?xml version=\"1.0\" encoding=\"UTF-8\"?>|<?xml version=\"1.0\" encoding=\"UTF-8\"?><?xml-stylesheet type=\"text/css\" href=\"opensong.css\"?>|ni"
       </Directory>

    
   ![Nano](/assets/songbook/songbook-ssh-nano.png)
   
   Save the file using CTRL-X and Y .   
   
5. Restart apache2:

        $ sudo /etc/init.d/apache2 stop
        $ sudo /etc/init.d/apache2 start

6. Test the new configuration `http://songbook`. The OpenSong files should now look like

   ![Song](/assets/songbook/what_a_friend.png)
   
More about `mod_substitute` can be found on [https://www.ollegustafsson.com/en/fun-with-mod-substitute/ &#8599;](https://www.ollegustafsson.com/en/fun-with-mod-substitute/)

# Last advice

You can now use `ssh` and `scp` for complete administration. You can plug of keyboard and mouse and monitor.
To shutdown the raspberry pi simply type in the ssh console

        $ sudo shutdown -h now
        
You should update the rasberry pi every few days:

        $ sudo apt-get update
        $ sudo apt-get upgrade

That's the first part. I will continue that project in a later blog post. 

*Any comments or suggestions? Leave an issue or a pull request!*
