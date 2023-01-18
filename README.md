# gail-container

This reporsitory maintains a docker image for running CI/CD of Hobot and Alf (and hopefully for other purposes in the future).

The main implementation can be found at the top-level [Dockerfile](./Dockerfile).

## How to update the docker

1. Update the [requirements.txt](./hobot_cicd/requirements.txt) and commit
2. Create a [new release](https://github.com/HorizonRoboticsInternal/gail-container/releases/new) on GitHub.
3. After the release is created, a [GitHub
   workflow](https://github.com/HorizonRoboticsInternal/gail-container/actions)
   will kick off to build the new docker images.
4. It takes about 10 minutes for the docker image to be built and
   pushed to our [GitHub
   packages](https://github.com/orgs/HorizonRoboticsInternal/packages).
   You will find the list of packages (i.e. docker images)
   [here](https://github.com/HorizonRoboticsInternal/gail-container/pkgs/container/gail-container).
   The one tagged with "latest" is the one that it just builds.
   
   [[./resources/images/gail_packages.jpg]]
   
   In the above example, you can now use 
   
   ```
   ghcr.io/horizonroboticsinternal/gail-container:2023.01.17
   ```
   
   to refer the docker image in your CI/CD GitHub action, or pull it for your local use.
   
## TODO

1. A more integrated and automatic way to sync dependencies of our projects.
2. Currently this is a **single image for all*. Adding options to create images for different projects.
3. Add a GPU version so that we can run trianing with it.
