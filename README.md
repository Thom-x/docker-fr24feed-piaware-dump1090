# Fr24feed with dump1090-mutability Docker image
Docker image of fr24feed and dump1090-mutability.

Feed FlightRadar24 and see the positions of aircraft on a Google Maps map.

# Requirements
- Docker
- RTL-SDR DVBT USB Dongle (RTL2832)

# Configuration
## FlightRadar24
Register to https://www.flightradar24.com/share-your-data and get a sharing key.

Edit `fr24feed.ini` and replace `fr24key="YOUR_KEY_HERE"` with your key (ex: `fr24key="a23165za4za56"`).
## Dump1090
### Receiver location :
Edit `config.js` to suite your receiver location and name:
```javascript
SiteShow    = true;           // true to show a center marker
SiteLat     = 47.175718;            // position of the marker
SiteLon     = -1.542872;
SiteName    = "Maison"; // tooltip of the marker 
```
### Terrain-limit rings (optional):
Create a panorama for your receiver location on **http://www.heywhatsthat.com**

*Note the "view" value from the URL at the top of the panorama
i.e. the XXXX in http://www.heywhatsthat.com/?view=XXXX*

**Download http://www.heywhatsthat.com/api/upintheair.json?id=XXXX&refraction=0.25&alts=3048,9144 and place it in this directory**.
NB: altitudes are in _meters_, you can specify a list of altitudes
# Installation
Run : `docker-compose up`
# Usage
Go to http://dockerhost:8080 to view a map of reveived data.

Go to http://dockerhost:8754 to view fr24feed configuration panel.

# TL;DR
Edit `fr24feed.ini` and replace `fr24key="YOUR_KEY_HERE"` with your key.

Edit `config.js` and replace your receiver position

Go to  http://www.heywhatsthat.com and get your panorama json profile.

Run : `docker-compose up`
