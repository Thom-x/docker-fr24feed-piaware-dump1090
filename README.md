[![Build Status](https://travis-ci.org/Thom-x/docker-fr24feed-piaware-dump1090.svg?branch=master)](https://travis-ci.org/Thom-x/docker-fr24feed-piaware-dump1090)
![](https://images.microbadger.com/badges/image/thomx/fr24feed-piaware.svg)
![](https://images.microbadger.com/badges/version/thomx/fr24feed-piaware.svg)

# Fr24feed and FlightAware with dump1090 as a Docker image
Docker image of Fr24feed, FlightAware and dump1090.

Feed FlightRadar24 and FlightAware, allow you to see the positions of aircrafts on a map.

![Image of dump1090 webapp](https://raw.githubusercontent.com/Thom-x/docker-fr24feed-piaware-dump1090/master/screenshot.png)

# Requirements
- Docker
- RTL-SDR DVBT USB Dongle (RTL2832)

# Install from image

## FlightAware
Register to https://flightaware.com/account/join/.

Download and edit [`piaware.conf`](https://raw.githubusercontent.com/Thom-x/docker-fr24feed-piaware-dump1090/master/piaware.conf)

Replace `flightaware-user YOUR_USERNAME` with your username (ex: `flightaware-user JohnDoe`), `flightaware-password YOUR_PASSWORD` with your password (ex: `flightaware-password azerty`) and `feeder-id YOUR_FEEDER_ID` with your feeder id (ex: `feeder-id ffffffff-ffff-ffff-ffff-ffffffffffff`).

## FlightRadar24
Register to https://www.flightradar24.com/share-your-data and get a sharing key.

Download and edit [`fr24feed.ini`](https://raw.githubusercontent.com/Thom-x/docker-fr24feed-piaware-dump1090/master/fr24feed.ini)
Replace `fr24key="YOUR_KEY_HERE"` with your key (ex: `fr24key="a23165za4za56"`).

## Dump1090
### Receiver location
Download and edit [`config.js`](https://raw.githubusercontent.com/Thom-x/docker-fr24feed-piaware-dump1090/master/config.js) to suite your receiver location and name:
```javascript
SiteShow    = true;           // true to show a center marker
SiteLat     = 47;            // position of the marker
SiteLon     = 2.5;
SiteName    = "Home"; // tooltip of the marker
```
### Terrain-limit rings (optional):
If you don't need this feature ignore this.

Create a panorama for your receiver location on http://www.heywhatsthat.com.

Download http://www.heywhatsthat.com/api/upintheair.json?id=XXXX&refraction=0.25&alts=1000,10000 as upintheair.json.

*Note : the "id" value XXXX correspond to the URL at the top of the panorama http://www.heywhatsthat.com/?view=XXXX, altitudes are in meters, you can specify a list of altitudes.*
## Installation

Run : 
```
docker run -d -p 8080:8080 -p 8754:8754 \
--device=/dev/bus/usb:/dev/bus/usb \
-v /path/to/your/upintheair.json:/usr/lib/fr24/public_html/upintheair.json \
-v /path/to/your/piaware.conf:/etc/piaware.conf \
-v /path/to/your/config.js:/usr/lib/fr24/public_html/config.js \
-v /path/to/your/fr24feed.ini:/etc/fr24feed.ini \
thomx/fr24feed-piaware
```
*Note : remove `-v /path/to/your/upintheair.json:/usr/lib/fr24/public_html/upintheair.json` from the command line if you don't want to use this feature.*
# Build it yourself
## FlightAware
Register to https://flightaware.com/account/join/.

Edit `piaware.conf` and replace `user YOUR_USERNAME` with your username (ex: `user JohnDoe`) and `password YOUR_PASSWORD` with your password (ex: `password azerty`).
## Dump1090
### Receiver location
Edit `config.js` to suite your receiver location and name:
```javascript
SiteShow    = true;           // true to show a center marker
SiteLat     = 47;            // position of the marker
SiteLon     = 2.5;
SiteName    = "Home"; // tooltip of the marker
```
## FlightRadar24
Register to https://www.flightradar24.com/share-your-data and get a sharing key.

Edit `fr24feed.ini` and replace `fr24key="YOUR_KEY_HERE"` with your key (ex: `fr24key="a23165za4za56"`).
## Dump1090
### Receiver location
Edit `config.js` to suite your receiver location and name:
```javascript
SiteShow    = true;           // true to show a center marker
SiteLat     = 47;            // position of the marker
SiteLon     = 2.5;
SiteName    = "Home"; // tooltip of the marker
```
### Terrain-limit rings (optional):
If you don't need this feature ignore this.

Create a panorama for your receiver location on http://www.heywhatsthat.com.

Download http://www.heywhatsthat.com/api/upintheair.json?id=XXXX&refraction=0.25&alts=1000,10000 place the file upintheair.json in this directory and uncomment `#COPY upintheair.json /usr/lib/fr24/...` from Dockerfile.

*Note : the "id" value XXXX correspond to the URL at the top of the panorama http://www.heywhatsthat.com/?view=XXXX, altitudes are in meters, you can specify a list of altitudes.*
## Installation
Run : `docker-compose up`

# Usage
Go to http://dockerhost:8080 to view a map of reveived data.

Go to http://dockerhost:8754 to view fr24feed configuration panel.
