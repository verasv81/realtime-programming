# Real-time Programming Lab1

Using Elixir programming language.

This app is gathering data from 10 sensors (light, wind speed, humidity, atmospheric pressure and temperature, and the timestamp when the event was sent) and convert these readings into a weather forecast that will be updated every 5 seconds.

## Installation
### Run Local

Get project from git:
```bash 
  git pull https://github.com/verasv81/realtime-programming.git
```
Run using: 
```bash
  docker-compose up
```

**or**

```shell
 docker pull alexburlacu/rtp-server
 docker run -p 4000:4000 --rm alexburlacu/rtp-server
 //another terminal
  mix run
```

### Using Docker images

In different terminals run the following to commands:

**For Data Server**
```bash
 docker pull alexburlacu/rtp-server
 docker run -p 4000:4000 --rm alexburlacu/rtp-server
```

**For Forecast**
```bash
 docker pull verasv997/rtp-lab1-forecast:1.1
 docker run -p 5000:5000 --rm verasv997/rtp-lab1-forecast:1.1
```
