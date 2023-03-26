FROM ubuntu:22.04

# update the package lists
RUN apt-get update

# install AZCLI
RUN apt-get install -y curl
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# install Terraform
RUN apt-get install -y gnupg software-properties-common
RUN apt-get install -y wget
RUN wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
RUN gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint
RUN echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
tee /etc/apt/sources.list.d/hashicorp.list
RUN apt-get update
RUN apt-get install -y terraform

# install Ansible
RUN add-apt-repository --yes --update ppa:ansible/ansible
RUN apt-get update
RUN apt install -y ansible

# set the working directory
WORKDIR /app

# copy any necessary files into the container
COPY . ./

# expose any necessary ports
EXPOSE 80

# set the command to run when the container starts
# CMD ["/bin/bash"]
#ENTRYPOINT service apache2 start && /bin/bash
ENTRYPOINT python3 -m http.server 80 --directory /tmp/ & /bin/bash
