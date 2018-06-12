FROM ubuntu:16.04
# setup dependencies
RUN apt-get update -qq && apt-get install -y gcc autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev wget git-core tzdata
RUN ln -sf /usr/share/zoneinfo/Europe/Copenhagen /etc/localtime
# install packages
RUN apt-get install -y libmysqlclient-dev libcurl4-openssl-dev nodejs
# install app packages
RUN apt-get install -y locales xvfb php wkhtmltopdf ffmpeg imagemagick ffmpegthumbnailer unoconv
# set locale for ffmpegthumbnailer
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
RUN ln -s /usr/bin/wkhtmltopdf /usr/local/bin/wkhtmltopdf

# install
ENV DEBIAN_FRONTEND noninteractive
ENV VERSION 8
ENV UPDATE 171
ENV BUILD 11
ENV SIG 512cd62ec5174c3487ac17c61aaa89e8
ENV JAVA_HOME /usr/lib/jvm/java-${VERSION}-oracle
ENV JRE_HOME ${JAVA_HOME}/jre
RUN apt-get update && apt-get install ca-certificates curl \
        -y --no-install-recommends && \
  curl --silent --location --retry 3 --cacert /etc/ssl/certs/GeoTrust_Global_CA.pem \
  --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
  http://download.oracle.com/otn-pub/java/jdk/"${VERSION}"u"${UPDATE}"-b"${BUILD}"/"${SIG}"/server-jre-"${VERSION}"u"${UPDATE}"-linux-x64.tar.gz \
  | tar xz -C /tmp && \
  mkdir -p /usr/lib/jvm && mv /tmp/jdk1.${VERSION}.0_${UPDATE} "${JAVA_HOME}" && \
  apt-get autoclean && apt-get --purge -y autoremove && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN update-alternatives --install "/usr/bin/java" "java" "${JRE_HOME}/bin/java" 1 && \
  update-alternatives --install "/usr/bin/javac" "javac" "${JAVA_HOME}/bin/javac" 1 && \
  update-alternatives --set java "${JRE_HOME}/bin/java" && \
  update-alternatives --set javac "${JAVA_HOME}/bin/javac"


# install ruby
RUN cd
RUN wget https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.1.tar.gz
RUN tar -xzvf ruby-2.3.1.tar.gz
RUN cd ruby-2.3.1/ && ./configure && make && make install
RUN gem install bundler -N
RUN mkdir /gemified
WORKDIR /gemified
COPY Gemfile /gemified/Gemfile
COPY Gemfile.lock /gemified/Gemfile.lock
RUN bundle install
