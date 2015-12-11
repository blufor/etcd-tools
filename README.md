# etcd-tools
additional tools for easier ETCD administration

## Installation

```gem install etcd-tools --no-rdoc --no-ri```


## Tools description

### etcd-erb

```
Applies variables from ETCD onto ERB template

Usage: ./etcd-erb [OPTIONS] < template.erb > outfile

Connection options:
    -u, --url URL                    URL endpoint of the ETCD service (ETCDCTL_ENDPOINT envvar also applies) [DEFAULT: http://127.0.0.1:4001]

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
Reads YAML file and imports the data into ETCD

Usage: ./yaml2etcd [OPTIONS] < config.yaml

Connection options:
    -u, --url HOST                   URL endpoint of the ETCD service (ETCDCTL_ENDPOINT envvar also applies) [DEFAULT: http://127.0.0.1:4001]

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

### etcd-ip-watchdog
