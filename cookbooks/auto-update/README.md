auto-update Cookbook
====================

This cookbook keeps your system updated. Important: Use this cookbook very carefully! Updates may casue unwanted changes and system failures.

Requirements
------------

### Platforms
The recipes work on the following tested platforms:

- Ubuntu 12.04, Ubuntu 14.04
- CentOS 6.5

It may work on other platforms or versions of the above platforms with or without modification.

#### packages
- `apt` - apt has been already implemented the auto-update function for the Debian family

Attributes
----------
#### auto-update::default

* default['auto-update']['enabled'] - Auto update is disabled by default. It must be explicitly set `true` in order to work.
* default['auto-update']['stamp_file'] - Location of the stamp file in Red Hat family.
* default['auto-update']['interval'] - Minimum interval between updates.

Usage
-----
#### auto-update::default

Include `auto-update` in the `run_list` of the node or in the target environment and set to true
the ['auto-update']['enabled'] attribute. 

License & Authors
-----------------
- Author:: Sandor Acs (<acs.sandor@sztaki.mta.hu>)
- Author:: Mark Gergely (<gergely.mark@sztaki.mta.hu>)

```text
Copyright 2014, MTA SZTAKI

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```