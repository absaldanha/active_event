# ActiveEvent

ActiveEvent is a micro framework for usage within Rails apps. It offers synchronous and asynchronous execution of application specific events through specified handlers.

## Usage

### Defining events

Events are first-class objects of your application, named `XXXEvent`. `ActiveEvent` ships with the `ActiveEvent::Event` module so you can create your own event classes:

```ruby
class FooCreatedEvent
  include ActiveEvent::Event
end
```

Events are instantiated with a hash argument, representing they payload, which can be accessed by the `payload` method.

You are free to build a more semantic API on your event class, but it still needs to be instantiated correctly with the payload in order to be used in asynchronous execution (more about it in Proccessing events).

```ruby
class BarUpdatedEvent
  include ActiveEvent::Event

  def a_value
    payload.dig(:look, :a_value)
  end

  def other_value
    payload.dig(:look, :other_value)
  end
end

BarUpdatedEvent.new(look: { a_value: 1, other_value: 2 })
```

Events also respond to the `name` method that is used when dispatching them to the correct listeners. By default, names are the undescored demodulized class names without the `"Event"` string. For example, the `FooUpdatedEvent` will have the `foo_updated` name. Of course, `name` is just a method that can be overwrote by developers.


### Dispatching events

In order for your application to execute some code in response of an event, you need to dispatch it. That can be done by simply calling the `dispatch` method on your event:

```ruby
event = SomeEvent.new(payload)
event.dispatch
```

The execution of your code regarding the event will be synchronous or asynchronous, depending on your handling configuration.

### Handling events

Before you can dispatch events, you need to configure the handling of events of your application. That can be done with the `subscribe` method on `ActiveEvent`:

```ruby
ActiveEvent.subscribe(FooHandler, on: [FooCreatedEvent, FooUpdatedEvent])
ActiveEvent.subscribe(AsyncFooHandler, on: [FooCreatedEvent], async: true)
```

The `subscribe` method accepts three arguments:
- A list of constants (classes) that will handle the events
- `on`: the list of events that the handler class will work with (note that these are the classes of your events)
- `async` (defaults to `false`): if the events will be handled async or not

The handler classes must be able to be initialized without giving any arguments. Events will be send as the sole argument to an instance method of the handler class with the same name as the event, if the handler responds to that method, otherwise, the event will be send to the `handle` method. Following the example above, the `FooListener` must respond to the `foo_created` and `foo_updated` methods, or the `handle` method.

The list of event classes will be registered, and the handler will only handle those registered events classes. Note that this is a design choice, that enables use cases of handlers that work with all events of a certain type. For example, given the following events:

```ruby
class PostEvent
  include ActiveEvent::Event
end

class PostCreatedEvent < PostEvent
end

class PostUpdatedEvent < PostEvent
end
```

We can subscribe a `PostLogHandler` that will log all events related to posts:

```ruby
class PostLogHandler
  def handle(event)
    log(event.name)
  end
end

ActiveEvent.subscribe(PostLogHandler, on: PostEvent)
```

Lastly, the `async` option signalizes if the handler will be executed sychronous or asynchronous.

### Handling events asynchronous

By passing the `async` flag in a `ActiveEvent.subscribe` call, the handling of events will be done asynchronous. This is achieved by enqueueing an `ActiveJob` job with the `payload` of your event, the event class name and the class name of the handler. Because of that, your event class must be able to correct construct a new event instance from the `build_from_event` class method.

Currently, only `ActiveJob` is supported.

## Repository Info

### Versioning

### Contributions

### Credits
