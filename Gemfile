source 'https://rubygems.org'

group :development do
  gem 'net-ssh', '2.9.4'
  gem 'kitchen-ansiblepush', '!= 0.5.2'
  # kitchen-docker 2.5.0 is broken, see
  # https://github.com/ahelal/kitchen-ansiblepush/issues/31
  gem 'kitchen-docker', '!= 2.5.0'
  # 2.1.1 silently requires more recent Ruby than 1.9.3.  However,
  # including kitchen-sync with sftp does not actually help -- builds
  # were around 31--34 minutes on travis CI with and without SFTP
  # gem 'kitchen-sync', '2.1.0'
  #gem 'kitchen-verifier-serverspec',
  #  :ref => 'ef120567c8ade49c373bd4ac7e4a755408109104'
  #gem 'kitchen-verifier-shell'
  #gem 'serverspec'
  gem 'test-kitchen'
  gem 'thor', '!= 0.19.2'
end
