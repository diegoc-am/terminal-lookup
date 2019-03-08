# Terminal Lookup

[![pipeline status](https://gitlab.com/belfazt/terminal-lookup/badges/master/pipeline.svg)](https://gitlab.com/belfazt/terminal-lookup/commits/master)
[![coverage report](https://gitlab.com/belfazt/terminal-lookup/badges/master/coverage.svg)](https://gitlab.com/belfazt/terminal-lookup/commits/master)

## Developing

### Dependencies

- docker
- docker-compose
- rbenv

### Installation

```sh
rbenv install
gem install bundler
bundle install
docker-compose up -d
bundle exec rake db:migrate
```

#### Loading location codes

```sh
bundle exec rake import_locodes
```

#### Running the tests

```sh
bundle exec rake test
```

#### Running an evaluation suite

```sh
bundle exec rake
```

### Shipping

```sh
docker build . -t terminal-lookup-api:latest
export DESIRED_PORT=8080
export ENVIRONMENT=production
docker run -p "$DESIRED_PORT":8080 terminal-lookup-api:latest bundle exec rackup -o 0.0.0.0 -E "$ENVIRONMENT" -p 8080
```

## Contributors
* Diego Camargo
