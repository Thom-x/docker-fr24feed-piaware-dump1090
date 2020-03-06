# Fr24feed and FlightAware with dump1090 as a Docker image

[![Build Status](https://travis-ci.org/Thom-x/docker-fr24feed-piaware-dump1090.svg?branch=master)](https://travis-ci.org/Thom-x/docker-fr24feed-piaware-dump1090)
![](https://images.microbadger.com/badges/image/thomx/fr24feed-piaware.svg)
![](https://images.microbadger.com/badges/version/thomx/fr24feed-piaware.svg)
![GitHub](https://img.shields.io/github/license/Thom-x/docker-fr24feed-piaware-dump1090)
![GitHub issues](https://img.shields.io/github/issues/Thom-x/docker-fr24feed-piaware-dump1090)

> Please consider following this project's author, [Thom-x](https://github.com/Thom-x), and consider starring the project to show your ❤️ and support.

Docker image of Fr24feed, FlightAware and dump1090.

Feed FlightRadar24 and FlightAware, allow you to see the positions of aircrafts on a map.

---

![Image of dump1090 webapp](https://raw.githubusercontent.com/Thom-x/docker-fr24feed-piaware-dump1090/master/screenshot.png)

# Requirements
- Docker
- RTL-SDR DVBT USB Dongle (RTL2832)

# Getting started

Run : 
```
docker run -d -p 8080:8080 -p 8754:8754 \
--device=/dev/bus/usb:/dev/bus/usb \
-v /path/to/your/upintheair.json:/usr/lib/fr24/public_html/upintheair.json \
-v /path/to/your/config.js:/usr/lib/fr24/public_html/config.js \
-e FR24FEED_FR24KEY=MY_SHARING_KEY \
-e PIAWARE_FEEDER_DASH_ID=MY_FEEDER_ID \
thomx/fr24feed-piaware
```

Go to http://dockerhost:8080 to view a map of reveived data.
Go to http://dockerhost:8754 to view fr24feed configuration panel.

*Note : remove `-v /path/to/your/upintheair.json:/usr/lib/fr24/public_html/upintheair.json` from the command line if you don't want to use this feature.*

# Configuration
## FlightAware
Register to https://flightaware.com/account/join/.

Add the environment variable `PIAWARE_FEEDER_DASH_ID` with your feeder id.

| Environment Variable                | Configuration property | Default value   |
|-------------------------------------|------------------------|-----------------|
| PIAWARE_FEEDER_DASH_ID              | feeder-id              | YOUR_FEEDER_ID  |
| PIAWARE_RECEIVER_DASH_TYPE          | receiver-type          | other           |
| PIAWARE_RECEIVER_DASH_HOST          | receiver-host          | 127.0.0.1       |
| PIAWARE_RECEIVER_DASH_PORT          | receiver-port          | 30005           |

And claim it on https://fr.flightaware.com/adsb/piaware/claim.

## FlightRadar24
Register to https://www.flightradar24.com/share-your-data and get a sharing key.

Add the environment variable `FR24FEED_FR24KEY` with your sharing key.


| Environment Variable                | Configuration property | Default value   |
|-------------------------------------|------------------------|-----------------|
| FR24FEED_RECEIVER                   | receiver               | beast-tcp       |
| FR24FEED_FR24KEY                    | fr24key                | YOUR_KEY_HERE   |
| FR24FEED_HOST                       | host                   | 127.0.0.1:30005 |
| FR24FEED_BS                         | bs                     | no              |
| FR24FEED_RAW                        | raw                    | no              |
| FR24FEED_LOGMODE                    | logmode                | 1               |
| FR24FEED_LOGPATH                    | logpath                | /tmp            |
| FR24FEED_MLAT                       | mlat                   | no              |
| FR24FEED_MLAT_DASH_WITHOUT_DASH_GPS | mlat-without-gps       | no              |

**Note** : you can add any property to either fr24feed or piaware configuration file by adding an environment variable sarting either `PIAWARE_...` or `FR24FEED_...`.

Example :
| Environment Variable                | Configuration property | value           | Configuration file    |
|-------------------------------------|------------------------|-----------------|-----------------------|
| FR24FEED_TEST_=value                | test-test              | value           | fr24feed.init         |
| FR24FEED_TEST_DASH_TEST=value       | test                   | value2          | fr24feed.init         |
| PIAWARE_TEST=value                  | test                   | value           | piaware.conf          |

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

# Build it yourself

Clone this repo.

```docker build . ```
