network_programming
=====

Working through [Network Programming in Elixir and Erlang][npee] in Erlang

[npee]: https://pragprog.com/titles/alnpee/network-programming-in-elixir-and-erlang/

# Chapter 3

To start the chat server, open `rebar3 shell` and run
`chat_acceptor:start_link()`. It should accept an arbitrary number of clients. In
another terminal open `rebar3 shell` and run,

```erlang
> Pid = chat_client:run().
Enter your username: % enter your username here!
> chat_client:send(Pid, ~"Your message here").
```

Note: it isn't very clever. For example, you can use duplicate usernames.
