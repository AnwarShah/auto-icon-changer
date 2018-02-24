# auto-icon-changer
A small script to automate icon themes for linux desktop (currently only on gnome desktop)

## Usage
```
USAGE: ruby icon_changer.rb -i (interactive mode)
 or    ruby icon_changer -d, --daemon [period in minute] (run in daemon mode)
 ```
 
 - Interactive mode will display a list of icon themes installed on your system in standard locations and enable you to change a theme
 - Daemon mode will automatically change the icon theme per minutes specified (or every 5 minutes when it's not specified)
 
 
