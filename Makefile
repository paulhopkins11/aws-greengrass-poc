help:
	python basic_discovery.py -h
pub:
	python src/basic_discovery.py \
	-r devices/root-ca-cert.pem \
	--cert certs/device1.cert.pem \
	--key certs/device1.private.key \
	--thing-name HelloWorldPublisher \
	--topic 'newsoft/training/pubsub' \
	--mode publish \
	--region $(region) \
	--message 'Hello, Newsoft Training! Sent from HelloWorldPublisher'

sub:
	python src/basic_discovery.py \
	-r devices/root-ca-cert.pem \
	--cert certs/device2.cert.pem \
	--key certs/device2.private.key \
	--thing-name HelloWorldSubscriber \
	--topic 'newsoft/training/pubsub' \
	--mode subscribe \
	--region $(region)
