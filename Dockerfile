FROM ubuntu:16.04
# setup dependencies
RUN apt-get update -qq && apt-get install -y gcc autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev wget git-core tzdata
RUN ln -sf /usr/share/zoneinfo/Europe/Copenhagen /etc/localtime
# install packages
RUN apt-get install -y libmysqlclient-dev libcurl4-openssl-dev nodejs
# install app packages
RUN apt-get install -y xvfb php wkhtmltopdf ffmpeg
RUN ln -s /usr/bin/wkhtmltopdf /usr/local/bin/wkhtmltopdf
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
