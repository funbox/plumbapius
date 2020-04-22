FROM docker.funbox.ru/fb-centos7

RUN yum -y --enablerepo=kaos-testing install erlang22-3 elixir-1.10.2

RUN mix local.hex --force
RUN mix local.rebar --force

ENV LC_ALL=en_US.utf8
RUN ulimit -n 16384

COPY . /app
WORKDIR /app