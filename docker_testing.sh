echo "Check all necessary R packages are added to Dockerfile."
echo ""
echo "> Stopping container if running"
sudo docker container stop microbiome-webapp
echo ""
echo "> Removing container if present"
sudo docker container rm microbiome-webapp-container
echo ""
echo "> Removing image if present"
sudo docker image rm microbiome-webapp
echo ""
echo "> Copying necessary files"
cp -r ~/Documents/microbiome_analysis/ ~/Documents/microbiome_webapp/
echo ""
echo "> Building image"
DOCKER_BUILDKIT=1 sudo docker build -t microbiome-webapp .
echo ""
echo "> Launching container"
sudo docker run -d --name microbiome-webapp-container microbiome-webapp
echo ""
echo "> Launching shiny-server webpage"
# google-chrome http://172.17.0.2:3838/microbiome-webapp/
sudo docker inspect microbiome-webapp-container | grep \"IPAddress\":

# docker exec -it iot-dashboard-container /bin/bash
