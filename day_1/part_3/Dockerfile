FROM ruby:latest

RUN gem install sinatra puma
COPY ./ping.rb ping.rb

CMD ["ruby", "ping.rb"]
EXPOSE 4567/tcp
