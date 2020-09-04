### Changelog

##### 0.14.0

* Support tomograph 3.0 json schema format

##### 0.13.0

* `mix plumbapius.cover -m` option implemented. It enables oneOfs and enums coverage tracking.

##### 0.12.0

* `mix plumbapius.cover -v` option implemented

##### 0.11.0

* `mix plumbapius.cover` can now ignore preconfigured requests (check readme)

##### 0.10.0

* `mix plumbapius.cover` task for listing uncovered requests and checking min coverage

##### 0.9.0

* Exceptions for requests undefined in schema are now raised only in RaiseValidationError plug

##### 0.8.1

* Bugfix: get_docs task checked out branch in wrong repository after initial cloning
