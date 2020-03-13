FROM elixir:1.10.2-alpine

EXPOSE 4000
ENV PORT=4000 \
    MIX_ENV=prod \
    HOME=/opt/app \
    TERM=xterm \
    SERVICE=line_bot

WORKDIR ${HOME}

RUN apk --update upgrade && \
    apk add --update bash && rm -rf /var/cache/apk/* && \
    apk add --update --no-cache bash make automake cmake g++ git libtool openssl openssl-dev libuv libuv-dev && \
    apk add --update --no-cache --virtual build-dependencies build-base && \
    apk add --update --no-cache curl wget openssh-client grep

RUN mkdir -p /opt/${SERVICE}/log

COPY mix.exs mix.lock ./
# RUN ls && ls /root/ && mkdir /root/.ssh &&  mv ./service-ssh-key /root/.ssh/id_rsa
# RUN chmod og-rwx /root/.ssh/id_rsa
# RUN echo "	StrictHostKeyChecking no" >> /etc/ssh/ssh_config

RUN rm -Rf _build && \
    mix local.hex --force && \
    mix local.rebar --force && \
    mix do deps.get, deps.compile

COPY . .
RUN mix release --overwrite && \
    cp -a ./_build/prod/rel/${SERVICE}/. /opt/${SERVICE}/ && \
    cp ./erl_inetrc /opt/${SERVICE}/erl_inetrc && \
    cd /opt/${SERVICE} && \
    rm -rf /opt/app/* && \
    chmod -R 777 /opt/app && \
    chmod -R 777 /opt/${SERVICE}

ENV ERL_INETRC=/opt/${SERVICE}/erl_inetrc

WORKDIR /opt/${SERVICE}

USER 9999:9999

CMD bin/${SERVICE} start
