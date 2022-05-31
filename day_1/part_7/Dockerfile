FROM ruby:latest

RUN gem install sinatra puma redis
WORKDIR /root/app

CMD ["date"]
EXPOSE 4567/tcp
