## CHANGELOG.md

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this project adheres to [Semantic Versioning](http://semver.org/).

### 0.1.1

**Released**: 2026.05.21

**Summary**:

* Added content for Windows targets:
    * Added automation for installalation of REDIS Insight installer-EXE
    * Added automation for configuration of REDIS Insight to provide a "user-ready" usage-environment
    * Added automation for cleaning up  RDIS Insight installations made with previous invocations of this project's automation
* Add CI tests to continually validate Windows-related automation-content
* Updated project-documentation (READMEs, pillar.example, etc) for newly-added Windows functionality

### 0.1.0

**Released**: 2026.05.20

**Summary**:

* Added content for ("enterprise") Linux targets:
    * Added automation for installalation of REDIS Insight RPM
    * Added automation for configuration of REDIS Insight to provide a "user-ready" usage-environment
    * Added automation for cleaning up  RDIS Insight installations made with previous invocations of this project's automation
* Add CI tests to continually validate Linux-related automation-content
* Updated project-documentation (READMEs, pillar.example, etc) for newly-added ("enterprise") Linux functionality


### 0.0.1

**Released**: 2026.05.14

**Summary**:

*   Cloned project from https://github.com/plus3it/repo-template
*   Created redis-insight directory-tree contents by:
    1.   Cloning https://github.com/saltstack-formulas/template-formula.git
    2.   Executing `bin/convert-formula.sh redis-insight` in the new repo-copy
    3.   Moving the resulting `redis-insight` directory into this project's space
    4.   Updating all imports from "`redis__insight`" to "`redis_insight`"
*   Update [LICENSE](LICENSE), CHANGELOG.md (this file), [README.md](README.md) and [.bumpversion.cfg](.bumpversion.cfg) per the P3 repo-template guidance
*   Update the `.github` and `tests` directories' contents  per the P3 repo-template guidance
