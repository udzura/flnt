# Flnt

Gentle post-to-fluentd log solution.

## Powered by wercker

[![wercker status](https://app.wercker.com/status/4c5b18d2fe3debeee48b7f0fab81eb12/m/ "wercker status")](https://app.wercker.com/project/bykey/4c5b18d2fe3debeee48b7f0fab81eb12)

## Installation

Usual Gemfile way:

```ruby
gem 'flnt'
```

```bash
$ bundle install
```

## Usage

### Just post log to fluent

* Setting up fluentd on your localhost:24224
* Call the methods below:
```ruby
Flnt.app.payment.info "Payment done"
```
* Then, your fluentd receives json `{message: "Payment done"}` with tag `app.payment.info`

`Flnt` compiles method chaining into a tag, and when the method is called with an argument,
it emits the information to fluentd.

NOTE: You cannot use methods such as `foo?` or `foo!` for tag suffix. only `/[a-zA-Z0-9_]/` are OK.

### Configuration of fluentd

```ruby
Flnt::Configuration.configure do |c|
  c.prefix = "foobar"
  c.host = 'fluentd.example.jp'
  c.port = 12345
end
```

## License

see `LICENSE.txt`.


## Contributing

The usual github way.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
