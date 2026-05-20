redis-insight-formula
==================

A SaltStack formula designed to install and configure the [REDIS Insight](https://redis.io/insight/) utility on installation-targets.

It is primarily expected that this formula will be run via [P3](https://www.plus3it.com/)'s "[watchmaker](https://watchmaker.readthedocs.io/en/stable/)" framework.

This formula is able to install the REDIS Insight utility on both Linux[^1] and Windows Server[^2] operating environments. Intallation for internet-connected systems may come from the REDIS Insight utility project's ["releases" page](https://github.com/redis/RedisInsight/releases). If installing this way, the formula will install the latest-available version of the content. Alternately:

* Sites whose installation-targets won't be able to reach the REDIS Insight utility project's GitHub repository will need to self-host copies of the desired content.
* Sites that wish to use a specific version of the REDIS Insight utility will need to target that content

Targeting specific versions of the REDIS Insight utility or local copies of the install-archives can be directed to do so by adding appropriate content to the formula's associated Pillar-data (see thish projct's [pillar.example](pillar.example) file for guidance).


## Available states

- [redis-insight](#redis-insight)
- [redis-insight.clean](#redis-insight.clean)
- [redis-insight.package](#redis-insight.package)
- [redis-insight.package.clean](#redis-insight.package.clean)
- [redis-insight.config](#redis-insight.config)
- [redis-insight.config.clean](#redis-insight.config.clean)

### redis-insight

Executes the `package` and `config` states to install and configure the REDIS Insight utility

### redis-insight.clean

Executes the `package` and `config` states' `clean` actions to fully uninstall the REDIS Insight utility and remove previously-installed browser policy-configs (and, on Windows, associated registry entries)

### redis-insight.package

Executes _just_ the `package` state to install the REDIS Insight utility package.

### redis-insight.package.clean

Executes _just_ the `package.clean` state to uninstall the REDIS Insight utility package.

### redis-insight.config

Executes _just_ the `config` state to install/configure the REDIS Insight utility client-configuration (etc.) files

### redis-insight.config.clean

Executes _just_ the `config` state to uninstall the REDIS Insight utility client-configuration (etc.) files and, on Windows, remove any registry-keys set by prior install-runs of the formula.

## Compatibility Notes:

### Linux-based deployment

1. The ("enterprise") Linux content is provided as a best-effort offering. It appears to properly install and configure the REDIS Insight RPM[^3]. However, when one attempts to launch it on a headless server (e.g., an AWS EC2 with or without a full graphical desktop installed), the `redisinsight` binary attempts to start but ultimately bombs out. This appears to be due to a limitation in the interaction between the RPM-packaged binaries and the expectations for the system they're installed on. This automation _may_ work on a physical, EL-based (RHEL, OEL, Alma, Rocky, etc) hosts with a _real_ GPU installed. However, limitations of the development and testing environment prevents proving this to be true or false
1. As of the April 2026 release (v3.4.2), the RPM is not installable via `dnf` on FIPS-enabled systems[^4]. Due to this limitation, the formula's package installation and cleanup logic performs some workarounds when FIPS-mode is detected to be enabled.


[^1]: As of this README's writing, only Enterprise Linux and related distros (Red Hat and Oracle Enterprise, CentOS Stream, Rocky and Alma Linux). It has only been specifically tested with EL **_9_** variants.
[^2]: As of this README's writing, this functionality has only been tested on Windows Server 2022
[^3]: The RPMs are distributed through the public GitHub project for REDIS Insight. See project's [releases](https://github.com/redis/RedisInsight/releases) page
[^4]: This issue has been [reported](https://github.com/redis/RedisInsight/issues/5950) to the project maintainers
