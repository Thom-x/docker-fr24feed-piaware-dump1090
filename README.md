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
	-e "FR24FEED_FR24KEY=MY_SHARING_KEY" \
	-e "PIAWARE_FEEDER_DASH_ID=MY_FEEDER_ID" \
	-e "HTML_SITE_LAT=MY_SITE_LAT" \
	-e "HTML_SITE_LON=MY_SITE_LON" \
	-e "HTML_SITE_NAME=MY_SITE_NAME" \
	-e "PANORAMA_ID=MY_PANORAMA_ID" \
	thomx/fr24feed-piaware
```

Go to http://dockerhost:8080 to view a map of reveived data.
Go to http://dockerhost:8754 to view fr24feed configuration panel.

*Note : remove `-e "PANORAMA_ID=MY_PANORAMA_ID"` from the command line if you don't want to use this feature.*

# Configuration

## Common

To disable starting a service you can add an environement variable :

| Environment Variable                  | Value                    | Description               |
|---------------------------------------|--------------------------|---------------------------|
| `SERVICE_ENABLE_DUMP1090`             | `false`                  | Disable dump1090 service  |
| `SERVICE_ENABLE_PIAWARE`              | `false`                  | Disable piaware service   |
| `SERVICE_ENABLE_FR24FEED`             | `false`                  | Disable fr24feed service  |
| `SERVICE_ENABLE_HTTP`                 | `false`                  | Disable http service      |

Ex : `-e "SERVICE_ENABLE_HTTP=false"`


## FlightAware

Resgister on https://flightaware.com/account/join/.

Run :
```
docker run -it --rm \
	-e "SERVICE_ENABLE_DUMP1090=false" \
	-e "SERVICE_ENABLE_HTTP=false" \
	-e "SERVICE_ENABLE_FR24FEED=false" \
	thomx/fr24feed-piaware /bin/bash
```
When the container starts you should see the feeder id, note it. Wait 5 minutes and you should see a new receiver at https://fr.flightaware.com/adsb/piaware/claim (use the same IP as your docker host), claim it and exit the container.

Add the environment variable `PIAWARE_FEEDER_DASH_ID` with your feeder id.

| Environment Variable                  | Configuration property   | Default value     |
|---------------------------------------|--------------------------|-------------------|
| `PIAWARE_FEEDER_DASH_ID`              | `feeder-id`              | `YOUR_FEEDER_ID`  |
| `PIAWARE_RECEIVER_DASH_TYPE`          | `receiver-type`          | `other`           |
| `PIAWARE_RECEIVER_DASH_HOST`          | `receiver-host`          | `127.0.0.1`       |
| `PIAWARE_RECEIVER_DASH_PORT`          | `receiver-port`          | `30005`           |


Ex : `-e "PIAWARE_RECEIVER_DASH_TYPE=other"`

## FlightRadar24

Run :
```
docker run -it --rm \
	-e "SERVICE_ENABLE_DUMP1090=false" \
	-e "SERVICE_ENABLE_HTTP=false" \
	-e "SERVICE_ENABLE_PIAWARE=false" \
	-e "SERVICE_ENABLE_FR24FEED=false" \
	thomx/fr24feed-piaware /bin/bash
```

Then : `/fr24feed/fr24feed/fr24feed --signup` and follow the instructions, for technical steps, your answer doesn't matter we just need the sharing key at the end.

Finally to see the sharing key run `cat /etc/fr24feed.ini`, you can now exit the container.

Add the environment variable `FR24FEED_FR24KEY` with your sharing key.


| Environment Variable                  | Configuration property   | Default value     |
|---------------------------------------|--------------------------|-------------------|
| `FR24FEED_RECEIVER`                   | `receiver`               | `beast-tcp`       |
| `FR24FEED_FR24KEY`                    | `fr24key`                | `YOUR_KEY_HERE`   |
| `FR24FEED_HOST`                       | `host`                   | `127.0.0.1:30005` |
| `FR24FEED_BS`                         | `bs`                     | `no`              |
| `FR24FEED_RAW`                        | `raw`                    | `no`              |
| `FR24FEED_LOGMODE`                    | `logmode`                | `1`               |
| `FR24FEED_LOGPATH`                    | `logpath`                | `/tmp`            |
| `FR24FEED_MLAT`                       | `mlat`                   | `yes`             |
| `FR24FEED_MLAT_DASH_WITHOUT_DASH_GPS` | `mlat-without-gps`       | `yes`             |

Ex : `-e "FR24FEED_FR24KEY=0123456789"`

## Add custom properties

**Note** : you can add any property to either fr24feed or piaware configuration file by adding an environment variable starting with `PIAWARE_...` or `FR24FEED_...`.

Example :

| Environment Variable                  | Configuration property   | value             | Configuration file      |
|---------------------------------------|--------------------------|-------------------|-------------------------|
| `FR24FEED_TEST=value`                 | `test`                   | `value`           | `fr24feed.init`         |
| `FR24FEED_TEST_DASH_TEST=value`       | `test-test`              | `value2`          | `fr24feed.init`         |
| `PIAWARE_TEST=value`                  | `test`                   | `value`           | `piaware.conf`          |

## Dump1090
### Receiver location

| Environment Variable                  | Default value            |
|---------------------------------------|--------------------------|
| `HTML_SITE_LAT`                       | `45.0`                   |
| `HTML_SITE_LON`                       | `9.0`                    |
| `HTML_SITE_NAME`                      | `My Radar Site`          |

Ex : `-e "HTML_SITE_NAME=My site"`

### Terrain-limit rings (optional):
If you don't need this feature ignore this.

Create a panorama for your receiver location on http://www.heywhatsthat.com.

| Environment Variable                  | Default value            | Description                                 |
|---------------------------------------|--------------------------|---------------------------------------------|
| `PANORAMA_ID`                         |                          | Panorama id                                 |
| `PANORAMA_ALTS`                       | `1000,10000`             | Comma seperated list of altitudes in meter  |

*Note : the panorama id value correspond to the URL at the top of the panorama http://www.heywhatsthat.com/?view=XXXX, altitudes are in meters, you can specify a list of altitudes.*

Ex : `-e "PANORAMA_ID=FRUXK2G7"`

If you don't want to download the limit every time you bring up the container you can download `http://www.heywhatsthat.com/api/upintheair.json?id=${PANORAMA_ID}&refraction=0.25&alts=${PANORAMA_ALTS}` as upintheair.json and mount it in `/usr/lib/fr24/public_html/upintheair.json`.

# Build it yourself

Clone this repo.

```docker build . ```
