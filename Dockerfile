# -----
FROM node:14.4-alpine AS build

RUN apk update
RUN apk add --no-cache python gcc make g++ build-base git lzo bzip2 openssl bash file postgresql mosquitto nano go coreutils
#ENV PYTHONUNBUFFERED=1
#RUN apk add --no-cache python3 && \
#    if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi 


#RUN mv /usr/src/dagviz/k-explorer /usr/src/k-explorer
#RUN cd /usr/src/k-explorer && npm install && npm link
#RUN npm link k-explorer
#RUN mv /usr/src/dagviz/k-explorer /usr/src/dagviz/k-explorer
#RUN cd /usr/src/dagviz/k-explorer && npm install && npm link
#RUN npm link k-explorer

RUN addgroup -S kobrax && adduser -S kobrax -G kobrax
RUN mkdir -p /run/postgresql
RUN chown kobrax:kobrax /run/postgresql

# Tell docker that all future commands should run as the appuser user

WORKDIR /home/kobrax/releases/kobrax
COPY . .
RUN rm -rf node_modules
RUN rm package-lock.json
#RUN chown -R kobrax:kobrax .


RUN npm install
RUN npm install @kobradag/process-list
RUN npm install -g emanator@latest
RUN emanate --local-binaries --no-ssh


USER kobrax

EXPOSE 16210 16211 16310 16311 11224 18792 
# 18787 
# (pgsql - may conflict with other instances)

ENTRYPOINT ["node","kobrax.js","--init","--nice","--mine"]
