# Fr24feed with dump1090-mutability Docker image
Docker image of fr24feed and dump1090-mutability.

Feed FlightRadar24 and see the positions of aircraft on a Google Maps map.

# Requirements
- Docker
- RTL-SDR DVBT USB Dongle (RTL2832)

# From image

## FlightRadar24
Register to https://www.flightradar24.com/share-your-data and get a sharing key.

Download and edit https://raw.githubusercontent.com/Thom-x/docker-fr24feed-dump1090-mutability/master/fr24feed.ini
Replace `fr24key="YOUR_KEY_HERE"` with your key (ex: `fr24key="a23165za4za56"`).

## Dump1090
### Receiver location
Download and edit https://raw.githubusercontent.com/Thom-x/docker-fr24feed-dump1090-mutability/master/config.jsto suite your receiver location and name:

```
SiteShow    = true;           // true to show a center marker
SiteLat     = 47;            // position of the marker
SiteLon     = 2.5;
SiteName    = "Home"; // tooltip of the marker
```

### Terrain-limit rings (optional):
If you don't need this feature simply delete the `upintheair.json` file or else
create a panorama for your receiver location on **http://www.heywhatsthat.com**

*Note the "view" value from the URL at the top of the panorama*
i.e. the XXXX in http://www.heywhatsthat.com/?view=XXXX
**Download http://www.heywhatsthat.com/api/upintheair.json?id=XXXX&refraction=0.25&alts=3048,9144 and replace upintheair.json in this directory**.
NB: altitudes are in _meters_, you can specify a list of altitudes

## Installation

Run : 
```
docker run -d -p 8080:8080 -p 8754:8754 \
--device=/dev/bus/usb:/dev/bus/usb \
-v /path/to/your/config.js:/usr/lib/fr24/public_html/config.js \
-v /path/to/your/upintheair.json:/usr/lib/fr24/public_html/upintheair.json \
-v /path/to/your/fr24feed.ini:/etc/fr24feed.ini \
thomx/fr24feed
```

# Build it yourself
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
Create a panorama for your receiver location on http://www.heywhatsthat.com.

Download http://www.heywhatsthat.com/api/upintheair.json?id=XXXX&refraction=0.25&alts=3048,9144 and place it in this directory (altitudes are in meters, you can specify a list of altitudes).

*Note : XXXX is the "view" value from the URL at the top of the panorama XXXX in http://www.heywhatsthat.com/?view=XXXX*
## Installation
Run : `docker-compose up`

# Usage
Go to http://dockerhost:8080 to view a map of reveived data.

Go to http://dockerhost:8754 to view fr24feed configuration panel.
