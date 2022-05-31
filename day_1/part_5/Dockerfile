FROM ruby:latest

RUN gem install sinatra puma redis
COPY ./ping.rb ping.rb

CMD ["ruby", "ping.rb"]
EXPOSE 4567/tcp
