FROM ubuntu:22.04

# update the package lists
RUN apt-get update

# install any necessary packages
RUN apt-get install -y curl
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# set the working directory
WORKDIR /app

# copy any necessary files into the container
# COPY <local-path> <container-path>

# expose any necessary ports
EXPOSE 80

# set the command to run when the container starts
# CMD ["/bin/bash"]
#ENTRYPOINT service apache2 start && /bin/bash
ENTRYPOINT python3 -m http.server 80 --directory /tmp/ & /bin/bash