ANSIBLES=ansible1.6.1 \
	ansible1.7.2 \
	ansible1.8.4 \
	ansible1.9.4 \
	ansible2.0.0 \

all: test

ansible%:
	test -d $@ || virtualenv $@
	$@/bin/pip install ansible==$*

vendor/bundle:
	bundle install --path "$@"

test: vendor/bundle $(ANSIBLES)
	bundle exec kitchen test all
