build:
	@rebar3 compile

format:
	@rebar3 fmt -w

.PHONY: build format
