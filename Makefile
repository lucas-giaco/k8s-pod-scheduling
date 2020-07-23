setup:
	@curl -Lo ./kind "https://github.com/kubernetes-sigs/kind/releases/download/v0.8.1/kind-$$(uname)-amd64"
	@chmod +x kind
	@mv kind $$HOME/.local/bin/kind
	@kind version

start:
	@kind create cluster --config config.yaml

stop:
	@kind delete cluster
