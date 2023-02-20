# dream container

### Host-based Gazebo
Note, you can run gazebo natively to get better performance and only need to set the gazebo partition before
launching.

```bash
export GZ_PARTITION=cognipilot
gz sim quad.sdf
```


## NVidia Container Toolkit
To run gazebo within the container you will need an nvidia graphics card and
should install the Nvidia Container Toolkit.

https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html


## Hardware Rendering

Create a docker override, this file will be ignored by .git so you
can use it as a location to put any customizations.

docker/docker-compose.override.yml

```yaml
services:

  dream:

    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
```

