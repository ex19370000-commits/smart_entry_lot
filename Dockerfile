FROM ruby:3.1.4
ENV LANG C.UTF-8
ENV TZ Asia/Tokyo

RUN apt-get update -qq && apt-get install -y ca-certificates curl gnupg \
  && mkdir -p /etc/apt/keyrings \
  && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
  && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
  && apt-get update && apt-get install -y nodejs \
  && npm install --global yarn

RUN mkdir /smart_entry_lot
WORKDIR /smart_entry_lot

RUN gem install bundler:2.3.17
COPY Gemfile /smart_entry_lot/Gemfile
COPY Gemfile.lock /smart_entry_lot/Gemfile.lock

RUN bundle install
COPY . /smart_entry_lot

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]