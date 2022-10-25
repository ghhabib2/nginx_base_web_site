#!/bin/bash
if [ -d ./volumes ]
then
    echo -e "\033[1;36m * volumes folder already exists \033[0m"
else
    echo -e "\033[1;36m * creating volumes folder \033[0m"
    mkdir -p ./volumes/app/mattermost/{config,data,logs,plugins,client/plugins,bleve-indexes}
    chown -R 2000:2000 ./volumes/app/mattermost
fi

echo -e "\033[1;36m * Running the commands to setup mattermost \033[0m"

docker-compose -f docker-compose.yml -f docker-compose.without-nginx.yml up -d