source 'https://rubygems.org'

group :development do
  gem 'kitchen-ansiblepush', '!= 0.5.2'
  # kitchen-docker 2.5.0 is broken, see
  # https://github.com/ahelal/kitchen-ansiblepush/issues/31
  gem 'kitchen-docker', '!= 2.5.0'
  # 2.1.1 silently requires more recent Ruby than 1.9.3.  However,
  # including kitchen-sync with sftp does not actually help -- builds
  # were around 31--34 minutes on travis CI with and without SFTP
  # gem 'kitchen-sync', '2.1.0'
  # Blacklist 0.6.2 due to
  # https://github.com/neillturner/kitchen-verifier-serverspec/pull/20
  #gem 'kitchen-verifier-serverspec', '!= 0.5.2', '!= 0.6.2'
  gem 'kitchen-verifier-serverspec',
    :git => 'https://github.com/wtanaka/kitchen-verifier-serverspec.git',
    :ref => '6246275109f296feabb9d389fc4dacd87e4208ca'
  #gem 'kitchen-verifier-shell'
  gem 'net-ssh'
  #gem 'serverspec'
  gem 'test-kitchen'
  gem 'thor', '!= 0.19.2'
end
