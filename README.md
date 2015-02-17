Модуль корректировки redis
==========================

Данная программа слушает RabbitMQ очередь *svp_redis_correction* 


### Настройка Docker и fig

1. Утановить Docker:

    ```bash
    echo 'deb https://get.docker.com/ubuntu docker main' | sudo tee /etc/apt/sources.list.d/docker.list
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
    sudo apt-get update
    sudo apt-get install lxc-docker
    sudo gpasswd -a ${USER} docker
    sudo service docker restart
    ```

    перелогиниться, чтобы добавление в группу вступило в силу:

    ```
    groups | grep docker
    ```

2. Утановить fig:

    ```
    sudo curl -L https://github.com/docker/fig/releases/download/1.0.1/fig-`uname -s`-`uname -m` > fig
    chmod +x fig
    sudo mv fig /usr/local/bin
    ```



