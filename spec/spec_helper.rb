ENV['RACK_ENV'] = 'test'
ENV['DATABASE_ADAPTER'] ||= 'mongoid'

Bundler.require
