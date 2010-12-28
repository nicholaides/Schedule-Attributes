# Schedule Attributes

Schedule Attributes allows models (ORM agnostic) to accept recurring schedule form parameters and translate them into an [IceCube](https://github.com/seejohnrun/ice_cube/) `Schedule` object. Schedule Attributes adds `schedule_attributes` and `schedule_attributes=` methods that let your model automatically populate Rails forms and receive HTML form parameters. Additionally, it provides access to the `IceCube::Schedule` object itself.

## Usage

To use, include the `ScheduleAttributes` module in your model class.

```ruby
class SomeModel
  include ScheduleAttributes
end
```

Your model must respond to `:schedule_yaml` and `:schedule_yaml=`, because ScheduleAttributes will serialize and deserialize the schedule in YAML using this column.  If you are using ActiveRecord, make a string column called `schedule_yaml`. If you're using Mongoid, make a string field like so: `field :schedule_yaml`.

You model will gain the following methods:

## `schedule_attributes=`

Accepts form a parameter hash that represent a schedule, and creates an `IceCube::Schedule` object, and serializes it into your `schedule_yaml` field.

E.x.

```ruby
@event.schedule_attributes = params[:event][:schedule_attributes]
```

### Parameters Accepted

Because they are coming from a form, all parameters are expected to be in string format.

##### `:repeat`

Can be `0` or `1`. The parameter should respond to `:to_i`. `0` indicates that the event does not repeat. Anything else indicates that the event repeats.

#### Parameters for non-repeating events

The following parameters will only be used if the `repeat` parameter is `0`.

##### `:date`

The date that this (non-repeating) event is scheduled for. Should be parseable by `Time.parse`. This parameter is only used if `:repeat` is `0`.

#### Parameters for repeating events

The following parameters will only be used if the `repeat` parameter is `1`.

##### `:start_date`

The date at which the event starts repeating. Must be parseable by `Time.parse`.

#### `:interval_unit`

The interval unit by which the event repeats. Can be `"day"` or `"week"`. For example, if the even repeats every day, this would be `"day"`. If it repeats weekly, this would be `"week"`.

#### `:interval`

The interval by which the event repeats. Should be an integer (in string format). For example, if the event repeats every other day, this parameter should be `2`, and `:interval_unit` should be `"day"`. If it repeats every other week, it should be `2` and interval unit should be `"week"`.

#### `:sunday`, `:monday`, `:tuesday`, `:wednesday`, `:thursday`, `:friday`, `:saturday`

Indicates with a `0` or `1` whether the event repeats on this day. For example, if the event repeats every other week on Tues and Thursday, then the parameters would include these: `:interval => "2", :interval_unit => "week", :tuesday => "1", :thursday => "1"`. These parameters are only used if `:repeat` is `1` and `:interval_unit` is `"week"`.

## `schedule_attributes`

Provides an OStruct with methods that correspond to the attributes accepted by `#schedule_attributes=`


##`schedule`

Returns a the `IceCube::Schedule` object that is serialized to the model's `schedule_yaml` field. If there is none, it returns a schedule with `start_date` of the current date, recurring daily, ending never.
