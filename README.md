Kong Plugin - *Route on Header*
====================
A plugin that will send request to a different upstream when it matches all of the header and values defined. 

This plugin was developed using the `kong-vagrant`
[development environment](https://github.com/Mashape/kong-vagrant). The details below will assume that you are developing in the kong-vagrant environment.

## Enabling the plugin (on a Route)
```
curl -X POST http://kong:8001/routes/{route_id}/plugins \
  --data "name=route-on-header"
  --data "config.upstream=upstream.name"
  --data "config.headers=name1:value1,name2:value2"
```

## Parameters
| paramater | required  | type         | 
|-----------|-----------|--------------|
| upstream  | true      | string       |
| headers   | true      | array(string)|

- *upstream*: this is the name of the upstream cluster in which you want to reroute the request based on if all the header names and values match the ones you defined when enabling the plugin. This value should be a hostname and it will correspond to the name of the upstream object as well as the host of a service. 

- *headers*: and array of strings that define what header names and corresponding values are required in a request for that request to be routed to a different upstream. The headers array needs to be defined with a colon seperated list of name:value pairs. Those name:value pairs are seperate by a ','
  - Header names are not case sesnitive and will match on upper or lower case names. The values for those headers are case sensitive. 
  - Spaces are allowed between the comma seperated list. Spaces within the header name or value will not be recognized. Spaces are removed prior to comparison. 
  

## Usage and Assumptions

- An upstream is already defined with a corresponding service to handle the requests that get rerouted based on the header match. This upstream name will correspond to the upstream paramater you define as 'config.upstream'


## Test

To test this plugin in isolation run the following command from /kong directory on your vagrant instance 

```
vagrant@ubuntu-bionic:/kong$ bin/busted /kong-plugin/spec/route-on-header
```

## Furthur considerations ...

- Harden plugin scheme to more closely match required paramater
- Determine more elegant data scheme to capture header array of name and value pairs 
  - Currently although the headers paramaters is an 'array' the items are all stored in one item of the array as a string
- Add unit tests to cover more of the usecases 
    - Currently the unit test just checks for two basic usecases if the headers match or they do not match
