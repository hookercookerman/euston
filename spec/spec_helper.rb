# -*- coding: utf-8 -*-

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require 'bundler'
Bundler.setup
Bundler.require :default, :test

require 'awesome_print'

require 'cqrs'
require 'aggregate_root_samples'
