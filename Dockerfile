FROM rocker/shiny-verse:latest

LABEL author="James Swift"
LABEL maintainer="James Swift"
LABEL name="Microbiome Webapp"
LABEL version="1.0"

RUN apt update
RUN apt upgrade -y
RUN apt install iputils-ping -y
RUN apt install cmake -y

COPY . /srv/shiny-server/microbiome_webapp/

RUN R -e "install.packages('renv')"
RUN R -e "renv::restore('/srv/shiny-server/microbiome_webapp/')"



# EXPOSE 3838

# CMD shiny-server 2>&1

