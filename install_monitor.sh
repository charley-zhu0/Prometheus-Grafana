#!/usr/bin/env bash

set -e

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd $BASEDIR
pwd

function check_floder(){
    if [ ! -d /tmp/prometheus ]; then
        mkdir -p /tmp/prometheus
        sudo chmod -R 777 /tmp/prometheus
    fi
    if [ ! -d /tmp/grafana ]; then
        mkdir -p /tmp/grafana
        sudo chmod -R 777 /tmp/grafana
    fi
}

function install_prometheus(){
    echo "install prometheus"
    # check if docker exist
    if ! command -v docker &> /dev/null; then
        echo "docker not exist, please install docker first"
        return
    fi
    # check if prometheus is running
    if docker ps | grep prometheus; then
        echo "prometheus is running"
        return
    fi
    # install prometheus
    docker run -d --network=host --name prometheus -v $PWD/prometheus.yml:/etc/prometheus/prometheus.yml -v /tmp/prometheus:/prometheus prom/prometheus
    echo "prometheus is running"
}

function install_grafana(){
    echo "install grafana"
    # check if docker exist
    if ! command -v docker &> /dev/null; then
        echo "docker not exist, please install docker first"
        return
    fi
    # check if Grafana is running
    if docker ps | grep grafana; then
        echo "grafana is running"
        return
    fi
    # install Grafana
    docker run -d --name grafana -p 3000:3000 -v /tmp/grafana:/var/lib/grafana grafana/grafana
    echo "grafana is running"
}

function install_node_exporter(){
    echo "install node_exporter"
    # check if node_exporter is running
    if ps -ef | grep node_exporter; then
        echo "node_exporter is running"
        return
    fi
    # install node_exporter
    cd /tmp
    wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
    tar -xvf node_exporter-1.7.0.linux-amd64.tar.gz
    rm -rf node_exporter-1.7.0.linux-amd64.tar.gz
    cd node_exporter-1.7.0.linux-amd64
    sudo nohup ./node_exporter &
    echo "node_exporter is running"
}

function install_mongodb_exporter(){
    echo "install mongodb_exporter"
    # check if mongodb exist
    if ! command -v mongod &> /dev/null; then
        echo "mongodb not exist, please install mongodb first"
        return
    fi
    # check if user prometheus exist in mongodb
    if ! mongo -u prometheus -p prometheus --authenticationDatabase admin --eval "db.getUsers()" | grep prometheus; then
        echo "user prometheus not exist in mongodb, create user prometheus"
        mongo admin --eval "db.createUser({user:"prometheus", pwd:"prometheus", roles:[{role:"read", db:"admin"}, {role:"readAnyDatabase", db:"admin"}, {role:"clusterMonitor", db:"admin"}]});"
    fi
    # check if mongodb_exporter is running
    if ps -ef | grep mongodb_exporter; then
        echo "mongodb_exporter is running"
        return
    fi
    # install mongodb_exporter
    cd /tmp
    wget https://github.com/percona/mongodb_exporter/releases/download/v0.40.0/mongodb_exporter-0.40.0.linux-amd64.tar.gz
    tar -xvf mongodb_exporter-0.40.0.linux-amd64.tar.gz
    rm -rf mongodb_exporter-0.40.0.linux-amd64.tar.gz
    cd mongodb_exporter-0.40.0.linux-amd64
    sudo nohup  ./mongodb_exporter --mongodb.uri mongodb://prometheus:prometheus@127.0.0.1:27017/admin --collect-all  &
    echo "mongodb_exporter is running"
}

function main(){
    check_floder
    install_prometheus
    install_grafana
    install_node_exporter
}

main
