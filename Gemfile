source 'https://rubygems.org'

group :development do
  gem 'net-ssh', '2.9.4'
  gem 'kitchen-ansiblepush'
  gem 'kitchen-docker'
  # 2.1.1 silently requires more recent Ruby than 1.9.3.  However,
  # including kitchen-sync with sftp does not actually help -- builds
  # were around 31--34 minutes on travis CI with and without SFTP
  # gem 'kitchen-sync', '2.1.0'
  #gem 'kitchen-verifier-serverspec',
  #  :ref => 'ef120567c8ade49c373bd4ac7e4a755408109104'
  #gem 'kitchen-verifier-shell'
  #gem 'serverspec'
  # Pin test-kitchen at 1.10.2 due to
  # https://github.com/ahelal/kitchen-ansiblepush/issues/31
  gem 'test-kitchen', '1.10.2'
  # Work around Thor bug in 0.19.2
  gem 'thor', '0.19.1'
end
