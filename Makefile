# Ping this machine to get its IP, and add a :0 to that to refer to the primary X11 display on this machine.
TCP_DISPLAY:=$(shell echo `ping -c 1 $$(hostname) | grep "from" | cut -d' ' -f4 | cut -d: -f1`:0)

# Obtain the MIT_MAGIC_COOKIE line from xauth for the X11 display on this machine 
XAUTH:=$(shell xauth -n list :0.0 | cut -d' ' -f2-)

run:
	# Create an .Xauthority file for this display using a TCP socket rather than the unix domain socket which is not docker friendly
	xauth -f volumes/.Xauthority add $(TCP_DISPLAY) $(XAUTH)

	make clean

	# Create the tello facetrack container, using the TCP_DISPLAY as the X11 display
	DISPLAY=$(TCP_DISPLAY) docker-compose up -d

	# Tail the logs. This tail can be stopped with cntl-C, and the facetrack container will continue in the background
	docker-compose logs -f

# Build the container image from source using the Dockerfile
build:
	docker-compose build

# Pull the container image from the Docker registry
pull:
	docker pull sofwerx/tello-facetrack:latest

# Cleanup any existing running container
clean:
	docker-compose stop
	docker-compose rm -f

# Attach a shell to the running facetrack container
attach:
	docker exec -ti facetrack bash