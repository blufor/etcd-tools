# etcd-tools
additional tools for easier ETCD administration

## Installation

1. ```make check``` - check availability of required ruby gems
2. ```sudo make install``` - install the tools

## Tools description

### etcd-erb

```
Usage: /bin/etcd-erb [OPTIONS] < template.erb > outfile

Connection options:
    -s, --host HOST                  hostname/IP of the ETCD service (ETCD_HOST envvar also applies) [DEFAULT: 127.0.0.1]
    -p, --port PORT                  port of the ETCD service (ETCD_PORT envvar also applies) [DEFAULT: 4001]

Common options:
    -h, --help                       show usage
```

#### Example

You need to create an ERB template first. There are two special functions, which will help you with fetching the data from ETCD:
- ```keys```
- ```values```

Using these two, you should be able to either **list subkeys** or **get a value of a key**

Sample ERB code:
```erb
# let's fetch some keys
<%= keys('/test').join('\n') %>

<%= keys('/test/nested').join('\n') %>

# and how about a value?
<%= value('/test/plain') %>
```

produces file like this:
```
# let's fetch some keys
/test/plain
/test/nested

/test/nested/test1
/test/nested/test2

# and how about a value?
true
```

### yaml2etcd
```
Usage: /bin/yaml2etcd [OPTIONS] < config.yaml

Connection options:
    -s, --host HOST                  hostname/IP of the ETCD service (ETCD_HOST envvar also applies) [DEFAULT: 127.0.0.1]
    -p, --port PORT                  port of the ETCD service (ETCD_PORT envvar also applies) [DEFAULT: 4001]

Common options:
    -r, --root-path PATH             root PATH of ETCD tree to inject the data [DEFAULT: /config]
    -v, --verbose                    run verbosely
    -h, --help                       show usage
```
#### Example

Let's have a YAML file called ```test.yaml```:
```yaml
---
plain: true
nested:
  test1: [1,2]
  test2: [3,4]
```

Now import the data with ```yaml2etcd -v -r /test < test.yaml```:

```
Connected to ETCD on 127.0.0.1:4001
SET: /test/plain: true
SET: /test/nested/test1: [1,2]
SET: /test/nested/test2: [3,4]
```
