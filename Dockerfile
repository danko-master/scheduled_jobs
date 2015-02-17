FROM centos:centos7
MAINTAINER Daniil Zhirnov <d.zhirnov@progresspoint.ru>

RUN yum localinstall -y http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
RUN yum localinstall -y http://dl.iuscommunity.org/pub/ius/stable/CentOS/7/x86_64/ius-release-1.0-13.ius.centos7.noarch.rpm
RUN yum install -y yum-plugin-replace
RUN yum upgrade -y
RUN yum groupinstall -y 'Development Tools'
RUN yum install -y zlib-devel
RUN yum install -y ruby rubygem-bundler ruby-devel
RUN yum install -y redis

RUN mkdir -p /home/apps/scheduled_jobs
RUN mkdir -p /tmp/vendor-cache
WORKDIR /home/apps/scheduled_jobs
# Сначала копируем и устанавливаем гемы, т.к. этот шаг долгий и
# при отсутствии изменений в зависимостях может быть закэширован докером
ADD Gemfile /home/apps/scheduled_jobs/Gemfile
ADD Gemfile.lock /home/apps/scheduled_jobs/Gemfile.lock
ADD vendor/cache /home/apps/scheduled_jobs/vendor/cache/

ADD . /home/apps/scheduled_jobs/

