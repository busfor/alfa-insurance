# AlfaInsurance

Обертка для SOAP API предоставляемого Альфа-Страхованием

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'alfa_insurance'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install alfa_insurance

## Usage

Пример использования:

```ruby
    client = AlfaInsurance::BusClient.new(operator: 'TestBusOperator', product_code: 'TEST-BUS', debug: true)
    response = client.calculate(480)
    response.cost
    response.risk_value
```

Все ответы сервера поддерживают метод success? и если он возвращает false, содержат код и описание ошибки в полях error_code и error_description. 

Описание методов:
### calculate

Принимает на вход стоимость билета (тип Money, или Float), возвращает структуру CalculateResponse с полями cost, risk_value (денежные) и строковым полем risk_type, где содержится код покрываемого риска. Расчет осуществляется без учета валюты - она настраивается на уровне выбора страхового продукта.

```ruby
    response = client.calculate(480)
    response.cost
    response.risk_value
```

### create

Принимает на вход заполненную данными структуру BusInsuranceRequest, возвращает структуру CreateResponse, с полями аналогичными CalculateResponse.

```ruby
    insurance_request = AlfaInsurance::BusInsuranceRequest.new(
      insured_first_name: 'Vassily',
      insured_last_name: 'Poupkine',
      insured_patronymic: 'Petrovitch',
      insured_birth_date: '1980-01-01',
      bus_segments: [
        AlfaInsurance::BusSegment.new(
          number: 1,
          route_number: 33,
          place_number: 14,
          arrival_station: 'Kiev',
          arrival_at: DateTime.parse('2018-03-25 00:00:00+03:00'),
          departure_station: 'Moscow',
          departure_at: DateTime.parse('2018-03-24 12:00:00+03:00')
        )
      ],
      total_value: Money.new(480, 'RUB'),
      customer_phone: '+79161234567',
      customer_email: 'text@example.com'
    )
    response = client.create(insurance_request)
    response.cost
    response.risk_value

```

### confirm

Принимает на вход числовой идентификатор страховки, возвращает структуру ConfirmResponse, с полями insurance_id и document_url (ссылка на pdf)

```ruby
    response = client.confirm(insurance_id)
    response.success?
    response.document_url
```

### cancel

Принимает на вход числовой идентификатор страховки, отменяет страховку, возвращает Reponse

```ruby
    response = client.cancel(insurance_id)
    response.success?
```

### find

Принимает на вход числовой идентификатор страховки, возвращает FindReponse с полями insurance_id, cost, risk_value, risk_type (см. выше) и state, где содержится текстовый статус страховки (например ISSUING, CONFIRMED, CANCELLED)

```ruby
    response = client.find(insurance_id)
    response.state
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/alfa_insurance.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

